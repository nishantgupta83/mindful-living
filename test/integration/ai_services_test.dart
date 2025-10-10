/// Integration tests for AI services and personalization
/// 
/// Tests AI functionality including:
/// - Content personalization
/// - Mood analysis and recommendations
/// - User behavior insights
/// - AI-powered search and discovery
/// - Machine learning model integration

import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_living/core/models/ai_models.dart';
import 'package:mindful_living/core/models/life_situation.dart';
import 'package:mindful_living/core/services/ai_service.dart';

void main() {
  group('AI Content Personalization', () {
    late AIService aiService;

    setUp(() {
      aiService = AIService();
    });

    test('Generates personalized content recommendations', () async {
      final userProfile = {
        'mood_history': ['stressed', 'anxious', 'calm'],
        'preferred_categories': ['career', 'health'],
        'difficulty_preference': 'medium',
        'usage_time': 'evening',
      };

      final recommendations = await aiService.getPersonalizedRecommendations(userProfile);

      expect(recommendations, isNotEmpty);
      expect(recommendations.length, lessThanOrEqualTo(10));
      
      // Check that recommendations match user preferences
      for (final recommendation in recommendations) {
        expect(recommendation.confidenceScore, greaterThan(0.5));
        expect(recommendation.category, anyOf(['career', 'health', 'stress_management']));
      }
    });

    test('Adapts content difficulty based on user progress', () async {
      final userProgress = {
        'completed_easy': 15,
        'completed_medium': 8,
        'completed_hard': 2,
        'success_rate': 0.78,
        'time_spent_per_session': 320, // seconds
      };

      final adaptedContent = await aiService.adaptContentDifficulty(userProgress);

      expect(adaptedContent.suggestedDifficulty, isIn([DifficultyLevel.medium, DifficultyLevel.hard]));
      expect(adaptedContent.reasoning, isNotEmpty);
      expect(adaptedContent.confidenceLevel, greaterThan(0.6));
    });

    test('Provides contextual insights based on time and activity', () async {
      final contexts = [
        {
          'time': '08:00',
          'day': 'monday',
          'recent_mood': 'anxious',
          'upcoming_events': ['meeting', 'presentation'],
        },
        {
          'time': '18:00',
          'day': 'friday',
          'recent_mood': 'tired',
          'upcoming_events': ['dinner', 'relaxation'],
        },
      ];

      for (final context in contexts) {
        final insight = await aiService.generateContextualInsight(context);
        
        expect(insight.content, isNotEmpty);
        expect(insight.confidence, greaterThan(0.7));
        expect(insight.category, isIn([
          InsightCategory.personalization,
          InsightCategory.recommendation,
          InsightCategory.optimization,
        ]));
      }
    });
  });

  group('Mood Analysis and Tracking', () {
    test('Analyzes mood patterns from journal entries', () async {
      final journalEntries = [
        {
          'date': '2024-01-01',
          'content': 'Feeling stressed about the upcoming project deadline',
          'mood': 'stressed',
        },
        {
          'date': '2024-01-02', 
          'content': 'Had a good workout today, feeling energized',
          'mood': 'energetic',
        },
        {
          'date': '2024-01-03',
          'content': 'Meditation helped me feel more centered and calm',
          'mood': 'calm',
        },
      ];

      final aiService = AIService();
      final moodAnalysis = await aiService.analyzeMoodPatterns(journalEntries);

      expect(moodAnalysis.dominantMoods, contains('stressed'));
      expect(moodAnalysis.trends, isNotEmpty);
      expect(moodAnalysis.recommendations, isNotEmpty);
      expect(moodAnalysis.confidenceScore, greaterThan(0.5));
    });

    test('Identifies emotional triggers and patterns', () async {
      final moodData = [
        {'mood': 'anxious', 'triggers': ['work', 'deadlines'], 'time': '9:00'},
        {'mood': 'happy', 'triggers': ['exercise', 'nature'], 'time': '17:00'},
        {'mood': 'frustrated', 'triggers': ['traffic', 'meetings'], 'time': '8:30'},
      ];

      final aiService = AIService();
      final triggerAnalysis = await aiService.identifyEmotionalTriggers(moodData);

      expect(triggerAnalysis.primaryTriggers, contains('work'));
      expect(triggerAnalysis.positivePatterns, contains('exercise'));
      expect(triggerAnalysis.timePatterns, isNotEmpty);
      expect(triggerAnalysis.suggestions, isNotEmpty);
    });

    test('Predicts mood trends and suggests preventive actions', () async {
      final historicalData = {
        'mood_sequence': ['happy', 'neutral', 'stressed', 'anxious', 'calm'],
        'external_factors': ['weather_rainy', 'workload_high', 'sleep_poor'],
        'intervention_points': ['meditation', 'exercise', 'social_time'],
      };

      final aiService = AIService();
      final prediction = await aiService.predictMoodTrends(historicalData);

      expect(prediction.predictedMood, isNotEmpty);
      expect(prediction.confidence, greaterThan(0.4));
      expect(prediction.preventiveActions, isNotEmpty);
      expect(prediction.riskFactors, isNotEmpty);
    });
  });

  group('AI-Powered Search and Discovery', () {
    test('Semantic search finds relevant content', () async {
      final searchQueries = [
        'I feel overwhelmed at work',
        'relationship problems with partner',
        'can\'t sleep anxiety thoughts',
        'motivation for healthy habits',
      ];

      final aiService = AIService();
      
      for (final query in searchQueries) {
        final results = await aiService.semanticSearch(query);
        
        expect(results, isNotEmpty);
        expect(results.length, lessThanOrEqualTo(20));
        
        // Verify results are ranked by relevance
        for (int i = 0; i < results.length - 1; i++) {
          expect(results[i].relevanceScore, 
                 greaterThanOrEqualTo(results[i + 1].relevanceScore));
        }
      }
    });

    test('Content similarity recommendations work accurately', () async {
      final currentContent = LifeSituation(
        id: 'test-situation',
        title: 'Managing Work Stress',
        description: 'Dealing with workplace pressure and deadlines',
        mindfulApproach: 'Practice mindful breathing',
        practicalSteps: ['Take breaks', 'Prioritize tasks'],
        keyInsights: ['Stress is manageable'],
        lifeArea: LifeArea.career,
        tags: ['stress', 'work', 'pressure'],
        difficultyLevel: DifficultyLevel.medium,
        estimatedReadTime: 5,
        wellnessFocus: WellnessFocus.mentalHealth,
      );

      final aiService = AIService();
      final similarContent = await aiService.findSimilarContent(currentContent);

      expect(similarContent, isNotEmpty);
      expect(similarContent.length, lessThanOrEqualTo(5));
      
      for (final content in similarContent) {
        expect(content.similarityScore, greaterThan(0.3));
        expect(content.commonTags, isNotEmpty);
      }
    });

    test('Intelligent content filtering based on user state', () async {
      final userStates = [
        {
          'current_mood': 'stressed',
          'available_time': 5, // minutes
          'energy_level': 'low',
          'location': 'office',
        },
        {
          'current_mood': 'motivated',
          'available_time': 30,
          'energy_level': 'high',
          'location': 'home',
        },
      ];

      final aiService = AIService();
      
      for (final state in userStates) {
        final filteredContent = await aiService.filterContentByState(state);
        
        expect(filteredContent, isNotEmpty);
        
        // Verify content matches user's current capacity
        for (final content in filteredContent) {
          expect(content.estimatedTime, lessThanOrEqualTo(state['available_time']));
          expect(content.appropriateness, greaterThan(0.7));
        }
      }
    });
  });

  group('Machine Learning Model Integration', () {
    test('Model inference performs within time limits', () async {
      final testInputs = [
        {'text': 'I am feeling anxious about tomorrow', 'type': 'mood_detection'},
        {'text': 'Best practices for work-life balance', 'type': 'content_classification'},
        {'user_data': {'mood': 'happy', 'activity': 'exercise'}, 'type': 'recommendation'},
      ];

      final aiService = AIService();
      
      for (final input in testInputs) {
        final stopwatch = Stopwatch()..start();
        
        final result = await aiService.runModelInference(input);
        
        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // 2 second limit
        expect(result.confidence, greaterThan(0.0));
        expect(result.output, isNotNull);
      }
    });

    test('Model handles edge cases and invalid inputs', () async {
      final edgeCases = [
        {'input': '', 'expected': 'empty_input_handled'},
        {'input': 'a' * 1000, 'expected': 'long_input_truncated'},
        {'input': '🎉🎊🎈', 'expected': 'emoji_input_processed'},
        {'input': null, 'expected': 'null_input_handled'},
      ];

      final aiService = AIService();
      
      for (final testCase in edgeCases) {
        final result = await aiService.handleEdgeCase(testCase['input']);
        
        expect(result.error, isFalse);
        expect(result.fallbackUsed, isTrue);
        expect(result.message, isNotEmpty);
      }
    });

    test('Model updates and version management work correctly', () async {
      final aiService = AIService();
      
      // Check current model version
      final currentVersion = await aiService.getCurrentModelVersion();
      expect(currentVersion, isNotEmpty);
      
      // Check for model updates
      final updateAvailable = await aiService.checkForModelUpdates();
      expect(updateAvailable.status, isIn(['up_to_date', 'update_available']));
      
      // Simulate model update if available
      if (updateAvailable.status == 'update_available') {
        final updateResult = await aiService.updateModel();
        expect(updateResult.success, isTrue);
        expect(updateResult.newVersion, isNotEmpty);
      }
    });
  });

  group('AI Performance Optimization', () {
    test('Caching reduces response times for repeated queries', () async {
      final aiService = AIService();
      const testQuery = 'stress management techniques';
      
      // First request (no cache)
      final stopwatch1 = Stopwatch()..start();
      final result1 = await aiService.getCachedRecommendations(testQuery);
      stopwatch1.stop();
      
      // Second request (should use cache)
      final stopwatch2 = Stopwatch()..start();
      final result2 = await aiService.getCachedRecommendations(testQuery);
      stopwatch2.stop();
      
      expect(result1.recommendations, isNotEmpty);
      expect(result2.recommendations, equals(result1.recommendations));
      expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds));
      expect(result2.fromCache, isTrue);
    });

    test('Batch processing handles multiple requests efficiently', () async {
      final batchRequests = List.generate(10, (index) => {
        'id': 'request_$index',
        'query': 'wellness advice for scenario $index',
        'priority': index % 3, // 0=high, 1=medium, 2=low
      });

      final aiService = AIService();
      final stopwatch = Stopwatch()..start();
      
      final batchResults = await aiService.processBatch(batchRequests);
      
      stopwatch.stop();
      
      expect(batchResults.length, equals(batchRequests.length));
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // 5 second limit for batch
      
      // Verify high priority items processed first
      final highPriorityResults = batchResults.where((r) => r.priority == 0);
      expect(highPriorityResults.every((r) => r.processedAt != null), isTrue);
    });
  });

  group('AI Privacy and Security', () {
    test('User data anonymization works correctly', () async {
      final sensitiveData = {
        'user_id': 'user_12345',
        'email': 'test@example.com',
        'name': 'John Doe',
        'journal_content': 'I had a difficult conversation with my boss today',
        'mood_data': ['anxious', 'stressed'],
      };

      final aiService = AIService();
      final anonymizedData = await aiService.anonymizeUserData(sensitiveData);

      expect(anonymizedData['user_id'], isNot(equals('user_12345')));
      expect(anonymizedData['email'], isNull);
      expect(anonymizedData['name'], isNull);
      expect(anonymizedData['journal_content'], contains('difficult conversation'));
      expect(anonymizedData['mood_data'], equals(['anxious', 'stressed']));
    });

    test('Data retention policies are enforced', () async {
      final dataRetentionRules = [
        {'type': 'mood_data', 'retention_days': 365},
        {'type': 'journal_entries', 'retention_days': 1095}, // 3 years
        {'type': 'usage_analytics', 'retention_days': 90},
        {'type': 'crash_logs', 'retention_days': 30},
      ];

      final aiService = AIService();
      
      for (final rule in dataRetentionRules) {
        final enforcementResult = await aiService.enforceDataRetention(rule);
        
        expect(enforcementResult.itemsProcessed, greaterThanOrEqualTo(0));
        expect(enforcementResult.itemsDeleted, greaterThanOrEqualTo(0));
        expect(enforcementResult.success, isTrue);
      }
    });
  });
}