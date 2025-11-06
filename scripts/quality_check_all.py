#!/usr/bin/env python3
"""
Quality check ALL generated responses
- Runs AFTER generation completes
- Scores each response (0-100%)
- Flags responses <70% (doesn't delete)
- Updates Firebase with quality_score and quality_flag
"""

import os
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

FIREBASE_KEY = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")
QUALITY_THRESHOLD = 0.70

def init_firebase():
    if not firebase_admin._apps:
        cred = credentials.Certificate(FIREBASE_KEY)
        firebase_admin.initialize_app(cred, {'projectId': PROJECT_ID})
    return firestore.client()

def calculate_quality_score(scenario: Dict, response: str) -> tuple:
    """Score response 0-100%"""
    response_lower = response.lower()

    # Keyword matching (40%)
    keywords = set()
    keywords.update(scenario.get('title', '').lower().split())
    keywords.update(scenario.get('description', '').lower().split())
    keywords = [k for k in keywords if len(k) > 3]
    matched = [k for k in keywords if k in response_lower]
    keyword_score = len(matched) / max(len(keywords), 1)

    # Tag matching (30%)
    tags = scenario.get('tags', [])
    matched_tags = [t for t in tags if t.lower() in response_lower]
    tag_score = len(matched_tags) / max(len(tags), 1)

    # Length (15%)
    word_count = len(response.split())
    length_score = min(word_count / 100, 1.0)

    # Wellness markers (15%)
    markers = ["mindful", "breath", "practice", "ground", "aware", "compassion", "technique"]
    wellness_count = sum(1 for m in markers if m in response_lower)
    wellness_score = min(wellness_count / 3, 1.0)

    score = (
        keyword_score * 0.40 +
        tag_score * 0.30 +
        length_score * 0.15 +
        wellness_score * 0.15
    )

    return score, matched, matched_tags

def main():
    db = init_firebase()

    logger.info("=" * 80)
    logger.info("🔍 QUALITY CHECK: ALL RESPONSES")
    logger.info("=" * 80)

    docs = list(db.collection('life_situations').stream())
    total = len(docs)

    passed = 0
    failed = 0
    no_response = 0

    for doc in tqdm(docs, desc="Quality checking"):
        scenario_id = doc.id
        scenario_data = doc.to_dict()

        try:
            # Get response
            response_doc = db.collection('life_situations').document(scenario_id).collection('llm_response').document('v1').get()
            if not response_doc.exists:
                no_response += 1
                continue

            response_data = response_doc.to_dict()
            response_text = response_data.get('response', '')

            # Score
            score, keywords, tags = calculate_quality_score(scenario_data, response_text)

            # Determine flag
            flag = 'pass' if score >= QUALITY_THRESHOLD else 'fail'

            # Update Firebase
            db.collection('life_situations').document(scenario_id).collection('llm_response').document('v1').update({
                'quality_score': float(score),
                'quality_flag': flag,
                'matched_keywords': keywords,
                'matched_tags': tags,
            })

            if score >= QUALITY_THRESHOLD:
                passed += 1
            else:
                failed += 1

        except Exception as e:
            logger.error(f"❌ {scenario_id}: {e}")

    logger.info("\n" + "=" * 80)
    logger.info("✅ QUALITY CHECK COMPLETE")
    logger.info("=" * 80)
    logger.info(f"Passed (≥70%): {passed}")
    logger.info(f"Failed (<70%): {failed} [FLAGGED, NOT DELETED]")
    logger.info(f"No response: {no_response}")
    logger.info(f"Pass rate: {passed/max(passed+failed, 1):.1%}")
    logger.info("=" * 80)

if __name__ == "__main__":
    main()
