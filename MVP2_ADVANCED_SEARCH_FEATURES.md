# MVP2: Advanced Search & AI Features
## Mindful Living App - Future Enhancements

**Status:** Research Complete, Implementation Deferred  
**Timeline:** Q2 2026 (Post-Launch)  
**Priority:** Medium-High  

---

## 🎯 Overview

This document outlines advanced search and AI features deferred to MVP2 based on comprehensive research of:
- GitaWisdom2's advanced search implementations
- Industry-standard hybrid search algorithms (Azure AI, Google Cloud, Elastic)
- Latest NLP and affective computing research (2023-2025)
- Mental health app best practices

---

## 📦 Phase 2: Advanced Features

### 1. **TensorFlow Lite Semantic Search** 🤖

**Research Findings:**
- TensorFlow Lite sentence encoder generates vector embeddings
- Cosine similarity enables deep semantic matching (0.3 threshold optimal)
- Hardware acceleration via XNNPack (Android) and GPU delegate (iOS)
- Caches embeddings for performance

**Implementation Details:**
```dart
// lib/core/services/semantic_search_service.dart
class SemanticSearchService {
  late Interpreter _interpreter;
  
  Future<void> initialize() async {
    final model = await loadModel('universal_sentence_encoder.tflite');
    _interpreter = Interpreter.fromAsset(model, options: InterpreterOptions()
      ..threads = 4
      ..useXNNPACK = true  // Android acceleration
      ..addDelegate(GpuDelegateV2())  // iOS acceleration
    );
  }
  
  List<double> generateEmbedding(String text) {
    // Tokenize (max 64 tokens)
    // Run inference
    // Normalize vector
    // Return embedding
  }
  
  double cosineSimilarity(List<double> a, List<double> b) {
    // Calculate cosine similarity between embeddings
  }
}
```

**Dependencies:**
```yaml
dependencies:
  tflite_flutter: ^0.10.0
  tflite_flutter_helper: ^0.3.1
```

**Benefits:**
- True semantic understanding beyond keyword matching
- Handles synonyms and related concepts automatically
- 85-90% accuracy in finding contextually relevant results

**Challenges:**
- Large model file (25-50MB)
- Initial loading time (~500ms)
- Requires pre-processing all situations (one-time cost)

**Estimated Effort:** 40-60 hours

---

### 2. **Emotional Context Detection** 🎭

**Research Summary:**
Based on 2023 research in affective computing and mental health NLP, emotional context detection identifies the user's emotional state from search queries to provide more empathetic, relevant results.

**Key Techniques:**

#### A. Sentiment Analysis
- **Polarity Detection**: Positive (+1), Neutral (0), Negative (-1)
- **Intensity Scoring**: Scale of 0-1 for emotion strength
- **Multi-dimensional**: Detect valence (positive/negative) and arousal (calm/excited)

#### B. Emotion Classification
Using the **Plutchik's Wheel** model:
- **Primary Emotions**: Joy, Trust, Fear, Surprise, Sadness, Disgust, Anger, Anticipation
- **Secondary Emotions**: Combinations (e.g., Joy + Trust = Love)

#### C. Mental Health Indicators
- **Stress markers**: "overwhelmed", "can't cope", "too much"
- **Anxiety markers**: "worried", "nervous", "afraid"
- **Depression markers**: "hopeless", "empty", "worthless"

**Implementation Approach:**

```dart
// lib/core/services/emotional_context_service.dart
class EmotionalContextService {
  // Emotion lexicons
  final Map<String, EmotionScore> _emotionLexicon = {
    'anxious': EmotionScore(emotion: Emotion.fear, intensity: 0.8),
    'stressed': EmotionScore(emotion: Emotion.fear, intensity: 0.7),
    'overwhelmed': EmotionScore(emotion: Emotion.sadness, intensity: 0.9),
    'hopeful': EmotionScore(emotion: Emotion.anticipation, intensity: 0.7),
    'grateful': EmotionScore(emotion: Emotion.joy, intensity: 0.8),
    // ... 500+ emotion keywords
  };
  
  EmotionalContext detectEmotion(String query) {
    final tokens = tokenize(query);
    final emotions = <Emotion, double>{};
    
    for (final token in tokens) {
      if (_emotionLexicon.containsKey(token)) {
        final score = _emotionLexicon[token]!;
        emotions[score.emotion] = 
          (emotions[score.emotion] ?? 0) + score.intensity;
      }
    }
    
    return EmotionalContext(
      primary: emotions.keys.first,
      intensity: emotions.values.first,
      secondary: emotions.keys.skip(1).take(2).toList(),
      sentiment: calculateSentiment(emotions),
    );
  }
  
  List<Map<String, dynamic>> enhanceResults(
    List<Map<String, dynamic>> results,
    EmotionalContext context,
  ) {
    // Boost results that match emotional context
    // Prioritize calming content for anxiety/stress
    // Prioritize uplifting content for sadness
    // Prioritize grounding content for overwhelm
  }
}
```

**Emotion-Aware Search Flow:**
1. User types: "I'm feeling really anxious about my job interview"
2. Detect emotions: Fear (0.8), Anxiety (0.9), Anticipation (0.5)
3. Search for "job interview" situations
4. Boost results tagged with: `calming`, `confidence`, `preparation`, `breathing`
5. Downrank results tagged with: `high-energy`, `excitement`

**Dataset Requirements:**
- Emotion lexicon (500+ words): Joy, Trust, Fear, Surprise, Sadness, Disgust, Anger, Anticipation
- Wellness-specific terms: mindfulness vocabulary, mental health indicators
- Context modifiers: intensifiers ("very", "extremely"), negations ("not", "never")

**Research Sources:**
- NRC Emotion Lexicon (14,000+ words with 8 emotions)
- VADER Sentiment Analysis (optimized for social media text)
- Transformer models: BERT for emotion classification
- Multi-task learning: Emotion + Sentiment + Intent

**Benefits:**
- More empathetic user experience
- Better situation matching for emotional needs
- Early mental health indicator detection
- Personalized content recommendations

**Challenges:**
- Context understanding (sarcasm, cultural nuances)
- Privacy concerns (storing emotional data)
- False positives in emotion detection
- Requires large emotion lexicon

**Estimated Effort:** 60-80 hours

---

### 3. **Reciprocal Rank Fusion (RRF)** 🔀

**Research Findings:**
Industry standard for combining multiple search result lists (keyword + semantic + emotional).

**Algorithm:**
```
For each document:
  RRF_score = Σ (1 / (rank_i + k))
  
Where:
  rank_i = position in result list i (0-based)
  k = constant (typically 60, experimentally optimal)
```

**Implementation:**
```dart
class HybridSearchService {
  List<SearchResult> fuseResults(
    List<SearchResult> keywordResults,
    List<SearchResult> semanticResults,
    List<SearchResult> emotionalResults,
  ) {
    final Map<String, double> rrfScores = {};
    const k = 60;
    
    // Process each result list
    for (int i = 0; i < keywordResults.length; i++) {
      final docId = keywordResults[i].id;
      rrfScores[docId] = (rrfScores[docId] ?? 0) + (1 / (i + k));
    }
    
    // Repeat for semantic and emotional results
    
    // Sort by RRF score (descending)
    final fusedResults = rrfScores.entries
      .map((e) => SearchResult(id: e.key, score: e.value))
      .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    
    return fusedResults;
  }
}
```

**Benefits:**
- Balances multiple ranking signals
- Reduces bias from any single algorithm
- Proven in production (Google, Azure, Elastic)

**Estimated Effort:** 20-30 hours

---

### 4. **BM25 Algorithm** 📊

**Research Findings:**
State-of-the-art keyword ranking algorithm, superior to TF-IDF.

**Formula:**
```
BM25(D, Q) = Σ IDF(qi) × (f(qi, D) × (k1 + 1)) / (f(qi, D) + k1 × (1 - b + b × (|D| / avgdl)))

Where:
  f(qi, D) = term frequency of qi in document D
  |D| = length of document D
  avgdl = average document length
  k1 = tuning parameter (typically 1.2-2.0)
  b = tuning parameter (typically 0.75)
```

**Why BM25 > TF-IDF:**
- Handles document length normalization better
- Diminishing returns for term frequency (prevents keyword stuffing)
- Industry standard (Elasticsearch, Solr, Lucene)

**Implementation:**
```dart
class BM25Scorer {
  double score(String query, String document) {
    const k1 = 1.5;
    const b = 0.75;
    final avgDocLength = _calculateAvgLength();
    final docLength = document.split(' ').length;
    
    // Calculate BM25 score
  }
}
```

**Estimated Effort:** 15-20 hours

---

### 5. **Advanced Caching with TTL** ⚡

**Research Findings:**
- **Stale-While-Revalidate**: Serve cached data, refresh in background
- **Time-Based Invalidation**: Monthly refresh optimal for wellness content
- **Write-Through**: Update cache on data changes
- **Cache-Aside**: Lazy loading pattern

**Implementation:**
```dart
class SearchCacheService {
  final Map<String, CachedSearchIndex> _cache = {};
  
  static const cacheDuration = Duration(days: 30);
  
  Future<SearchIndex> getIndex() async {
    final cached = _cache['main'];
    
    if (cached != null && !cached.isExpired) {
      // Stale-while-revalidate: return cached, refresh in background
      unawaited(_refreshInBackground());
      return cached.index;
    }
    
    // Cache miss or expired: fetch fresh
    return await _buildAndCacheIndex();
  }
  
  Future<void> _refreshInBackground() async {
    // Non-blocking refresh
  }
  
  bool isExpired(DateTime lastRefresh) {
    return DateTime.now().difference(lastRefresh) > cacheDuration;
  }
}
```

**Cache Strategy:**
- **Index**: 30-day TTL (situations change monthly)
- **Search Results**: 5-minute TTL (dynamic, user-specific)
- **Embeddings**: Permanent (recompute only on content change)

**Benefits:**
- 10-50x faster search after first load
- Reduced Firestore reads (cost savings)
- Offline search capability

**Estimated Effort:** 10-15 hours

---

### 6. **Wellness Concept Mapping** 🧠

**Research Findings:**
Mental health and wellness domains have rich semantic relationships that keyword matching misses.

**Concept Graph:**
```dart
final Map<String, Set<String>> wellnessConceptMap = {
  // Stress & Anxiety
  'stress': {'pressure', 'tension', 'overwhelm', 'burnout', 'strain'},
  'anxiety': {'worry', 'fear', 'nervous', 'apprehension', 'unease', 'stress'},
  'panic': {'anxiety', 'fear', 'overwhelm', 'crisis'},
  
  // Depression & Sadness
  'depression': {'sadness', 'hopeless', 'empty', 'numb', 'despair'},
  'grief': {'loss', 'sadness', 'mourning', 'sorrow'},
  
  // Positive States
  'happiness': {'joy', 'contentment', 'gratitude', 'peace', 'satisfaction'},
  'calm': {'peace', 'tranquility', 'serenity', 'stillness', 'quiet'},
  'confidence': {'self-esteem', 'assurance', 'courage', 'strength'},
  
  // Relationships
  'conflict': {'argument', 'disagreement', 'tension', 'dispute'},
  'loneliness': {'isolation', 'alone', 'disconnection', 'solitude'},
  'connection': {'relationship', 'bond', 'intimacy', 'belonging'},
  
  // Mindfulness Practices
  'meditation': {'mindfulness', 'contemplation', 'awareness', 'presence'},
  'breathing': {'pranayama', 'breathwork', 'respiration'},
  'yoga': {'asana', 'movement', 'posture', 'practice'},
  
  // Life Areas
  'work': {'career', 'job', 'employment', 'profession', 'vocation'},
  'family': {'parents', 'children', 'relatives', 'household'},
  'health': {'wellness', 'fitness', 'well-being', 'vitality'},
};
```

**Query Expansion:**
```dart
class ConceptExpansionService {
  Set<String> expandQuery(String query) {
    final tokens = tokenize(query);
    final expanded = <String>{};
    
    for (final token in tokens) {
      expanded.add(token);  // Original term
      
      if (wellnessConceptMap.containsKey(token)) {
        expanded.addAll(wellnessConceptMap[token]!);  // Related concepts
      }
    }
    
    return expanded;
  }
}

// Example:
// Query: "dealing with work stress"
// Expanded: "dealing with work stress pressure tension overwhelm burnout 
//            strain career job employment profession"
```

**Benefits:**
- Finds relevant situations user wouldn't discover with keywords alone
- Bridges vocabulary gap between user language and content language
- Improves recall (find more relevant results)

**Data Source:**
- Manually curated wellness taxonomy (500+ core concepts)
- WordNet integration for general synonyms
- Domain-specific ontologies (DSM-5, ICD-11 mental health terms)

**Estimated Effort:** 25-30 hours (including concept curation)

---

## 📊 Summary Table

| Feature | Effort (hrs) | Complexity | Impact | Priority |
|---------|-------------|------------|--------|----------|
| TensorFlow Lite Semantic Search | 40-60 | High | High | P1 |
| Emotional Context Detection | 60-80 | High | Very High | P1 |
| Reciprocal Rank Fusion (RRF) | 20-30 | Medium | High | P2 |
| BM25 Algorithm | 15-20 | Low | Medium | P3 |
| Advanced Caching with TTL | 10-15 | Low | Medium | P3 |
| Wellness Concept Mapping | 25-30 | Medium | High | P2 |

**Total Estimated Effort:** 170-235 hours (~4-6 weeks full-time)

---

## 🎯 Recommended Implementation Order

### Phase 2A (Month 1-2) - Foundation
1. **Advanced Caching** - Quick win, improves all search
2. **Wellness Concept Mapping** - Pure Dart, no ML dependencies
3. **BM25 Algorithm** - Better keyword ranking

### Phase 2B (Month 3-4) - Intelligence
4. **Emotional Context Detection** - High user value
5. **Reciprocal Rank Fusion** - Combines all signals

### Phase 2C (Month 5-6) - Advanced AI
6. **TensorFlow Lite Semantic Search** - Deep semantic understanding

---

## 🔬 Research References

### Hybrid Search
- Microsoft Azure: "Hybrid search in Azure AI Search" (2023)
- Google Cloud: "Combining semantic and keyword search with RRF" (2023)
- Elastic: "A Comprehensive Hybrid Search Guide" (2023)

### Emotional Context
- NIH: "A review on sentiment analysis and emotion detection from text" (2023)
- arXiv: "AI in Mental Health: Emotional and Sentiment Analysis of LLMs" (2024)
- IEEE: "Affective Computing: Recent Advances, Challenges, and Future Trends" (2023)

### NLP & ML
- NRC Emotion Lexicon Database
- VADER Sentiment Analysis Tool
- Universal Sentence Encoder (Google Research)

---

## ⚠️ Important Considerations

### Privacy & Ethics
- **Emotional Data**: Must obtain explicit consent before storing emotional indicators
- **Mental Health**: Not a replacement for professional help; include disclaimers
- **HIPAA Alignment**: If storing emotional data, review compliance requirements

### Performance
- **Model Size**: TF Lite model adds 25-50MB to app size
- **Battery Impact**: ML inference uses more power than keyword search
- **Network**: Consider offline capabilities with cached embeddings

### User Experience
- **Transparency**: Show users when AI/emotion detection is active
- **Control**: Allow users to disable emotional context detection
- **Feedback Loop**: Let users correct wrong emotion detections

---

**Document Version:** 1.0  
**Last Updated:** 2025-10-10  
**Next Review:** 2026-Q1 (Post-MVP1 Launch)  

---

*This document is part of the Mindful Living app development roadmap.*
