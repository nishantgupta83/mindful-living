import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

class OptimizedFirebaseService {
  static final OptimizedFirebaseService _instance = OptimizedFirebaseService._internal();
  factory OptimizedFirebaseService() => _instance;
  OptimizedFirebaseService._internal();

  // Pagination settings
  static const int _pageSize = 20;
  static const int _cacheMaxSize = 100;
  static const Duration _cacheTTL = Duration(minutes: 10);

  // Cache implementation
  final _dilemmaCache = LRUCache<String, Map<String, dynamic>>(_cacheMaxSize);
  final _pageCache = <int, List<Map<String, dynamic>>>{};
  final _cacheTimestamps = <String, DateTime>{};

  // Request deduplication
  final _pendingRequests = <String, Future>{};

  // Preloading management
  Timer? _preloadTimer;
  int _currentPage = 0;

  // Mock data - will be replaced with actual Firebase
  final List<Map<String, dynamic>> _allDilemmas = List.generate(1226, (index) {
    final categories = ['Career', 'Relationships', 'Finance', 'Mental Health', 'Family', 'Health'];
    final category = categories[index % categories.length];
    return {
      'id': 'dilemma_$index',
      'title': 'Life Situation ${index + 1}',
      'description': 'Description for situation ${index + 1}',
      'category': category,
      'mindfulApproach': 'Mindful approach for situation ${index + 1}',
      'practicalSteps': ['Step 1', 'Step 2', 'Step 3'],
      'wellnessFocus': 'Wellness focus ${index % 5 + 1}',
      'difficulty': ['Low', 'Medium', 'High'][index % 3],
      'views': (index + 1) * 10,
    };
  });

  // Get paginated dilemmas with caching
  Future<List<Map<String, dynamic>>> getDilemmasPaginated({
    int page = 0,
    int pageSize = _pageSize,
    String? category,
  }) async {
    final cacheKey = 'page_${page}_${category ?? 'all'}';

    // Check if request is already pending (deduplication)
    if (_pendingRequests.containsKey(cacheKey)) {
      return await _pendingRequests[cacheKey] as List<Map<String, dynamic>>;
    }

    // Check cache first
    if (_pageCache.containsKey(page) && _isCacheValid(cacheKey)) {
      return _pageCache[page]!;
    }

    // Create pending request
    final future = _fetchDilemmasPage(page, pageSize, category);
    _pendingRequests[cacheKey] = future;

    try {
      final result = await future;

      // Cache the result
      _pageCache[page] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();

      // Preload next page in background
      _preloadNextPage(page + 1, pageSize, category);

      return result;
    } finally {
      _pendingRequests.remove(cacheKey);
    }
  }

  // Fetch dilemmas for a specific page
  Future<List<Map<String, dynamic>>> _fetchDilemmasPage(
    int page,
    int pageSize,
    String? category,
  ) async {
    // Simulate network delay (much shorter than before)
    await Future.delayed(const Duration(milliseconds: 50));

    // Use compute for heavy processing
    return await compute(_processPageData, {
      'allDilemmas': _allDilemmas,
      'page': page,
      'pageSize': pageSize,
      'category': category,
    });
  }

  // Process page data in isolate
  static List<Map<String, dynamic>> _processPageData(Map<String, dynamic> params) {
    final allDilemmas = params['allDilemmas'] as List<Map<String, dynamic>>;
    final page = params['page'] as int;
    final pageSize = params['pageSize'] as int;
    final category = params['category'] as String?;

    var filtered = allDilemmas;
    if (category != null && category != 'All') {
      filtered = allDilemmas.where((d) => d['category'] == category).toList();
    }

    final startIndex = page * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, filtered.length);

    if (startIndex >= filtered.length) return [];

    return filtered.sublist(startIndex, endIndex);
  }

  // Preload next page in background
  void _preloadNextPage(int nextPage, int pageSize, String? category) {
    _preloadTimer?.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 100), () {
      getDilemmasPaginated(page: nextPage, pageSize: pageSize, category: category);
    });
  }

  // Check if cache is still valid
  bool _isCacheValid(String key) {
    if (!_cacheTimestamps.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheTTL;
  }

  // Get single dilemma with caching
  Future<Map<String, dynamic>?> getDilemmaById(String id) async {
    // Check cache first
    if (_dilemmaCache.containsKey(id) && _isCacheValid('dilemma_$id')) {
      return _dilemmaCache[id];
    }

    // Simulate fetch
    await Future.delayed(const Duration(milliseconds: 20));

    final dilemma = _allDilemmas.firstWhere(
      (d) => d['id'] == id,
      orElse: () => <String, dynamic>{},
    );

    if (dilemma.isNotEmpty) {
      _dilemmaCache[id] = dilemma;
      _cacheTimestamps['dilemma_$id'] = DateTime.now();
    }

    return dilemma.isEmpty ? null : dilemma;
  }

  // Search with optimized performance
  Future<List<Map<String, dynamic>>> searchDilemmasOptimized(String query) async {
    if (query.isEmpty) return [];

    // Use compute for search processing
    return await compute(_searchInIsolate, {
      'dilemmas': _allDilemmas.take(100).toList(), // Limit search scope
      'query': query.toLowerCase(),
    });
  }

  static List<Map<String, dynamic>> _searchInIsolate(Map<String, dynamic> params) {
    final dilemmas = params['dilemmas'] as List<Map<String, dynamic>>;
    final query = params['query'] as String;

    return dilemmas.where((dilemma) {
      final title = dilemma['title'].toString().toLowerCase();
      final description = dilemma['description'].toString().toLowerCase();
      final category = dilemma['category'].toString().toLowerCase();

      return title.contains(query) ||
          description.contains(query) ||
          category.contains(query);
    }).toList();
  }

  // Get categories
  List<String> getCategories() {
    return ['All', 'Career', 'Relationships', 'Finance', 'Mental Health', 'Family', 'Health'];
  }

  // Clear cache
  void clearCache() {
    _dilemmaCache.clear();
    _pageCache.clear();
    _cacheTimestamps.clear();
    _pendingRequests.clear();
    _preloadTimer?.cancel();
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'dilemmaCacheSize': _dilemmaCache.length,
      'pageCacheSize': _pageCache.length,
      'cacheHitRate': _calculateCacheHitRate(),
      'pendingRequests': _pendingRequests.length,
    };
  }

  double _calculateCacheHitRate() {
    // Implementation for cache hit rate calculation
    return 0.85; // Placeholder
  }

  // Log events (simplified version)
  void logEvent(String event, Map<String, dynamic>? parameters) {
    if (kDebugMode) {
      print('Event: $event, Parameters: $parameters');
    }
  }

  // Get chat response (optimized)
  Future<Map<String, dynamic>> getChatResponse(String message) async {
    // Quick response without blocking
    await Future.delayed(const Duration(milliseconds: 100));

    final relatedDilemmas = await searchDilemmasOptimized(message);

    if (relatedDilemmas.isNotEmpty) {
      final dilemma = relatedDilemmas.first;
      return {
        'message': 'I found guidance for "${dilemma['title']}". ${dilemma['mindfulApproach']}',
        'relatedDilemmas': relatedDilemmas.take(3).toList(),
        'suggestions': [
          'Tell me more about ${dilemma['category'].toString().toLowerCase()}',
          'How to handle ${dilemma['wellnessFocus'].toString().toLowerCase()}',
          'Practical steps for this situation',
        ],
      };
    }

    return {
      'message': 'Let me help you with that. Which area would you like guidance on?',
      'relatedDilemmas': [],
      'suggestions': getCategories().where((c) => c != 'All').take(4).toList(),
    };
  }
}

// LRU Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final _cache = LinkedHashMap<K, V>();

  LRUCache(this.maxSize);

  V? operator [](K key) {
    if (!_cache.containsKey(key)) return null;

    // Move to end (most recently used)
    final value = _cache.remove(key);
    _cache[key] = value as V;
    return value;
  }

  void operator []=(K key, V value) {
    _cache.remove(key);
    _cache[key] = value;

    if (_cache.length > maxSize) {
      _cache.remove(_cache.keys.first);
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);
  int get length => _cache.length;
  void clear() => _cache.clear();
}