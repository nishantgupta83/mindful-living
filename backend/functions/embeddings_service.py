#!/usr/bin/env python3
"""
RAG Embedding Service for MindfulLiving
- Generates vector embeddings for all scenarios
- Stores embeddings in Firestore for semantic search
- Built for scalability and persistence
"""

import os
import json
import time
from typing import List, Dict, Tuple
from dataclasses import dataclass, asdict
import firebase_admin
from firebase_admin import credentials, firestore
from sentence_transformers import SentenceTransformer
from dotenv import load_dotenv
import logging

load_dotenv()

# ============================================================================
# LOGGING SETUP
# ============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# ============================================================================
# CONFIG
# ============================================================================

FIREBASE_KEY = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
EMBEDDING_MODEL = "all-MiniLM-L6-v2"  # Fast, 384-dim, good quality
BATCH_SIZE = 50  # Batch embeddings to reduce API calls

@dataclass
class ScenarioEmbedding:
    scenario_id: str
    title: str
    embedding: List[float]
    text_snippet: str
    model_name: str
    created_at: str

# ============================================================================
# FIREBASE SETUP
# ============================================================================

def init_firebase():
    """Initialize Firebase connection"""
    if not firebase_admin._apps:
        cred = credentials.Certificate(FIREBASE_KEY)
        firebase_admin.initialize_app(cred, {'projectId': PROJECT_ID})
    return firestore.client()

# ============================================================================
# EMBEDDING GENERATION
# ============================================================================

def load_embedding_model(model_name: str):
    """Load sentence-transformer model"""
    logger.info(f"Loading embedding model: {model_name}")
    model = SentenceTransformer(model_name)
    logger.info(f"✓ Model loaded: {model_name} ({model[1].word_embedding_dimension} dimensions)")
    return model

def create_scenario_text(scenario: Dict) -> str:
    """Create combined text for embedding"""
    parts = [
        scenario.get('title', ''),
        scenario.get('description', ''),
        ' '.join(scenario.get('keyInsights', [])),
        ' '.join(scenario.get('tags', []))
    ]
    return ' '.join(filter(None, parts))

def embed_scenarios_batch(db: firestore.Client, model, batch_size: int = 50):
    """
    Generate and store embeddings for all scenarios

    Process:
    1. Fetch scenarios in batches
    2. Generate embeddings
    3. Store in Firestore
    4. Log progress
    """
    logger.info("=" * 70)
    logger.info("🚀 Starting Scenario Embedding Pipeline")
    logger.info("=" * 70)

    # Get total count
    total_docs = db.collection('life_situations').count().get()[0][0].value
    logger.info(f"Total scenarios to embed: {total_docs}")

    processed = 0
    embedded = 0
    failed = 0
    start_time = time.time()

    # Process in batches
    offset = 0
    while offset < total_docs:
        batch_start = time.time()

        # Fetch batch
        docs = db.collection('life_situations')\
            .order_by('__name__')\
            .offset(offset)\
            .limit(batch_size)\
            .stream()

        scenarios = []
        for doc in docs:
            scenarios.append((doc.id, doc.to_dict()))

        if not scenarios:
            break

        logger.info(f"\n📦 Batch {offset//batch_size + 1}: Processing {len(scenarios)} scenarios...")

        # Generate embeddings
        texts_to_embed = [create_scenario_text(data) for _, data in scenarios]
        embeddings = model.encode(texts_to_embed, show_progress_bar=True)

        # Store in Firestore
        batch_write = db.batch()
        for idx, (scenario_id, scenario_data) in enumerate(scenarios):
            try:
                embedding_doc = {
                    'scenario_id': scenario_id,
                    'title': scenario_data.get('title', ''),
                    'embedding': embeddings[idx].tolist(),  # Convert to list for Firestore
                    'text_snippet': texts_to_embed[idx][:200],  # Store snippet for debugging
                    'model_name': EMBEDDING_MODEL,
                    'created_at': firestore.SERVER_TIMESTAMP,
                    'dimension': len(embeddings[idx])
                }

                # Store at life_situations/{id}/embedding
                batch_write.set(
                    db.collection('life_situations').document(scenario_id).collection('_embeddings').document('v1'),
                    embedding_doc
                )
                embedded += 1

            except Exception as e:
                logger.error(f"❌ Error embedding {scenario_id}: {e}")
                failed += 1

        # Commit batch write
        batch_write.commit()

        processed += len(scenarios)
        batch_elapsed = time.time() - batch_start
        logger.info(f"✓ Batch complete: {embedded} embedded, {failed} failed ({batch_elapsed:.1f}s)")

        offset += batch_size

    # Summary
    elapsed = time.time() - start_time
    logger.info("\n" + "=" * 70)
    logger.info("✅ EMBEDDING PIPELINE COMPLETE")
    logger.info("=" * 70)
    logger.info(f"Total Processed: {processed}")
    logger.info(f"Successfully Embedded: {embedded}")
    logger.info(f"Failed: {failed}")
    logger.info(f"Time Elapsed: {elapsed:.1f}s ({elapsed/60:.1f} minutes)")
    logger.info(f"Average Time/Scenario: {(elapsed/processed):.2f}s")
    logger.info("=" * 70)

    return embedded, failed

# ============================================================================
# VECTOR SEARCH (For Query Testing)
# ============================================================================

def cosine_similarity(a: List[float], b: List[float]) -> float:
    """Calculate cosine similarity between two vectors"""
    import numpy as np
    a, b = np.array(a), np.array(b)
    return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))

def search_similar_scenarios(
    db: firestore.Client,
    query_embedding: List[float],
    top_k: int = 3
) -> List[Tuple[str, float]]:
    """
    Search for top-k similar scenarios using vector similarity

    NOTE: This is for demonstration. Production should use:
    - Typesense (vector search DB)
    - Weaviate
    - Pinecone
    - Firestore Vector Search API (when available)
    """
    logger.info(f"Searching for top {top_k} similar scenarios...")

    # Fetch all embeddings (NOT scalable for 1000+ - use Typesense in prod)
    results = []
    docs = db.collection_group('_embeddings').stream()

    for doc in docs:
        data = doc.to_dict()
        embedding = data.get('embedding', [])
        scenario_id = data.get('scenario_id', '')

        similarity = cosine_similarity(query_embedding, embedding)
        results.append((scenario_id, similarity))

    # Sort and return top-k
    results.sort(key=lambda x: x[1], reverse=True)
    return results[:top_k]

# ============================================================================
# MAIN
# ============================================================================

def main():
    """Main entry point"""
    db = init_firebase()
    model = load_embedding_model(EMBEDDING_MODEL)

    # Generate embeddings for all scenarios
    embedded, failed = embed_scenarios_batch(db, model, batch_size=BATCH_SIZE)

    if embedded > 0:
        logger.info(f"\n💾 Stored {embedded} embeddings in Firestore")
        logger.info("Next: Deploy talk_to_me_function.py as Cloud Function")

if __name__ == "__main__":
    main()
