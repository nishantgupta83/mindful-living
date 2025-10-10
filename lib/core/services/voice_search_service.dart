import 'dart:math';
import '../../shared/models/life_situation.dart';

class VoiceSearchResult {
  final LifeSituation situation;
  final double confidence;
  final String matchedTerms;

  VoiceSearchResult({
    required this.situation,
    required this.confidence,
    required this.matchedTerms,
  });
}

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  // Cache for search results to improve performance
  final Map<String, List<VoiceSearchResult>> _searchCache = {};
  
  // Common stop words to ignore in voice queries
  static const List<String> _stopWords = [
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
    'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
    'to', 'was', 'were', 'will', 'with', 'the', 'i', 'me', 'my', 'we',
    'our', 'you', 'your', 'what', 'how', 'when', 'where', 'why', 'should',
    'can', 'could', 'would', 'about', 'help', 'advice', 'guidance'
  ];

  // Synonym mappings for better voice recognition
  static const Map<String, List<String>> _synonymMappings = {
    'child': ['kid', 'toddler', 'baby', 'children', 'son', 'daughter'],
    'work': ['job', 'career', 'office', 'workplace', 'boss', 'manager', 'colleague'],
    'stress': ['pressure', 'anxiety', 'worry', 'tension', 'overwhelmed'],
    'angry': ['mad', 'furious', 'upset', 'irritated', 'frustrated'],
    'sad': ['depressed', 'down', 'blue', 'unhappy', 'melancholy'],
    'relationship': ['partner', 'spouse', 'husband', 'wife', 'boyfriend', 'girlfriend'],
    'money': ['financial', 'budget', 'debt', 'income', 'salary', 'bills'],
    'health': ['medical', 'doctor', 'illness', 'sick', 'wellness', 'fitness'],
    'family': ['relatives', 'parents', 'siblings', 'mother', 'father', 'mom', 'dad'],
    'school': ['education', 'student', 'teacher', 'homework', 'exam', 'college'],
    'sleep': ['tired', 'insomnia', 'rest', 'bedtime', 'exhausted'],
    'eating': ['food', 'diet', 'meal', 'nutrition', 'hunger', 'appetite'],
  };

  /// Main search method for voice queries
  Future<List<VoiceSearchResult>> searchSituations(
    String query, 
    List<LifeSituation> situations, {
    int maxResults = 5,
    double minConfidence = 0.1,
  }) async {
    // Check cache first
    final cacheKey = query.toLowerCase().trim();
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!.take(maxResults).toList();
    }

    // Clean and process the query
    final cleanedQuery = _cleanQuery(query);
    final expandedQuery = _expandQueryWithSynonyms(cleanedQuery);
    
    // Score all situations
    List<VoiceSearchResult> results = [];
    
    for (final situation in situations) {
      final confidence = _calculateConfidence(expandedQuery, situation);
      
      if (confidence >= minConfidence) {
        final matchedTerms = _getMatchedTerms(expandedQuery, situation);
        results.add(VoiceSearchResult(
          situation: situation,
          confidence: confidence,
          matchedTerms: matchedTerms,
        ));
      }
    }

    // Sort by confidence score
    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    // Cache results
    _searchCache[cacheKey] = results;
    
    return results.take(maxResults).toList();
  }

  /// Clean the voice query by removing stop words and normalizing
  String _cleanQuery(String query) {
    return query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .split(' ')
        .where((word) => word.isNotEmpty && !_stopWords.contains(word))
        .join(' ')
        .trim();
  }

  /// Expand query with synonyms for better matching
  List<String> _expandQueryWithSynonyms(String query) {
    final words = query.split(' ');
    final expandedWords = <String>[];
    
    for (final word in words) {
      expandedWords.add(word);
      
      // Add synonyms if available
      for (final entry in _synonymMappings.entries) {
        if (entry.value.contains(word) || entry.key == word) {
          expandedWords.addAll([entry.key, ...entry.value]);
        }
      }
    }
    
    return expandedWords.toSet().toList(); // Remove duplicates
  }

  /// Calculate confidence score for a situation against the query
  double _calculateConfidence(List<String> queryWords, LifeSituation situation) {
    double score = 0.0;
    final searchableTerms = situation.allSearchableTerms;
    
    for (final word in queryWords) {
      // Exact matches in voice keywords (highest weight)
      if (situation.voiceKeywords.any((k) => k.toLowerCase() == word)) {
        score += 5.0;
      }
      // Partial matches in voice keywords
      else if (situation.voiceKeywords.any((k) => k.toLowerCase().contains(word))) {
        score += 4.0;
      }
      // Exact matches in synonyms
      else if (situation.synonyms.any((s) => s.toLowerCase() == word)) {
        score += 4.0;
      }
      // Exact matches in title
      else if (situation.title.toLowerCase().contains(word)) {
        score += 3.0;
      }
      // Matches in tags
      else if (situation.tags.any((t) => t.toLowerCase().contains(word))) {
        score += 2.5;
      }
      // Matches in life area or wellness focus
      else if (situation.lifeArea.toLowerCase().contains(word) ||
               situation.wellnessFocus.toLowerCase().contains(word)) {
        score += 2.0;
      }
      // Fuzzy matches in description
      else if (situation.description.toLowerCase().contains(word)) {
        score += 1.5;
      }
      // Any other searchable terms
      else if (searchableTerms.any((term) => term.contains(word))) {
        score += 1.0;
      }
    }
    
    // Apply popularity bonus (situations used more often rank higher)
    final popularityBonus = situation.voicePopularity * 0.1;
    
    // Apply voice optimization bonus
    final voiceOptimizationBonus = situation.isVoiceOptimized ? 1.0 : 0.0;
    
    // Normalize by query length to prevent bias towards longer queries
    final normalizedScore = score / max(queryWords.length, 1);
    
    return (normalizedScore + popularityBonus + voiceOptimizationBonus).clamp(0.0, 10.0);
  }

  /// Get the terms that matched for explaining the result
  String _getMatchedTerms(List<String> queryWords, LifeSituation situation) {
    final matches = <String>[];
    
    for (final word in queryWords) {
      if (situation.voiceKeywords.any((k) => k.toLowerCase().contains(word))) {
        matches.add(word);
      } else if (situation.title.toLowerCase().contains(word)) {
        matches.add(word);
      } else if (situation.tags.any((t) => t.toLowerCase().contains(word))) {
        matches.add(word);
      }
    }
    
    return matches.take(3).join(', ');
  }

  /// Clear search cache (useful for testing or memory management)
  void clearCache() {
    _searchCache.clear();
  }

  /// Get popular voice queries for analytics
  Map<String, int> getPopularQueries() {
    final queryPopularity = <String, int>{};
    for (final key in _searchCache.keys) {
      queryPopularity[key] = (queryPopularity[key] ?? 0) + 1;
    }
    return queryPopularity;
  }

  /// Preprocess situations for better voice search performance
  List<LifeSituation> optimizeForVoice(List<LifeSituation> situations) {
    return situations.map((situation) {
      if (situation.isVoiceOptimized) {
        return situation; // Already optimized
      }
      
      // Generate voice keywords from title and description
      final autoKeywords = _extractKeywords(
        '${situation.title} ${situation.description}',
      );
      
      // Generate synonyms from existing tags
      final autoSynonyms = _generateSynonyms(situation.tags);
      
      // Create voice-friendly spoken title
      final spokenTitle = _makeSpokenFriendly(situation.title);
      
      return situation.copyWithVoiceOptimization(
        voiceKeywords: [...situation.voiceKeywords, ...autoKeywords],
        synonyms: [...situation.synonyms, ...autoSynonyms],
        spokenTitle: spokenTitle,
        isVoiceOptimized: true,
      );
    }).toList();
  }

  /// Extract keywords from text for voice search
  List<String> _extractKeywords(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .split(' ')
        .where((word) => word.length > 3 && !_stopWords.contains(word))
        .toSet()
        .toList();
    
    return words.take(10).toList(); // Limit to top 10 keywords
  }

  /// Generate synonyms for tags using the synonym mappings
  List<String> _generateSynonyms(List<String> tags) {
    final synonyms = <String>[];
    
    for (final tag in tags) {
      final lowercaseTag = tag.toLowerCase();
      for (final entry in _synonymMappings.entries) {
        if (entry.key == lowercaseTag || entry.value.contains(lowercaseTag)) {
          synonyms.addAll([entry.key, ...entry.value]);
        }
      }
    }
    
    return synonyms.toSet().toList(); // Remove duplicates
  }

  /// Make text more voice-friendly
  String _makeSpokenFriendly(String text) {
    return text
        .replaceAll('&', 'and')
        .replaceAll('@', 'at')
        .replaceAll('%', 'percent')
        .replaceAll('\$', 'dollar')
        .replaceAllMapped(RegExp(r'\b\d+\b'), (match) {
          // Convert numbers to words for better TTS
          final number = int.tryParse(match.group(0)!);
          if (number != null && number <= 20) {
            const numbers = [
              'zero', 'one', 'two', 'three', 'four', 'five',
              'six', 'seven', 'eight', 'nine', 'ten',
              'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
              'sixteen', 'seventeen', 'eighteen', 'nineteen', 'twenty'
            ];
            return numbers[number];
          }
          return match.group(0)!;
        });
  }
}