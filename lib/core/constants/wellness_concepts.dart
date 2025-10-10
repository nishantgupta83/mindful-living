/// Wellness Concept Mapping for Semantic Search Query Expansion
/// Based on research from mental health ontologies, mindfulness literature,
/// and wellness domain expertise
class WellnessConcepts {
  WellnessConcepts._();

  /// Core wellness concept map with semantic relationships
  static const Map<String, Set<String>> conceptMap = {
    // Stress & Anxiety
    'stress': {'pressure', 'tension', 'overwhelm', 'burnout', 'strain', 'worry'},
    'anxiety': {'worry', 'fear', 'nervous', 'apprehension', 'unease', 'stress', 'anxious'},
    'panic': {'anxiety', 'fear', 'overwhelm', 'crisis', 'intense'},
    'overwhelm': {'stress', 'too much', 'burden', 'overload'},
    'burnout': {'exhaustion', 'fatigue', 'stress', 'depletion'},
    
    // Depression & Sadness
    'depression': {'sadness', 'hopeless', 'empty', 'numb', 'despair', 'low'},
    'grief': {'loss', 'sadness', 'mourning', 'sorrow', 'bereavement'},
    'sadness': {'unhappy', 'down', 'blue', 'melancholy', 'sorrow'},
    'lonely': {'isolation', 'alone', 'loneliness', 'disconnected'},
    
    // Positive States
    'happiness': {'joy', 'contentment', 'gratitude', 'peace', 'satisfaction', 'happy'},
    'calm': {'peace', 'tranquility', 'serenity', 'stillness', 'quiet', 'peaceful'},
    'confidence': {'self-esteem', 'assurance', 'courage', 'strength', 'self-assured'},
    'gratitude': {'thankful', 'appreciation', 'grateful', 'blessing'},
    'joy': {'happiness', 'delight', 'pleasure', 'cheerful'},
    'peace': {'calm', 'tranquil', 'serene', 'harmony'},
    
    // Relationships
    'conflict': {'argument', 'disagreement', 'tension', 'dispute', 'fight'},
    'loneliness': {'isolation', 'alone', 'disconnection', 'solitude', 'lonely'},
    'connection': {'relationship', 'bond', 'intimacy', 'belonging', 'connect'},
    'communication': {'talking', 'conversation', 'dialogue', 'expressing'},
    'love': {'affection', 'caring', 'compassion', 'devotion'},
    'family': {'parents', 'children', 'relatives', 'household', 'spouse'},
    
    // Mindfulness Practices
    'meditation': {'mindfulness', 'contemplation', 'awareness', 'presence', 'meditate'},
    'breathing': {'pranayama', 'breathwork', 'respiration', 'breath'},
    'mindfulness': {'awareness', 'presence', 'consciousness', 'meditation', 'mindful'},
    'yoga': {'asana', 'movement', 'posture', 'practice'},
    'awareness': {'consciousness', 'attention', 'mindfulness', 'presence'},
    
    // Life Areas
    'work': {'career', 'job', 'employment', 'profession', 'vocation', 'workplace'},
    'career': {'work', 'job', 'professional', 'occupation'},
    'health': {'wellness', 'fitness', 'well-being', 'vitality', 'healthy'},
    'finance': {'money', 'financial', 'budget', 'income', 'wealth'},
    'growth': {'development', 'progress', 'improvement', 'learning'},
    
    // Emotions & States
    'anger': {'rage', 'fury', 'irritation', 'frustration', 'annoyed', 'angry'},
    'fear': {'afraid', 'scared', 'anxiety', 'worry', 'terror'},
    'shame': {'guilt', 'embarrassment', 'regret', 'remorse'},
    'tired': {'fatigue', 'exhaustion', 'weary', 'drained'},
    'energetic': {'energy', 'vitality', 'vigor', 'lively'},
    
    // Challenges
    'difficult': {'hard', 'challenging', 'tough', 'struggle'},
    'problem': {'issue', 'challenge', 'difficulty', 'trouble'},
    'crisis': {'emergency', 'critical', 'urgent', 'severe'},
    'change': {'transition', 'transformation', 'shift', 'adjustment'},
    
    // Wellness Actions
    'healing': {'recovery', 'restoration', 'wellness', 'recuperation'},
    'balance': {'equilibrium', 'harmony', 'stability'},
    'rest': {'sleep', 'relaxation', 'repose', 'recovery'},
    'exercise': {'movement', 'activity', 'fitness', 'workout'},
  };

  /// Expands a search query with semantically related wellness concepts
  static Set<String> expandQuery(String query) {
    final tokens = _tokenize(query.toLowerCase());
    final expanded = <String>{};
    
    for (final token in tokens) {
      // Always include original term
      expanded.add(token);
      
      // Add related concepts if mapping exists
      if (conceptMap.containsKey(token)) {
        expanded.addAll(conceptMap[token]!);
      }
    }
    
    return expanded;
  }

  /// Tokenize query into searchable terms
  static List<String> _tokenize(String text) {
    return text
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty && word.length > 2)
        .toList();
  }

  /// Get all related concepts for a single term
  static Set<String> getRelatedConcepts(String term) {
    final normalized = term.toLowerCase().trim();
    return conceptMap[normalized] ?? {};
  }

  /// Check if two terms are semantically related
  static bool areRelated(String term1, String term2) {
    final t1 = term1.toLowerCase().trim();
    final t2 = term2.toLowerCase().trim();
    
    if (t1 == t2) return true;
    
    final t1Concepts = conceptMap[t1] ?? {};
    final t2Concepts = conceptMap[t2] ?? {};
    
    return t1Concepts.contains(t2) || 
           t2Concepts.contains(t1) ||
           t1Concepts.intersection(t2Concepts).isNotEmpty;
  }

  /// Calculate semantic similarity between two terms (0.0 - 1.0)
  static double semanticSimilarity(String term1, String term2) {
    final t1 = term1.toLowerCase().trim();
    final t2 = term2.toLowerCase().trim();
    
    if (t1 == t2) return 1.0;
    
    final t1Concepts = conceptMap[t1] ?? {};
    final t2Concepts = conceptMap[t2] ?? {};
    
    // Direct relationship
    if (t1Concepts.contains(t2) || t2Concepts.contains(t1)) {
      return 0.8;
    }
    
    // Shared concepts (Jaccard similarity)
    if (t1Concepts.isNotEmpty && t2Concepts.isNotEmpty) {
      final intersection = t1Concepts.intersection(t2Concepts);
      final union = t1Concepts.union(t2Concepts);
      
      if (union.isNotEmpty) {
        return 0.5 + (0.3 * intersection.length / union.length);
      }
    }
    
    return 0.0;
  }
}
