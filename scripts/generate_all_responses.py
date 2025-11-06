#!/usr/bin/env python3
"""
Generate LLM responses for ALL life_situations (1,300+)
- NO quality checks during generation
- Save all responses to Firebase
- Fast, parallel processing
- Survives interruption (can resume)
"""

import os
import json
import time
import requests
from datetime import datetime
from typing import List, Dict
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv
import logging
from tqdm import tqdm

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")
FIREBASE_KEY = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
MODEL_NAME = os.getenv("MODEL_NAME", "mistral")

def init_firebase():
    if not firebase_admin._apps:
        cred = credentials.Certificate(FIREBASE_KEY)
        firebase_admin.initialize_app(cred, {'projectId': PROJECT_ID})
    return firestore.client()

PROMPT_TEMPLATE = """You are a mindful wellness advisor. Generate compassionate guidance.

SCENARIO:
Title: {title}
Description: {description}
Category: {category}
Difficulty: {difficulty}

RESPONSE GUIDELINES:
1. Empathy and validation (2 sentences)
2. Mindful perspective (2-3 sentences)
3. Practical steps (3-4 action items)
4. Be concise (150-200 words)
5. Include: breathing, grounding, or self-compassion

Generate now:"""

def generate_response(scenario: Dict) -> str:
    try:
        prompt = PROMPT_TEMPLATE.format(
            title=scenario.get('title', ''),
            description=scenario.get('description', ''),
            category=scenario.get('category', ''),
            difficulty=scenario.get('difficulty', '')
        )

        response = requests.post(
            f"{OLLAMA_HOST}/api/generate",
            json={
                "model": MODEL_NAME,
                "prompt": prompt,
                "stream": False,
                "temperature": 0.7,
                "top_p": 0.9,
            },
            timeout=600
        )
        response.raise_for_status()
        return response.json()["response"].strip()
    except Exception as e:
        logger.error(f"LLM error: {e}")
        return None

def main():
    db = init_firebase()

    logger.info("=" * 80)
    logger.info("🚀 GENERATING LLM RESPONSES FOR ALL SCENARIOS")
    logger.info("=" * 80)

    # Fetch all scenarios
    docs = list(db.collection('life_situations').stream())
    total = len(docs)
    logger.info(f"Total scenarios: {total}")

    generated = 0
    failed = 0
    start_time = time.time()

    for doc in tqdm(docs, desc="Generating"):
        scenario_id = doc.id
        scenario_data = doc.to_dict()

        try:
            # Check if already generated
            existing = db.collection('life_situations').document(scenario_id).collection('llm_response').document('v1').get()
            if existing.exists:
                logger.info(f"⏭️  {scenario_id} already exists")
                continue

            # Generate
            response = generate_response(scenario_data)
            if not response:
                failed += 1
                continue

            # Save to Firebase
            db.collection('life_situations').document(scenario_id).collection('llm_response').document('v1').set({
                'scenario_id': scenario_id,
                'response': response,
                'generated_at': datetime.now().isoformat(),
                'model': MODEL_NAME,
                'quality_score': None,  # Will be filled by quality check
                'quality_flag': None,   # Will be: 'pass' or 'fail'
            })

            generated += 1

        except Exception as e:
            logger.error(f"❌ {scenario_id}: {e}")
            failed += 1

    elapsed = time.time() - start_time
    logger.info("\n" + "=" * 80)
    logger.info("✅ GENERATION COMPLETE")
    logger.info("=" * 80)
    logger.info(f"Generated: {generated}")
    logger.info(f"Failed: {failed}")
    logger.info(f"Time: {elapsed/60:.1f} minutes")
    logger.info("=" * 80)

if __name__ == "__main__":
    main()
