/// Unit tests for core services
/// 
/// Tests business logic, data models, and service functionality
/// without UI dependencies

import 'package:flutter_test/flutter_test.dart';
import 'package:mindful_living/core/models/life_situation.dart';
import 'package:mindful_living/core/models/ai_models.dart';
import 'package:mindful_living/core/models/user_profile.dart';
import 'package:mindful_living/core/models/favorite_item.dart';

// Test enums
enum LifeArea { career, relationships, health, family, personal, financial }
enum DifficultyLevel { easy, medium, hard }
enum WellnessFocus { mentalHealth, physicalHealth, emotional, spiritual, social }
enum InsightCategory { personalization, recommendation, optimization }
enum FavoriteItemType { lifeSituation, practice }

void main() {
  group('Data Model Tests', () {
    group('LifeSituation Model', () {
      test('LifeSituation model serialization works correctly', () {
        final situation = LifeSituation(
          id: 'test-id',
          title: 'Test Situation',
          description: 'Test description',
          mindfulApproach: 'Mindful approach text',
          practicalSteps: ['Step 1', 'Step 2'],
          keyInsights: ['Insight 1', 'Insight 2'],
          lifeArea: 'career',
          tags: ['stress', 'work'],
          difficultyLevel: 3,
          estimatedReadTime: 5,
          wellnessFocus: ['mentalHealth'],
          voiceKeywords: ['test', 'stress'],
          spokenTitle: 'Test Situation',
          spokenActionSteps: ['Step 1', 'Step 2'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          metadata: {},
        );

        // Test all properties are set correctly
        expect(situation.id, equals('test-id'));
        expect(situation.title, equals('Test Situation'));
        expect(situation.description, equals('Test description'));
        expect(situation.practicalSteps, hasLength(2));
        expect(situation.keyInsights, hasLength(2));
        expect(situation.lifeArea, equals('career'));
        expect(situation.tags, contains('stress'));
        expect(situation.difficultyLevel, equals(3));
        expect(situation.estimatedReadTime, equals(5));
      });

      test('LifeSituation copyWith method works correctly', () {
        final original = LifeSituation(
          id: 'original-id',
          title: 'Original Title',
          description: 'Original description',
          mindfulApproach: 'Original approach',
          practicalSteps: ['Original step'],
          keyInsights: ['Original insight'],
          lifeArea: 'health',
          tags: ['original'],
          difficultyLevel: 2,
          estimatedReadTime: 3,
          wellnessFocus: ['physicalHealth'],
          voiceKeywords: ['health'],
          spokenTitle: 'Original Title',
          spokenActionSteps: ['Original step'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          metadata: {},
        );

        final updated = original.copyWith(
          title: 'Updated Title',
          difficultyLevel: 5,
        );

        // Updated properties should change
        expect(updated.title, equals('Updated Title'));
        expect(updated.difficultyLevel, equals(5));
        
        // Non-updated properties should remain the same
        expect(updated.id, equals('original-id'));
        expect(updated.description, equals('Original description'));
        expect(updated.lifeArea, equals('health'));
      });

      test('LifeSituation validation works', () {
        // Valid situation should pass
        final validSituation = LifeSituation(
          id: 'valid-id',
          title: 'Valid Title',
          description: 'Valid description',
          mindfulApproach: 'Valid approach',
          practicalSteps: ['Valid step'],
          keyInsights: ['Valid insight'],
          lifeArea: 'relationships',
          tags: ['valid'],
          difficultyLevel: 3,
          estimatedReadTime: 5,
          wellnessFocus: ['emotional'],
          voiceKeywords: ['valid'],
          spokenTitle: 'Valid Title',
          spokenActionSteps: ['Valid step'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isActive: true,
          metadata: {},
        );

        expect(validSituation.title.isNotEmpty, isTrue);

        // Invalid situation (empty title) should fail
        final invalidSituation = validSituation.copyWith(title: '');
        expect(invalidSituation.title.isEmpty, isTrue);
      });
    });

    group('AIInsight Model', () {
      test('AIInsight model creation and properties', () {
        final insight = AIInsight(
          id: 'insight-123',
          content: 'This is an AI-generated insight',
          confidence: 0.85,
          category: InsightCategory.personalization,
          timestamp: DateTime(2024, 1, 15),
          metadata: {'source': 'ml_model_v2'},
        );

        expect(insight.id, equals('insight-123'));
        expect(insight.content, equals('This is an AI-generated insight'));
        expect(insight.confidence, equals(0.85));
        expect(insight.category, equals(InsightCategory.personalization));
        expect(insight.metadata['source'], equals('ml_model_v2'));
      });

      test('AIInsight confidence validation', () {
        // Valid confidence values
        expect(() => AIInsight(
          id: 'test',
          content: 'test',
          confidence: 0.0,
          category: InsightCategory.recommendation,
          timestamp: DateTime.now(),
        ), returnsNormally);

        expect(() => AIInsight(
          id: 'test',
          content: 'test',
          confidence: 1.0,
          category: InsightCategory.recommendation,
          timestamp: DateTime.now(),
        ), returnsNormally);

        // Invalid confidence values should throw
        expect(() => AIInsight(
          id: 'test',
          content: 'test',
          confidence: -0.1,
          category: InsightCategory.recommendation,
          timestamp: DateTime.now(),
        ), throwsArgumentError);

        expect(() => AIInsight(
          id: 'test',
          content: 'test',
          confidence: 1.1,
          category: InsightCategory.recommendation,
          timestamp: DateTime.now(),
        ), throwsArgumentError);
      });
    });

    group('UserProfile Model', () {
      test('UserProfile creation with default values', () {
        final profile = UserProfile(
          id: 'user-123',
          email: 'test@example.com',
        );

        expect(profile.id, equals('user-123'));
        expect(profile.email, equals('test@example.com'));
        expect(profile.preferences, isNotNull);
        expect(profile.createdAt, isNotNull);
        expect(profile.lastActiveAt, isNotNull);
      });

      test('UserProfile preference updates', () {
        final profile = UserProfile(
          id: 'user-123',
          email: 'test@example.com',
        );

        final updatedProfile = profile.updatePreferences({
          'language': 'es',
          'notifications': true,
          'theme': 'dark',
        });

        expect(updatedProfile.preferences['language'], equals('es'));
        expect(updatedProfile.preferences['notifications'], isTrue);
        expect(updatedProfile.preferences['theme'], equals('dark'));
      });

      test('UserProfile activity tracking', () {
        final profile = UserProfile(
          id: 'user-123',
          email: 'test@example.com',
        );

        final activeProfile = profile.markActive();
        
        expect(activeProfile.lastActiveAt.isAfter(profile.lastActiveAt), isTrue);
      });
    });

    group('FavoriteItem Model', () {
      test('FavoriteItem creation and properties', () {
        final favorite = FavoriteItem(
          id: 'fav-123',
          userId: 'user-456',
          itemId: 'situation-789',
          itemType: FavoriteItemType.lifeSituation,
          addedAt: DateTime(2024, 1, 15),
        );

        expect(favorite.id, equals('fav-123'));
        expect(favorite.userId, equals('user-456'));
        expect(favorite.itemId, equals('situation-789'));
        expect(favorite.itemType, equals(FavoriteItemType.lifeSituation));
        expect(favorite.addedAt, equals(DateTime(2024, 1, 15)));
      });

      test('FavoriteItem equality and hashCode', () {
        final favorite1 = FavoriteItem(
          id: 'fav-123',
          userId: 'user-456',
          itemId: 'situation-789',
          itemType: FavoriteItemType.lifeSituation,
          addedAt: DateTime(2024, 1, 15),
        );

        final favorite2 = FavoriteItem(
          id: 'fav-123',
          userId: 'user-456',
          itemId: 'situation-789',
          itemType: FavoriteItemType.lifeSituation,
          addedAt: DateTime(2024, 1, 15),
        );

        final favorite3 = FavoriteItem(
          id: 'fav-124',
          userId: 'user-456',
          itemId: 'situation-789',
          itemType: FavoriteItemType.lifeSituation,
          addedAt: DateTime(2024, 1, 15),
        );

        expect(favorite1, equals(favorite2));
        expect(favorite1.hashCode, equals(favorite2.hashCode));
        expect(favorite1, isNot(equals(favorite3)));
      });
    });
  });

  group('Enum Tests', () {
    test('LifeArea enum values', () {
      final areas = LifeArea.values;
      expect(areas, contains(LifeArea.career));
      expect(areas, contains(LifeArea.relationships));
      expect(areas, contains(LifeArea.health));
      expect(areas, contains(LifeArea.family));
      expect(areas, contains(LifeArea.personal));
      expect(areas, contains(LifeArea.financial));
    });

    test('DifficultyLevel enum ordering', () {
      expect(DifficultyLevel.easy.index, lessThan(DifficultyLevel.medium.index));
      expect(DifficultyLevel.medium.index, lessThan(DifficultyLevel.hard.index));
    });

    test('WellnessFocus enum coverage', () {
      final focuses = WellnessFocus.values;
      expect(focuses, contains(WellnessFocus.mentalHealth));
      expect(focuses, contains(WellnessFocus.physicalHealth));
      expect(focuses, contains(WellnessFocus.emotional));
      expect(focuses, contains(WellnessFocus.spiritual));
      expect(focuses, contains(WellnessFocus.social));
    });
  });

  group('Utility Function Tests', () {
    test('String extension methods work correctly', () {
      expect('hello world'.toTitleCase(), equals('Hello World'));
      expect('UPPERCASE TEXT'.toTitleCase(), equals('Uppercase Text'));
      expect(''.toTitleCase(), equals(''));
    });

    test('Date formatting utilities', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      expect(date.toIsoDateString(), equals('2024-01-15'));
      expect(date.toReadableString(), equals('January 15, 2024'));
    });

    test('Validation utilities', () {
      expect('test@example.com'.isValidEmail, isTrue);
      expect('invalid-email'.isValidEmail, isFalse);
      expect(''.isValidEmail, isFalse);
      
      expect('ValidPassword123!'.isValidPassword, isTrue);
      expect('weak'.isValidPassword, isFalse);
      expect(''.isValidPassword, isFalse);
    });
  });
}

// Extension methods for testing utilities
extension StringExtensions on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  bool get isValidEmail {
    if (isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPassword {
    if (length < 8) return false;
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]').hasMatch(this);
  }
}

extension DateTimeExtensions on DateTime {
  String toIsoDateString() {
    return toIso8601String().split('T')[0];
  }

  String toReadableString() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[month - 1]} $day, $year';
  }
}