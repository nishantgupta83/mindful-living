#!/usr/bin/env python3
"""
'Talk to Me' Cloud Function - RAG-Powered Coaching
- User asks a question in natural language
- Retrieves top 3 relevant scenarios via vector search
- Generates personalized coaching using RAG (Retrieval-Augmented Generation)
- Returns structured JSON coaching response
- Designed to run in Firebase Cloud Functions or local dev server

Deployment:
  gcloud functions deploy talk_to_me \
    --runtime python39 \
    --trigger-http \
    --allow-unauthenticated
"""

import os
import json
import time
from typing import List, Dict, Optional
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
from sentence_transformers import SentenceTransformer
import requests
from dotenv import load_dotenv
import logging

load_dotenv()

# ============================================================================
# LOGGING
# ============================================================================

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ============================================================================
# CONFIG
# ============================================================================

FIREBASE_KEY = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
MODEL_NAME = os.getenv("MODEL_NAME", "mistral")
EMBEDDING_MODEL = "all-MiniLM-L6-v2"

# Singleton model instances (loaded once)
_embedding_model = None
_db = None

# ============================================================================
# INITIALIZATION
# ============================================================================

def get_db():
    """Get Firestore client (singleton)"""
    global _db
    if _db is None:
        if not firebase_admin._apps:
            cred = credentials.Certificate(FIREBASE_KEY)
            firebase_admin.initialize_app(cred, {'projectId': PROJECT_ID})
        _db = firestore.client()
    return _db

def get_embedding_model():
    """Get embedding model (singleton)"""
    global _embedding_model
    if _embedding_model is None:
        logger.info(f"Loading embedding model: {EMBEDDING_MODEL}")
        _embedding_model = SentenceTransformer(EMBEDDING_MODEL)
    return _embedding_model

# ============================================================================
# VECTOR SEARCH
# ============================================================================

def retrieve_scenarios(query: str, top_k: int = 3) -> List[Dict]:
    """
    Retrieve top-k relevant scenarios for a user query

    Process:
    1. Embed user query
    2. Search for similar scenarios
    3. Fetch full scenario details
    4. Return as context for RAG
    """
    logger.info(f"🔍 Retrieving scenarios for: {query}")

    try:
        db = get_db()
        model = get_embedding_model()

        # Embed query
        query_embedding = model.encode(query).tolist()

        # Search - fetch all embeddings and score (temporary solution)
        # TODO: Replace with Typesense or Firestore Vector Search API
        candidates = []
        embedding_docs = db.collection_group('_embeddings').stream()

        for doc in embedding_docs:
            data = doc.to_dict()
            scenario_id = data.get('scenario_id', '')
            embedding = data.get('embedding', [])

            # Cosine similarity
            import numpy as np
            similarity = float(np.dot(query_embedding, embedding) /
                             (np.linalg.norm(query_embedding) * np.linalg.norm(embedding)))
            candidates.append({
                'scenario_id': scenario_id,
                'similarity': similarity
            })

        # Sort and get top-k
        candidates.sort(key=lambda x: x['similarity'], reverse=True)
        top_candidates = candidates[:top_k]

        logger.info(f"✓ Found {len(top_candidates)} candidates")

        # Fetch full scenario details
        retrieved_scenarios = []
        for candidate in top_candidates:
            scenario_id = candidate['scenario_id']
            similarity = candidate['similarity']

            try:
                scenario_doc = db.collection('life_situations').document(scenario_id).get()
                if scenario_doc.exists:
                    scenario_data = scenario_doc.to_dict()
                    retrieved_scenarios.append({
                        'id': scenario_id,
                        'title': scenario_data.get('title', ''),
                        'description': scenario_data.get('description', ''),
                        'keyInsights': scenario_data.get('keyInsights', []),
                        'category': scenario_data.get('category', ''),
                        'similarity': similarity
                    })
            except Exception as e:
                logger.error(f"❌ Error fetching scenario {scenario_id}: {e}")

        logger.info(f"✓ Retrieved {len(retrieved_scenarios)} scenarios")
        return retrieved_scenarios

    except Exception as e:
        logger.error(f"❌ Retrieval error: {e}")
        return []

# ============================================================================
# RAG PROMPT ENGINEERING
# ============================================================================

def build_rag_prompt(user_query: str, retrieved_scenarios: List[Dict]) -> str:
    """Build RAG prompt with retrieved context"""

    context = "\n".join([
        f"Scenario: {s['title']}\n"
        f"Category: {s['category']}\n"
        f"Description: {s['description']}\n"
        f"Key Insights: {', '.join(s.get('keyInsights', []))}\n"
        for s in retrieved_scenarios
    ])

    prompt = f"""You are a compassionate mindful wellness coach.

User's Question: {user_query}

Here is relevant wisdom from the MindfulLiving knowledge base:
{context}

Generate a personalized coaching response using this structure:

1. **Empathy** (2 sentences): Acknowledge their struggle without judgment
2. **Mindful Perspective** (3 sentences): Frame this through wisdom/mindfulness lens
3. **Practical Steps** (3-4 actionable steps): Concrete things they can do today
4. **2-Minute Action Plan** (numbered steps with timings):
   - Step 1 (duration): specific action
   - Step 2 (duration): specific action
   - Step 3 (duration): specific action
5. **Related Practices**: Suggest 3 wellness practices (breathing, meditation, grounding, etc.)
6. **Safety Notes**: Any important warnings or escalation points

Keep response compassionate, grounded in the wisdom above, actionable, and under 400 words.

Start response now:"""

    return prompt

# ============================================================================
# LLM GENERATION (Using Ollama)
# ============================================================================

def generate_coaching_with_ollama(prompt: str, timeout: int = 300) -> Optional[str]:
    """
    Generate coaching response using Ollama

    NOTE: Fallback to template if Ollama unavailable
    """
    logger.info(f"🤖 Generating response with {MODEL_NAME}...")

    try:
        response = requests.post(
            f"{OLLAMA_HOST}/api/generate",
            json={
                "model": MODEL_NAME,
                "prompt": prompt,
                "stream": False,
                "temperature": 0.7,
                "top_p": 0.9,
            },
            timeout=timeout
        )
        response.raise_for_status()
        return response.json()["response"].strip()

    except requests.exceptions.Timeout:
        logger.error(f"❌ Ollama timeout after {timeout}s")
        return None
    except requests.exceptions.ConnectionError:
        logger.error("❌ Ollama not running. Using template fallback.")
        return None
    except Exception as e:
        logger.error(f"❌ LLM generation error: {e}")
        return None

def generate_coaching_template_fallback(user_query: str, scenarios: List[Dict]) -> str:
    """
    Fallback template-based response if Ollama unavailable
    Ensures "Talk to Me" works even offline
    """
    logger.info("📝 Using template-based fallback response")

    if not scenarios:
        return {
            "empathy": "I understand you're facing a challenge.",
            "mindfulPerspective": "Remember that all challenges are opportunities for growth.",
            "practicalSteps": [
                "Take 3 deep breaths",
                "Reflect on what you can control",
                "Reach out for support if needed"
            ],
            "actionPlan": [
                {"step": "Take 3-4 minute breaths", "duration": 2},
                {"step": "Journal about the situation", "duration": 5},
                {"step": "Reach out to a trusted person", "duration": 5}
            ],
            "relatedPractices": ["breathing_box", "meditation_5min", "grounding"],
            "warnings": ["This is not professional advice. Seek help if needed."]
        }

    # Extract key insights from retrieved scenarios
    all_insights = []
    for s in scenarios:
        all_insights.extend(s.get('keyInsights', [])[:2])

    return {
        "empathy": f"I hear you about '{user_query.lower()}'. That's a real challenge many people face.",
        "mindfulPerspective": f"Our app's wisdom on this topic emphasizes: {all_insights[0] if all_insights else 'self-compassion and patience'}.",
        "practicalSteps": all_insights[:3] if all_insights else ["Reflect", "Seek support", "Practice daily"],
        "actionPlan": [
            {"step": "Pause and observe without judgment", "duration": 2},
            {"step": "Practice grounding: notice 5 things you see", "duration": 3},
            {"step": "Take one small action today", "duration": 5}
        ],
        "relatedPractices": ["breathing_box", "grounding_5_4_3_2_1", "self_compassion"],
        "warnings": ["This guidance is supportive, not professional medical advice"]
    }

# ============================================================================
# RESPONSE PARSING & STRUCTURING
# ============================================================================

def parse_coaching_response(raw_response: str, query: str, scenarios: List[Dict]) -> Dict:
    """
    Parse LLM response into structured JSON

    Returns data contract format for iOS/Android UI
    """
    return {
        "query": query,
        "response": raw_response,
        "retrievedScenarios": [
            {"id": s['id'], "title": s['title'], "similarity": s['similarity']}
            for s in scenarios
        ],
        "actionPlan": [
            {"step": "Pause and breathe", "duration": 2},
            {"step": "Journal or reflect", "duration": 5},
            {"step": "Take one action", "duration": 5}
        ],
        "relatedPractices": ["breathing_box", "meditation", "grounding"],
        "generatedAt": datetime.now().isoformat(),
        "modelVersion": MODEL_NAME,
        "warningLevel": "info"  # info, warning, critical
    }

# ============================================================================
# MAIN CLOUD FUNCTION
# ============================================================================

def talk_to_me(request):
    """
    Main Cloud Function endpoint for 'Talk to Me'

    Request JSON:
    {
      "query": "I'm struggling with work anxiety",
      "userId": "user123"  # optional, for logging
    }

    Response JSON:
    {
      "query": "...",
      "response": "compassionate coaching text",
      "actionPlan": [{step, duration}, ...],
      "relatedPractices": ["breathing_box", ...],
      "retrievedScenarios": [{id, title, similarity}, ...],
      "generatedAt": "ISO timestamp",
      "success": true
    }
    """

    start_time = time.time()
    logger.info("=" * 70)
    logger.info("🎯 TALK TO ME - RAG Coaching Request")
    logger.info("=" * 70)

    try:
        # Parse request
        request_json = request.get_json()
        user_query = request_json.get('query', '')
        user_id = request_json.get('userId', 'anonymous')

        if not user_query:
            return {"error": "Missing 'query' parameter"}, 400

        logger.info(f"User: {user_id}")
        logger.info(f"Query: {user_query}")

        # Step 1: Retrieve relevant scenarios
        retrieved_scenarios = retrieve_scenarios(user_query, top_k=3)

        # Step 2: Build RAG prompt
        rag_prompt = build_rag_prompt(user_query, retrieved_scenarios)

        # Step 3: Generate response
        coaching_response = generate_coaching_with_ollama(rag_prompt)

        # Fallback to template if LLM fails
        if not coaching_response:
            logger.info("⚠️  Using template fallback")
            coaching_response_json = generate_coaching_template_fallback(user_query, retrieved_scenarios)
        else:
            # Parse LLM response
            coaching_response_json = parse_coaching_response(
                coaching_response,
                user_query,
                retrieved_scenarios
            )

        # Step 4: Return structured response
        elapsed = time.time() - start_time

        response_data = {
            "success": True,
            "query": user_query,
            "response": coaching_response or "Using cached response",
            "retrievedScenarios": [
                {
                    "id": s['id'],
                    "title": s['title'],
                    "similarity": s['similarity']
                }
                for s in retrieved_scenarios
            ],
            "actionPlan": coaching_response_json.get("actionPlan", []),
            "relatedPractices": coaching_response_json.get("relatedPractices", []),
            "generatedAt": datetime.now().isoformat(),
            "modelVersion": MODEL_NAME,
            "latencySeconds": elapsed,
            "offline": coaching_response is None  # True if template fallback used
        }

        logger.info(f"✅ Response generated in {elapsed:.2f}s")
        logger.info("=" * 70)

        return response_data, 200

    except Exception as e:
        logger.error(f"❌ Error: {e}", exc_info=True)
        return {
            "success": False,
            "error": str(e),
            "offline": True
        }, 500

# ============================================================================
# LOCAL TESTING
# ============================================================================

if __name__ == "__main__":
    """Test locally"""
    from flask import Flask, request as flask_request

    app = Flask(__name__)

    @app.route('/talk-to-me', methods=['POST'])
    def handler():
        return talk_to_me(flask_request)

    logger.info("🚀 Starting local Talk to Me server on http://localhost:5000")
    logger.info("Test: curl -X POST http://localhost:5000/talk-to-me \\")
    logger.info("      -H 'Content-Type: application/json' \\")
    logger.info("      -d '{\"query\": \"I struggle with anxiety\"}'")
    app.run(debug=True, port=5000)
