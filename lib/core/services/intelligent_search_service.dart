import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/wellness_concepts.dart';

/// Enhanced Intelligent Search Service with Phase 1 improvements
///
/// **MVP1 Features (Implemented):**
/// - TF-IDF (Term Frequency-Inverse Document Frequency) scoring
/// - Fuzzy matching for typos and partial matches
/// - Stop word removal
/// - Multi-field search (title, description, tags, category)
/// - Relevance ranking
/// - **Wellness Concept Mapping** - Semantic query expansion
/// - **Advanced Caching with TTL** - 30-day stale-while-revalidate
/// - **Hybrid Scoring** - 60% keyword + 40% semantic overlap
///
/// **MVP2 Features (Research Complete, Deferred):**
/// See MVP2_ADVANCED_SEARCH_FEATURES.md for:
/// - TensorFlow Lite semantic search
/// - Emotional context detection
/// - Reciprocal Rank Fusion (RRF)
/// - BM25 algorithm
///
/// Inspired by GitaWisdom2 + Azure AI + Google Cloud best practices
class IntelligentSearchService {
  // Singleton pattern
  static final IntelligentSearchService _instance = IntelligentSearchService._internal();
  factory IntelligentSearchService() => _instance;
  IntelligentSearchService._internal() {
    // Load cache timestamp on initialization
    _loadCacheTimestamp();
  }

  // Search index
  final Map<String, Map<String, double>> _invertedIndex = {};
  final Map<String, Map<String, dynamic>> _documents = {};
  int _documentCount = 0;
  bool _isIndexed = false;

  // Caching with TTL (stale-while-revalidate pattern)
  DateTime? _lastIndexRefresh;
  static const _cacheValidityDuration = Duration(days: 30);
  static const _cacheKeyLastRefresh = 'search_index_last_refresh';
  bool _isRefreshing = false;

  // Stop words (common words to ignore)
  static const Set<String> _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'by', 'for', 'from',
    'has', 'he', 'in', 'is', 'it', 'its', 'of', 'on', 'that', 'the',
    'to', 'was', 'will', 'with', 'i', 'me', 'my', 'we', 'you', 'your',
  };

  // Hybrid scoring weights (based on Azure AI/Google Cloud research)
  static const double _keywordWeight = 0.6;  // 60% keyword (TF-IDF)
  static const double _semanticWeight = 0.4;  // 40% semantic overlap

  /// Initialize and index all situations from Firestore
  /// Implements stale-while-revalidate caching pattern
  Future<void> indexSituations() async {
    if (_isIndexed && !_isCacheExpired()) {
      // Already indexed and cache is fresh
      _refreshInBackgroundIfNeeded(); // Stale-while-revalidate
      return;
    }

    print('🔍 Starting intelligent search indexing...');
    final stopwatch = Stopwatch()..start();

    try {
      // Fetch all active situations from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('life_situations')
          .where('isActive', isEqualTo: true)
          .get();

      _documentCount = querySnapshot.docs.length;
      print('📚 Indexing $_documentCount situations...');

      // Clear existing index
      _invertedIndex.clear();
      _documents.clear();

      // Build inverted index
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final docId = doc.id;

        // Store document
        _documents[docId] = data;

        // Extract text fields
        final title = data['title'] as String? ?? '';
        final description = data['description'] as String? ?? '';
        final mindfulApproach = data['mindfulApproach'] as String? ?? '';
        final practicalSteps = data['practicalSteps'] as String? ?? '';
        final lifeArea = data['lifeArea'] as String? ?? '';
        final tags = (data['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .join(' ') ?? '';

        // Combine all searchable text (with field weighting)
        final combinedText = '''
        $title $title $title
        $description $description
        $mindfulApproach
        $practicalSteps
        $lifeArea $lifeArea
        $tags $tags
        ''';

        // Tokenize and index
        final tokens = _tokenize(combinedText);
        final termFrequency = _calculateTermFrequency(tokens);

        // Add to inverted index
        for (var entry in termFrequency.entries) {
          final term = entry.key;
          final tf = entry.value;

          if (!_invertedIndex.containsKey(term)) {
            _invertedIndex[term] = {};
          }

          _invertedIndex[term]![docId] = tf;
        }
      }

      _isIndexed = true;
      _lastIndexRefresh = DateTime.now();

      // Persist cache timestamp
      await _saveCacheTimestamp();

      stopwatch.stop();
      print('✅ Search index built in ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Indexed ${_invertedIndex.length} unique terms');
    } catch (e) {
      print('❌ Error building search index: $e');
      _isIndexed = false;
    }
  }

  /// Check if cache has expired (30-day TTL)
  bool _isCacheExpired() {
    if (_lastIndexRefresh == null) return true;

    final now = DateTime.now();
    final age = now.difference(_lastIndexRefresh!);

    return age > _cacheValidityDuration;
  }

  /// Refresh index in background if approaching expiration (stale-while-revalidate)
  void _refreshInBackgroundIfNeeded() {
    if (_isRefreshing || _lastIndexRefresh == null) return;

    final now = DateTime.now();
    final age = now.difference(_lastIndexRefresh!);

    // Refresh in background if cache is > 25 days old (before 30-day expiration)
    if (age > const Duration(days: 25)) {
      _isRefreshing = true;

      // Non-blocking background refresh
      Future.microtask(() async {
        try {
          print('🔄 Background index refresh started...');
          _isIndexed = false; // Force re-index
          await indexSituations();
          print('✅ Background index refresh complete');
        } finally {
          _isRefreshing = false;
        }
      });
    }
  }

  /// Save cache timestamp to SharedPreferences
  Future<void> _saveCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKeyLastRefresh,
        _lastIndexRefresh?.toIso8601String() ?? '',
      );
      print('💾 Cache timestamp saved');
    } catch (e) {
      print('⚠️ Failed to save cache timestamp: $e');
    }
  }

  /// Load cache timestamp from SharedPreferences
  Future<void> _loadCacheTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_cacheKeyLastRefresh);

      if (timestamp != null && timestamp.isNotEmpty) {
        _lastIndexRefresh = DateTime.parse(timestamp);
        print('📅 Cache timestamp loaded: $_lastIndexRefresh');
      }
    } catch (e) {
      print('⚠️ Failed to load cache timestamp: $e');
    }
  }

  /// Search situations with intelligent ranking
  Future<List<Map<String, dynamic>>> search(String query, {int maxResults = 20}) async {
    if (!_isIndexed) {
      await indexSituations();
    }

    if (query.trim().isEmpty) {
      return [];
    }

    print('🔍 Searching for: "$query"');
    final stopwatch = Stopwatch()..start();

    // Tokenize query
    final queryTokens = _tokenize(query);

    if (queryTokens.isEmpty) {
      return [];
    }

    // PHASE 1: Wellness concept expansion for semantic query enhancement
    final expandedTerms = WellnessConcepts.expandQuery(query);
    print('🧠 Query expanded: ${queryTokens.length} → ${expandedTerms.length} terms');

    // Combine original tokens with expanded wellness concepts
    final allSearchTerms = {...queryTokens, ...expandedTerms};

    // Score all documents
    final scores = <String, double>{};

    for (var docId in _documents.keys) {
      double score = 0.0;
      double keywordScore = 0.0;
      double semanticScore = 0.0;

      // Calculate keyword score (original query terms with higher weight)
      for (var queryTerm in queryTokens) {
        // Exact match score
        if (_invertedIndex.containsKey(queryTerm) &&
            _invertedIndex[queryTerm]!.containsKey(docId)) {
          final tf = _invertedIndex[queryTerm]![docId]!;
          final idf = _calculateIDF(queryTerm);
          keywordScore += tf * idf * 2.0; // Boost exact matches
        }

        // Fuzzy match score (partial matches)
        for (var indexTerm in _invertedIndex.keys) {
          if (indexTerm.contains(queryTerm) || queryTerm.contains(indexTerm)) {
            if (indexTerm != queryTerm && // Don't double-count exact matches
                _invertedIndex[indexTerm]!.containsKey(docId)) {
              final tf = _invertedIndex[indexTerm]![docId]!;
              final idf = _calculateIDF(indexTerm);
              final similarity = _calculateStringSimilarity(queryTerm, indexTerm);
              keywordScore += tf * idf * similarity; // Partial match bonus
            }
          }
        }
      }

      // Calculate semantic score (expanded wellness concepts)
      final expandedOnlyTerms = allSearchTerms.difference(queryTokens.toSet());
      for (var expandedTerm in expandedOnlyTerms) {
        if (_invertedIndex.containsKey(expandedTerm) &&
            _invertedIndex[expandedTerm]!.containsKey(docId)) {
          final tf = _invertedIndex[expandedTerm]![docId]!;
          final idf = _calculateIDF(expandedTerm);
          semanticScore += tf * idf; // Semantic match from concept expansion
        }
      }

      // Hybrid scoring: 60% keyword + 40% semantic (Azure AI best practice)
      score = (keywordScore * _keywordWeight) + (semanticScore * _semanticWeight);

      if (score > 0) {
        scores[docId] = score;
      }
    }

    // Sort by score (descending)
    final rankedDocs = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Build result list with matched terms
    final results = rankedDocs.take(maxResults).map((entry) {
      final docId = entry.key;
      final score = entry.value;
      final doc = _documents[docId]!;

      // Find matched terms for highlighting
      final matchedTerms = <String>[];
      for (var queryTerm in queryTokens) {
        if (_invertedIndex.containsKey(queryTerm) &&
            _invertedIndex[queryTerm]!.containsKey(docId)) {
          matchedTerms.add(queryTerm);
        }
      }

      return {
        'id': docId,
        ...doc,
        'relevanceScore': score,
        'matchedTerms': matchedTerms,
      };
    }).toList();

    stopwatch.stop();
    print('✅ Found ${results.length} results in ${stopwatch.elapsedMilliseconds}ms');

    return results;
  }

  /// Tokenize text into searchable terms
  List<String> _tokenize(String text) {
    // Convert to lowercase
    final lowercaseText = text.toLowerCase();

    // Remove special characters and split by whitespace
    final words = lowercaseText
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    // Remove stop words and short words
    final filtered = words
        .where((word) => !_stopWords.contains(word) && word.length > 2)
        .toList();

    return filtered;
  }

  /// Calculate term frequency for a list of tokens
  Map<String, double> _calculateTermFrequency(List<String> tokens) {
    final frequency = <String, int>{};

    for (var token in tokens) {
      frequency[token] = (frequency[token] ?? 0) + 1;
    }

    // Normalize by total token count
    final totalTokens = tokens.length;
    final tf = <String, double>{};

    for (var entry in frequency.entries) {
      tf[entry.key] = entry.value / totalTokens;
    }

    return tf;
  }

  /// Calculate Inverse Document Frequency
  double _calculateIDF(String term) {
    if (!_invertedIndex.containsKey(term)) {
      return 0.0;
    }

    final documentsWithTerm = _invertedIndex[term]!.length;

    if (documentsWithTerm == 0) {
      return 0.0;
    }

    // IDF = log(total documents / documents containing term)
    return math.log(_documentCount / documentsWithTerm);
  }

  /// Calculate string similarity (for fuzzy matching)
  double _calculateStringSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;

    // Levenshtein distance-based similarity
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = math.max(s1.length, s2.length);

    if (maxLength == 0) return 1.0;

    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance (edit distance)
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }

    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;

        matrix[i][j] = [
          matrix[i - 1][j] + 1, // Deletion
          matrix[i][j - 1] + 1, // Insertion
          matrix[i - 1][j - 1] + cost, // Substitution
        ].reduce(math.min);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Suggest related search terms based on indexed terms
  List<String> suggestTerms(String partial, {int maxSuggestions = 5}) {
    if (!_isIndexed || partial.length < 2) {
      return [];
    }

    final partialLower = partial.toLowerCase();
    final suggestions = <String>[];

    for (var term in _invertedIndex.keys) {
      if (term.startsWith(partialLower) && term != partialLower) {
        suggestions.add(term);
      }
    }

    // Sort by frequency (document count)
    suggestions.sort((a, b) {
      final aCount = _invertedIndex[a]!.length;
      final bCount = _invertedIndex[b]!.length;
      return bCount.compareTo(aCount);
    });

    return suggestions.take(maxSuggestions).toList();
  }

  /// Get popular search terms
  List<String> getPopularTerms({int maxTerms = 10}) {
    if (!_isIndexed) {
      return [];
    }

    // Sort terms by document frequency
    final termFrequencies = _invertedIndex.entries.map((entry) {
      return MapEntry(entry.key, entry.value.length);
    }).toList();

    termFrequencies.sort((a, b) => b.value.compareTo(a.value));

    return termFrequencies
        .take(maxTerms)
        .map((e) => e.key)
        .toList();
  }

  /// Clear index (for re-indexing)
  void clearIndex() {
    _invertedIndex.clear();
    _documents.clear();
    _documentCount = 0;
    _isIndexed = false;
    print('🗑️ Search index cleared');
  }

  /// Get index statistics
  Map<String, dynamic> getIndexStats() {
    return {
      'isIndexed': _isIndexed,
      'documentCount': _documentCount,
      'uniqueTerms': _invertedIndex.length,
      'avgTermsPerDoc': _documentCount > 0
          ? (_invertedIndex.values.fold<int>(
                  0, (sum, docs) => sum + docs.length) /
              _documentCount)
          : 0,
    };
  }
}
