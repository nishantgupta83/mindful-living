import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_item.dart';
import '../models/ai_models.dart';
import 'ai_service.dart';

/// Service for managing user favorites with AI-powered categorization and insights
class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AIService _aiService = AIService();

  // State management
  final Map<String, FavoriteItem> _favorites = {};
  final Map<String, List<FavoriteItem>> _categorizedFavorites = {};
  bool _isLoading = false;
  String? _lastError;

  // Getters
  Map<String, FavoriteItem> get favorites => Map.unmodifiable(_favorites);
  Map<String, List<FavoriteItem>> get categorizedFavorites => 
      Map.unmodifiable(_categorizedFavorites);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  int get totalCount => _favorites.length;

  /// Initialize favorites service
  Future<void> initialize() async {
    await loadFavorites();
    await _categorizeFavorites();
  }

  /// Load user favorites from Firebase
  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _setLoading(true);
    
    try {
      final snapshot = await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .collection('items')
          .orderBy('addedAt', descending: true)
          .get();

      _favorites.clear();
      for (final doc in snapshot.docs) {
        final favorite = FavoriteItem.fromMap(doc.data());
        _favorites[favorite.itemId] = favorite;
      }

      await _categorizeFavorites();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load favorites: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add item to favorites with AI categorization
  Future<bool> addToFavorites({
    required String itemId,
    required FavoriteItemType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (_favorites.containsKey(itemId)) {
      return true; // Already favorited
    }

    try {
      // Generate AI category and insights
      final aiCategory = await _generateAICategory(
        title: title,
        description: description,
        type: type,
        metadata: metadata,
      );

      final favorite = FavoriteItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        itemId: itemId,
        type: type,
        title: title,
        description: description,
        addedAt: DateTime.now(),
        lastAccessedAt: DateTime.now(),
        accessCount: 0,
        aiCategory: aiCategory,
        aiInsight: await _generateFavoriteInsight(title, description, type),
        metadata: metadata ?? {},
      );

      // Save to Firebase
      await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .collection('items')
          .doc(favorite.id)
          .set(favorite.toMap());

      // Update local state
      _favorites[itemId] = favorite;
      await _categorizeFavorites();
      
      // Log activity for AI learning
      await _logFavoriteActivity(favorite, 'added');
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add favorite: $e');
      return false;
    }
  }

  /// Remove item from favorites
  Future<bool> removeFromFavorites(String itemId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final favorite = _favorites[itemId];
    if (favorite == null) return false;

    try {
      await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .collection('items')
          .doc(favorite.id)
          .delete();

      _favorites.remove(itemId);
      await _categorizeFavorites();
      
      // Log activity
      await _logFavoriteActivity(favorite, 'removed');
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to remove favorite: $e');
      return false;
    }
  }

  /// Check if item is favorited
  bool isFavorited(String itemId) {
    return _favorites.containsKey(itemId);
  }

  /// Update access tracking for a favorite
  Future<void> trackAccess(String itemId) async {
    final favorite = _favorites[itemId];
    if (favorite == null) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final updatedFavorite = favorite.copyWith(
        lastAccessedAt: DateTime.now(),
        accessCount: favorite.accessCount + 1,
      );

      await _firestore
          .collection('user_favorites')
          .doc(user.uid)
          .collection('items')
          .doc(favorite.id)
          .update({
        'lastAccessedAt': Timestamp.fromDate(updatedFavorite.lastAccessedAt),
        'accessCount': updatedFavorite.accessCount,
      });

      _favorites[itemId] = updatedFavorite;
      await _logFavoriteActivity(updatedFavorite, 'accessed');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to track access: $e');
    }
  }

  /// Get favorites by category
  List<FavoriteItem> getFavoritesByCategory(String category) {
    return _categorizedFavorites[category] ?? [];
  }

  /// Get recently added favorites
  List<FavoriteItem> getRecentFavorites({int limit = 10}) {
    final sorted = _favorites.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(limit).toList();
  }

  /// Get most accessed favorites
  List<FavoriteItem> getMostAccessedFavorites({int limit = 10}) {
    final sorted = _favorites.values.toList()
      ..sort((a, b) => b.accessCount.compareTo(a.accessCount));
    return sorted.take(limit).toList();
  }

  /// Search favorites with AI-enhanced relevance
  List<FavoriteItem> searchFavorites(String query) {
    if (query.isEmpty) return _favorites.values.toList();

    final queryLower = query.toLowerCase();
    final results = <FavoriteItem>[];

    for (final favorite in _favorites.values) {
      double relevanceScore = 0.0;

      // Title match (highest weight)
      if (favorite.title.toLowerCase().contains(queryLower)) {
        relevanceScore += 1.0;
      }

      // Description match
      if (favorite.description.toLowerCase().contains(queryLower)) {
        relevanceScore += 0.7;
      }

      // AI category match
      if (favorite.aiCategory?.toLowerCase().contains(queryLower) == true) {
        relevanceScore += 0.5;
      }

      // AI insight match
      if (favorite.aiInsight?.toLowerCase().contains(queryLower) == true) {
        relevanceScore += 0.3;
      }

      // Metadata match
      final metadataText = favorite.metadata.values.join(' ').toLowerCase();
      if (metadataText.contains(queryLower)) {
        relevanceScore += 0.2;
      }

      if (relevanceScore > 0) {
        results.add(favorite);
      }
    }

    // Sort by relevance and access frequency
    results.sort((a, b) {
      final aScore = _calculateSearchScore(a, query);
      final bScore = _calculateSearchScore(b, query);
      return bScore.compareTo(aScore);
    });

    return results;
  }

  /// Get AI-powered favorite recommendations
  Future<List<ContentRecommendation>> getFavoriteRecommendations() async {
    try {
      // Analyze user's favorite patterns
      final patterns = _analyzeFavoritePatterns();
      
      // Get AI recommendations based on patterns
      final recommendations = await _aiService.generateRecommendations(
        limit: 5,
        type: ContentRecommendationType.lifeSituation,
      );

      return recommendations;
    } catch (e) {
      debugPrint('Failed to get recommendations: $e');
      return [];
    }
  }

  /// Export favorites data
  Map<String, dynamic> exportFavorites() {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': _favorites.length,
      'categories': _categorizedFavorites.keys.toList(),
      'favorites': _favorites.values.map((f) => f.toMap()).toList(),
    };
  }

  // Private methods

  Future<void> _categorizeFavorites() async {
    _categorizedFavorites.clear();

    for (final favorite in _favorites.values) {
      final category = favorite.aiCategory ?? 'Uncategorized';
      _categorizedFavorites.putIfAbsent(category, () => []);
      _categorizedFavorites[category]!.add(favorite);
    }

    // Sort each category by access frequency and recency
    for (final category in _categorizedFavorites.keys) {
      _categorizedFavorites[category]!.sort((a, b) {
        // Primary: access count
        if (a.accessCount != b.accessCount) {
          return b.accessCount.compareTo(a.accessCount);
        }
        // Secondary: recency
        return b.addedAt.compareTo(a.addedAt);
      });
    }
  }

  Future<String?> _generateAICategory({
    required String title,
    required String description,
    required FavoriteItemType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Simplified AI categorization logic
      // In a real implementation, this would call an AI API
      
      final text = '$title $description'.toLowerCase();
      
      if (text.contains('work') || text.contains('career') || text.contains('job')) {
        return 'Career Growth';
      } else if (text.contains('relationship') || text.contains('family') || text.contains('love')) {
        return 'Relationships';
      } else if (text.contains('health') || text.contains('wellness') || text.contains('exercise')) {
        return 'Health & Wellness';
      } else if (text.contains('stress') || text.contains('anxiety') || text.contains('calm')) {
        return 'Stress Management';
      } else if (text.contains('goal') || text.contains('growth') || text.contains('improve')) {
        return 'Personal Growth';
      } else if (text.contains('money') || text.contains('financial') || text.contains('budget')) {
        return 'Financial Wellness';
      }
      
      return 'General Wellness';
    } catch (e) {
      debugPrint('Failed to generate AI category: $e');
      return null;
    }
  }

  Future<String?> _generateFavoriteInsight(
    String title,
    String description,
    FavoriteItemType type,
  ) async {
    try {
      // Simplified insight generation
      switch (type) {
        case FavoriteItemType.lifeSituation:
          return 'This situation resonates with your personal growth journey';
        case FavoriteItemType.wellnessPractice:
          return 'Perfect addition to your mindfulness routine';
        case FavoriteItemType.journalEntry:
          return 'Reflects important moments in your wellness journey';
        case FavoriteItemType.goal:
          return 'Aligns with your long-term wellness objectives';
      }
    } catch (e) {
      debugPrint('Failed to generate insight: $e');
      return null;
    }
  }

  double _calculateSearchScore(FavoriteItem favorite, String query) {
    double score = 0.0;
    final queryLower = query.toLowerCase();

    // Base relevance scoring
    if (favorite.title.toLowerCase().contains(queryLower)) score += 1.0;
    if (favorite.description.toLowerCase().contains(queryLower)) score += 0.5;

    // Boost for frequently accessed items
    score += (favorite.accessCount * 0.1);

    // Boost for recently added items
    final daysSinceAdded = DateTime.now().difference(favorite.addedAt).inDays;
    if (daysSinceAdded < 7) score += 0.3;

    return score;
  }

  Map<String, dynamic> _analyzeFavoritePatterns() {
    final patterns = <String, dynamic>{};
    final categories = <String, int>{};
    final types = <String, int>{};

    for (final favorite in _favorites.values) {
      // Category patterns
      final category = favorite.aiCategory ?? 'Uncategorized';
      categories[category] = (categories[category] ?? 0) + 1;

      // Type patterns
      final type = favorite.type.toString();
      types[type] = (types[type] ?? 0) + 1;
    }

    patterns['categories'] = categories;
    patterns['types'] = types;
    patterns['totalCount'] = _favorites.length;
    patterns['averageAccessCount'] = _favorites.values
        .map((f) => f.accessCount)
        .fold(0, (a, b) => a + b) / _favorites.length;

    return patterns;
  }

  Future<void> _logFavoriteActivity(FavoriteItem favorite, String action) async {
    try {
      await _firestore
          .collection('user_activity')
          .add({
        'userId': favorite.userId,
        'action': 'favorite_$action',
        'itemId': favorite.itemId,
        'itemType': favorite.type.toString(),
        'category': favorite.aiCategory,
        'timestamp': Timestamp.now(),
        'metadata': {
          'title': favorite.title,
          'accessCount': favorite.accessCount,
        },
      });
    } catch (e) {
      debugPrint('Failed to log activity: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    debugPrint('Favorites Service Error: $error');
    notifyListeners();
  }
}