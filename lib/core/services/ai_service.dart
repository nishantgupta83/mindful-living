import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_models.dart';
import '../models/life_situation.dart';

/// Central AI service that provides intelligent personalization and insights
/// Integrates with Firebase Functions for server-side AI processing
class AIService extends ChangeNotifier {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // AI state management
  bool _isProcessing = false;
  String? _lastError;
  AIPersonalityProfile? _currentPersonality;
  List<AIInsight> _recentInsights = [];
  List<ContentRecommendation> _recommendations = [];

  // Getters
  bool get isProcessing => _isProcessing;
  String? get lastError => _lastError;
  AIPersonalityProfile? get currentPersonality => _currentPersonality;
  List<AIInsight> get recentInsights => List.unmodifiable(_recentInsights);
  List<ContentRecommendation> get recommendations => List.unmodifiable(_recommendations);

  /// Initialize AI service and load user personality profile
  Future<void> initialize() async {
    await _loadPersonalityProfile();
    await _loadRecentInsights();
    await _generateRecommendations();
  }

  /// Generate personalized content recommendations based on user behavior
  Future<List<ContentRecommendation>> generateRecommendations({
    int limit = 10,
    String? category,
    ContentRecommendationType? type,
  }) async {
    _setProcessing(true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user behavior data
      final userBehavior = await _getUserBehaviorData(user.uid);
      
      // Get available content
      Query query = _firestore.collection('life_situations');
      
      if (category != null) {
        query = query.where('lifeArea', isEqualTo: category);
      }
      
      query = query.limit(50); // Get more content to filter through
      final contentSnapshot = await query.get();
      
      // AI recommendation logic
      final recommendations = await _processRecommendations(
        userBehavior: userBehavior,
        availableContent: contentSnapshot.docs,
        limit: limit,
        type: type,
      );
      
      _recommendations = recommendations;
      notifyListeners();
      
      return recommendations;
    } catch (e) {
      _setError('Failed to generate recommendations: $e');
      return [];
    } finally {
      _setProcessing(false);
    }
  }

  /// Generate AI insights for a specific life situation
  Future<AIInsight?> generateSituationInsight({
    required String situationId,
    required Map<String, dynamic> userContext,
  }) async {
    _setProcessing(true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Get situation data
      final situationDoc = await _firestore
          .collection('life_situations')
          .doc(situationId)
          .get();
      
      if (!situationDoc.exists) {
        throw Exception('Situation not found');
      }

      // Generate insight using AI
      final insight = await _generatePersonalizedInsight(
        situation: situationDoc.data()!,
        userContext: userContext,
        personality: _currentPersonality,
      );

      if (insight != null) {
        _recentInsights.insert(0, insight);
        if (_recentInsights.length > 20) {
          _recentInsights = _recentInsights.take(20).toList();
        }
        
        // Save insight to Firebase
        await _saveInsight(insight);
        notifyListeners();
      }

      return insight;
    } catch (e) {
      _setError('Failed to generate insight: $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Analyze user mood patterns and provide insights
  Future<MoodAnalysis?> analyzeMoodPatterns({
    int daysBack = 30,
  }) async {
    _setProcessing(true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: daysBack));

      // Get journal entries with mood data
      final journalSnapshot = await _firestore
          .collection('journal_entries')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      if (journalSnapshot.docs.isEmpty) {
        return MoodAnalysis(
          averageMood: 5.0,
          moodTrend: MoodTrend.stable,
          insights: ['Not enough data for analysis. Keep journaling!'],
          recommendations: ['Start tracking your daily mood'],
          dataPoints: [],
          periodDays: daysBack,
        );
      }

      // Process mood data
      final moodAnalysis = await _processMoodData(journalSnapshot.docs);
      return moodAnalysis;
    } catch (e) {
      _setError('Failed to analyze mood patterns: $e');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Update user personality profile based on app usage
  Future<void> updatePersonalityProfile({
    required Map<String, dynamic> behaviorData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // AI personality analysis
      final updatedPersonality = await _analyzePersonality(behaviorData);
      
      if (updatedPersonality != null) {
        _currentPersonality = updatedPersonality;
        
        // Save to Firebase
        await _firestore
            .collection('user_personality')
            .doc(user.uid)
            .set(updatedPersonality.toMap(), SetOptions(merge: true));
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update personality profile: $e');
    }
  }

  /// Generate smart content filtering based on user preferences
  List<LifeSituation> filterContentWithAI({
    required List<LifeSituation> content,
    required String searchQuery,
    Map<String, dynamic>? userContext,
  }) {
    try {
      // Semantic search and relevance scoring
      final scoredContent = content.map((situation) {
        double score = _calculateRelevanceScore(
          situation: situation,
          query: searchQuery,
          personality: _currentPersonality,
          context: userContext,
        );
        
        return ScoredContent(situation: situation, score: score);
      }).toList();

      // Sort by relevance score and return top results
      scoredContent.sort((a, b) => b.score.compareTo(a.score));
      
      return scoredContent
          .where((scored) => scored.score > 0.3) // Minimum relevance threshold
          .map((scored) => scored.situation)
          .take(20)
          .toList();
    } catch (e) {
      debugPrint('AI filtering error: $e');
      return content; // Fallback to original content
    }
  }

  /// Generate dynamic wellness goals based on user progress
  Future<List<WellnessGoal>> generatePersonalizedGoals() async {
    _setProcessing(true);
    
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // Get user progress data
      final progressData = await _getUserProgressData(user.uid);
      
      // AI goal generation
      final goals = await _generateSmartGoals(
        progressData: progressData,
        personality: _currentPersonality,
        currentDate: DateTime.now(),
      );

      return goals;
    } catch (e) {
      _setError('Failed to generate goals: $e');
      return [];
    } finally {
      _setProcessing(false);
    }
  }

  // Private methods

  Future<void> _loadPersonalityProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore
          .collection('user_personality')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _currentPersonality = AIPersonalityProfile.fromMap(doc.data()!);
      } else {
        // Create initial personality profile
        _currentPersonality = AIPersonalityProfile.createDefault();
        await _firestore
            .collection('user_personality')
            .doc(user.uid)
            .set(_currentPersonality!.toMap());
      }
    } catch (e) {
      debugPrint('Error loading personality profile: $e');
    }
  }

  Future<void> _loadRecentInsights() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('ai_insights')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      _recentInsights = snapshot.docs
          .map((doc) => AIInsight.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading insights: $e');
    }
  }

  Future<void> _generateRecommendations() async {
    try {
      final recommendations = await generateRecommendations(limit: 10);
      _recommendations = recommendations;
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
    }
  }

  Future<List<ContentRecommendation>> _processRecommendations({
    required Map<String, dynamic> userBehavior,
    required List<QueryDocumentSnapshot> availableContent,
    required int limit,
    ContentRecommendationType? type,
  }) async {
    final recommendations = <ContentRecommendation>[];
    
    for (final doc in availableContent) {
      final data = doc.data() as Map<String, dynamic>;
      final situation = LifeSituation.fromMap(data);
      
      // Calculate recommendation score
      final score = _calculateRecommendationScore(
        situation: situation,
        userBehavior: userBehavior,
        personality: _currentPersonality,
      );
      
      if (score > 0.4) { // Minimum threshold
        recommendations.add(ContentRecommendation(
          id: doc.id,
          type: type ?? ContentRecommendationType.lifeSituation,
          title: situation.title,
          description: situation.description,
          score: score,
          reason: _generateRecommendationReason(situation, score),
          metadata: {
            'category': situation.lifeArea,
            'tags': situation.tags,
            'wellnessFocus': situation.wellnessFocus,
          },
          createdAt: DateTime.now(),
        ));
      }
    }
    
    // Sort by score and return top recommendations
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    return recommendations.take(limit).toList();
  }

  double _calculateRecommendationScore({
    required LifeSituation situation,
    required Map<String, dynamic> userBehavior,
    AIPersonalityProfile? personality,
  }) {
    double score = 0.0;
    
    // Base relevance score
    score += 0.3;
    
    // Category preference
    final categoryPreference = userBehavior['categoryPreferences']?[situation.lifeArea] ?? 0.0;
    score += categoryPreference * 0.3;
    
    // Personality alignment
    if (personality != null) {
      final personalityScore = _calculatePersonalityAlignment(situation, personality);
      score += personalityScore * 0.2;
    }
    
    // Recency bonus for new content
    final daysSinceCreated = DateTime.now().difference(situation.createdAt).inDays;
    if (daysSinceCreated < 7) {
      score += 0.1;
    }
    
    // Wellness focus alignment
    final userWellnessFocus = userBehavior['wellnessFocus'] as List<String>? ?? [];
    final commonFocus = situation.wellnessFocus
        .where((focus) => userWellnessFocus.contains(focus))
        .length;
    score += (commonFocus / situation.wellnessFocus.length) * 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  double _calculatePersonalityAlignment(
    LifeSituation situation,
    AIPersonalityProfile personality,
  ) {
    // Simplified personality alignment calculation
    double alignment = 0.0;
    
    // Match content style with personality
    if (personality.preferredContentStyle == 'practical' && 
        situation.practicalSteps.isNotEmpty) {
      alignment += 0.3;
    }
    
    if (personality.preferredContentStyle == 'mindful' && 
        situation.mindfulApproach.isNotEmpty) {
      alignment += 0.3;
    }
    
    // Match complexity preference
    if (personality.complexityPreference == 'simple' && 
        situation.difficultyLevel <= 3) {
      alignment += 0.2;
    }
    
    if (personality.complexityPreference == 'detailed' && 
        situation.difficultyLevel >= 4) {
      alignment += 0.2;
    }
    
    return alignment.clamp(0.0, 1.0);
  }

  double _calculateRelevanceScore({
    required LifeSituation situation,
    required String query,
    AIPersonalityProfile? personality,
    Map<String, dynamic>? context,
  }) {
    double score = 0.0;
    final queryLower = query.toLowerCase();
    
    // Title match
    if (situation.title.toLowerCase().contains(queryLower)) {
      score += 0.4;
    }
    
    // Description match
    if (situation.description.toLowerCase().contains(queryLower)) {
      score += 0.2;
    }
    
    // Tags match
    for (final tag in situation.tags) {
      if (tag.toLowerCase().contains(queryLower)) {
        score += 0.1;
      }
    }
    
    // Semantic similarity (simplified)
    score += _calculateSemanticSimilarity(queryLower, situation);
    
    return score.clamp(0.0, 1.0);
  }

  double _calculateSemanticSimilarity(String query, LifeSituation situation) {
    // Simplified semantic similarity calculation
    final keywords = query.split(' ');
    final situationText = '${situation.title} ${situation.description}'.toLowerCase();
    
    int matches = 0;
    for (final keyword in keywords) {
      if (situationText.contains(keyword)) {
        matches++;
      }
    }
    
    return keywords.isEmpty ? 0.0 : matches / keywords.length * 0.2;
  }

  String _generateRecommendationReason(LifeSituation situation, double score) {
    if (score > 0.8) {
      return 'Perfect match for your interests and goals';
    } else if (score > 0.6) {
      return 'Highly relevant to your wellness journey';
    } else if (score > 0.4) {
      return 'Recommended based on your preferences';
    } else {
      return 'Might be helpful for your current situation';
    }
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String error) {
    _lastError = error;
    debugPrint('AI Service Error: $error');
    notifyListeners();
  }

  // Placeholder methods for future implementation
  Future<Map<String, dynamic>> _getUserBehaviorData(String userId) async {
    // TODO: Implement actual behavior tracking
    return {
      'categoryPreferences': {
        'Career': 0.8,
        'Relationships': 0.6,
        'Health': 0.7,
      },
      'wellnessFocus': ['stress-relief', 'mindfulness'],
      'sessionDuration': 300, // seconds
      'engagementScore': 0.75,
    };
  }

  Future<AIInsight?> _generatePersonalizedInsight({
    required Map<String, dynamic> situation,
    required Map<String, dynamic> userContext,
    AIPersonalityProfile? personality,
  }) async {
    // TODO: Implement actual AI insight generation
    return AIInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _auth.currentUser?.uid ?? '',
      type: AIInsightType.situationAdvice,
      title: 'Personalized Insight',
      content: 'Based on your personality and current situation, consider focusing on mindful breathing techniques.',
      confidence: 0.85,
      metadata: {'situationId': situation['id']},
      createdAt: DateTime.now(),
    );
  }

  Future<void> _saveInsight(AIInsight insight) async {
    await _firestore
        .collection('ai_insights')
        .doc(insight.id)
        .set(insight.toMap());
  }

  Future<MoodAnalysis> _processMoodData(List<QueryDocumentSnapshot> docs) async {
    // TODO: Implement mood analysis algorithm
    return MoodAnalysis(
      averageMood: 6.5,
      moodTrend: MoodTrend.improving,
      insights: ['Your mood has been steadily improving'],
      recommendations: ['Continue your mindfulness practice'],
      dataPoints: [],
      periodDays: 30,
    );
  }

  Future<AIPersonalityProfile?> _analyzePersonality(Map<String, dynamic> behaviorData) async {
    // TODO: Implement personality analysis
    return _currentPersonality;
  }

  Future<Map<String, dynamic>> _getUserProgressData(String userId) async {
    // TODO: Implement progress tracking
    return {};
  }

  Future<List<WellnessGoal>> _generateSmartGoals({
    required Map<String, dynamic> progressData,
    AIPersonalityProfile? personality,
    required DateTime currentDate,
  }) async {
    // TODO: Implement goal generation
    return [];
  }
}

/// Helper class for scored content
class ScoredContent {
  final LifeSituation situation;
  final double score;

  ScoredContent({required this.situation, required this.score});
}