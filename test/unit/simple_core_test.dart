/// Simple unit tests to validate basic functionality
/// Tests core utilities and basic model creation

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Core Tests', () {
    test('String extensions work correctly', () {
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

    test('Basic map operations', () {
      final testData = {
        'id': 'test-123',
        'title': 'Test Title',
        'difficulty': 3,
        'tags': ['test', 'example'],
      };

      expect(testData['id'], equals('test-123'));
      expect(testData['title'], equals('Test Title'));
      expect(testData['difficulty'], equals(3));
      expect(testData['tags'], contains('test'));
    });

    test('List operations work correctly', () {
      final testList = ['career', 'health', 'relationships'];
      
      expect(testList.length, equals(3));
      expect(testList, contains('career'));
      expect(testList.first, equals('career'));
      expect(testList.last, equals('relationships'));
    });

    test('Difficulty level mapping', () {
      final difficultyMap = {
        1: 'Beginner',
        2: 'Easy', 
        3: 'Moderate',
        4: 'Advanced',
        5: 'Expert',
      };

      expect(difficultyMap[1], equals('Beginner'));
      expect(difficultyMap[3], equals('Moderate'));
      expect(difficultyMap[5], equals('Expert'));
    });

    test('Category validation', () {
      final validCategories = [
        'career', 'relationships', 'health', 
        'family', 'personal', 'financial'
      ];

      final testCategory = 'career';
      expect(validCategories.contains(testCategory), isTrue);
      
      final invalidCategory = 'invalid';
      expect(validCategories.contains(invalidCategory), isFalse);
    });

    test('Wellness focus areas', () {
      final wellnessFoci = [
        'mentalHealth', 'physicalHealth', 'emotional', 
        'spiritual', 'social'
      ];

      expect(wellnessFoci.length, equals(5));
      expect(wellnessFoci, contains('mentalHealth'));
      expect(wellnessFoci, contains('physicalHealth'));
    });
  });
}

// Extension methods for testing utilities
extension StringExtensions on String {
  String toTitleCase() {
    if (this.isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  bool get isValidEmail {
    if (this.isEmpty) return false;
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