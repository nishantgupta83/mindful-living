// Mock Firebase Service - Will be replaced with actual Firebase integration
import 'dart:math';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final Random _random = Random();

  // Dilemma/Life Situations
  Future<List<Map<String, dynamic>>> getDilemmas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {
        'id': '1',
        'title': 'Work-Life Balance',
        'description': 'Struggling to maintain boundaries between work and personal life',
        'category': 'Career',
        'mindfulApproach': 'Practice setting clear boundaries. Remember that rest is productive.',
        'practicalSteps': ['Set specific work hours', 'Create a shutdown ritual', 'Communicate boundaries clearly'],
        'wellnessFocus': 'Mental Health',
        'difficulty': 'Medium',
        'views': 1234,
      },
      {
        'id': '2',
        'title': 'Relationship Conflict',
        'description': 'Dealing with misunderstandings in personal relationships',
        'category': 'Relationships',
        'mindfulApproach': 'Listen with empathy, speak with kindness. Every conflict is an opportunity for growth.',
        'practicalSteps': ['Practice active listening', 'Use "I" statements', 'Take breaks when heated'],
        'wellnessFocus': 'Emotional Health',
        'difficulty': 'High',
        'views': 2341,
      },
      {
        'id': '3',
        'title': 'Financial Stress',
        'description': 'Managing anxiety about money and financial future',
        'category': 'Finance',
        'mindfulApproach': 'Focus on what you can control. Gratitude for what you have reduces anxiety.',
        'practicalSteps': ['Create a budget', 'Build emergency fund', 'Seek financial advice'],
        'wellnessFocus': 'Stress Management',
        'difficulty': 'High',
        'views': 3456,
      },
      {
        'id': '4',
        'title': 'Career Change Decision',
        'description': 'Contemplating a major career shift',
        'category': 'Career',
        'mindfulApproach': 'Trust your intuition. Growth happens outside comfort zones.',
        'practicalSteps': ['List pros and cons', 'Talk to mentors', 'Create transition plan'],
        'wellnessFocus': 'Personal Growth',
        'difficulty': 'High',
        'views': 987,
      },
      {
        'id': '5',
        'title': 'Social Anxiety',
        'description': 'Feeling uncomfortable in social situations',
        'category': 'Mental Health',
        'mindfulApproach': 'Be gentle with yourself. Small steps lead to big changes.',
        'practicalSteps': ['Start with small groups', 'Practice breathing exercises', 'Prepare conversation topics'],
        'wellnessFocus': 'Anxiety Management',
        'difficulty': 'Medium',
        'views': 4567,
      },
    ];
  }

  // Journal Entries
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {
        'id': '1',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'mood': 'Happy',
        'content': 'Had a great day today. Practiced meditation for 20 minutes.',
        'gratitude': ['Family time', 'Good health', 'Beautiful weather'],
        'wellness': 90,
      },
      {
        'id': '2',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'mood': 'Calm',
        'content': 'Feeling peaceful after morning yoga session.',
        'gratitude': ['Morning coffee', 'Supportive friends', 'New opportunities'],
        'wellness': 85,
      },
      {
        'id': '3',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'mood': 'Thoughtful',
        'content': 'Reflected on my goals and made some important decisions.',
        'gratitude': ['Clear mind', 'Time to think', 'Progress made'],
        'wellness': 75,
      },
    ];
  }

  Future<void> saveJournalEntry(Map<String, dynamic> entry) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real implementation, save to Firestore
  }

  // Practices/Exercises
  Future<List<Map<String, dynamic>>> getPractices() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': '1',
        'title': 'Box Breathing',
        'description': 'A simple technique to calm your mind',
        'duration': '5 min',
        'type': 'Breathing',
        'difficulty': 'Beginner',
        'benefits': ['Reduces stress', 'Improves focus', 'Calms anxiety'],
        'icon': '🫁',
      },
      {
        'id': '2',
        'title': 'Body Scan',
        'description': 'Progressive relaxation through body awareness',
        'duration': '10 min',
        'type': 'Meditation',
        'difficulty': 'Beginner',
        'benefits': ['Releases tension', 'Improves sleep', 'Increases awareness'],
        'icon': '🧘',
      },
      {
        'id': '3',
        'title': 'Gratitude Practice',
        'description': 'Cultivate appreciation for life\'s blessings',
        'duration': '3 min',
        'type': 'Reflection',
        'difficulty': 'Beginner',
        'benefits': ['Boosts happiness', 'Improves relationships', 'Reduces negativity'],
        'icon': '🙏',
      },
      {
        'id': '4',
        'title': 'Walking Meditation',
        'description': 'Mindful movement in nature',
        'duration': '15 min',
        'type': 'Movement',
        'difficulty': 'Intermediate',
        'benefits': ['Physical exercise', 'Mental clarity', 'Connection with nature'],
        'icon': '🚶',
      },
      {
        'id': '5',
        'title': 'Loving-Kindness',
        'description': 'Send compassion to yourself and others',
        'duration': '10 min',
        'type': 'Meditation',
        'difficulty': 'Intermediate',
        'benefits': ['Increases empathy', 'Reduces anger', 'Improves relationships'],
        'icon': '❤️',
      },
    ];
  }

  // User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'name': 'Mindful User',
      'email': 'user@mindful.com',
      'joinDate': DateTime.now().subtract(const Duration(days: 30)),
      'streak': 7,
      'totalSessions': 45,
      'totalMinutes': 890,
      'favoritesPractices': ['Box Breathing', 'Body Scan'],
      'wellnessScore': 85,
      'badges': ['Early Bird', '7 Day Streak', 'Meditation Master'],
    };
  }

  Future<void> updateUserProfile(Map<String, dynamic> profile) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, update Firestore
  }

  // Analytics
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    // In real implementation, log to Firebase Analytics
    print('Event: $eventName, Parameters: $parameters');
  }

  // Wellness Score
  Future<int> getWellnessScore() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 75 + _random.nextInt(20);
  }

  // Search
  Future<List<Map<String, dynamic>>> searchContent(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final allDilemmas = await getDilemmas();
    return allDilemmas.where((item) => 
      item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
      item['description'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Categories
  List<String> getCategories() {
    return ['All', 'Career', 'Relationships', 'Finance', 'Mental Health', 'Family', 'Health'];
  }

  // Search dilemmas based on query
  Future<List<Map<String, dynamic>>> searchDilemmas(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final dilemmas = await getDilemmas();

    if (query.isEmpty) return dilemmas;

    final searchQuery = query.toLowerCase();
    return dilemmas.where((dilemma) {
      final title = dilemma['title'].toString().toLowerCase();
      final description = dilemma['description'].toString().toLowerCase();
      final category = dilemma['category'].toString().toLowerCase();
      final mindfulApproach = dilemma['mindfulApproach'].toString().toLowerCase();
      final wellnessFocus = dilemma['wellnessFocus'].toString().toLowerCase();

      return title.contains(searchQuery) ||
          description.contains(searchQuery) ||
          category.contains(searchQuery) ||
          mindfulApproach.contains(searchQuery) ||
          wellnessFocus.contains(searchQuery);
    }).toList();
  }

  // Get AI chat response for dilemma queries
  Future<Map<String, dynamic>> getChatResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Search for related dilemmas
    final relatedDilemmas = await searchDilemmas(message);

    // Generate response based on found dilemmas
    if (relatedDilemmas.isNotEmpty) {
      final dilemma = relatedDilemmas.first;
      return {
        'message': 'I found something that might help with your situation about "${dilemma['title']}". ${dilemma['mindfulApproach']}',
        'relatedDilemmas': relatedDilemmas.take(3).toList(),
        'suggestions': [
          'Tell me more about ${dilemma['category'].toString().toLowerCase()} challenges',
          'How to handle ${dilemma['wellnessFocus'].toString().toLowerCase()}',
          'Practical steps for ${dilemma['title'].toString().toLowerCase()}',
        ],
      };
    } else {
      return {
        'message': 'I understand you\'re looking for guidance. Could you tell me more about what specific area you need help with? You can explore categories like Career, Relationships, Mental Health, or Family.',
        'relatedDilemmas': [],
        'suggestions': [
          'How to manage work stress',
          'Dealing with relationship conflicts',
          'Finding work-life balance',
          'Managing financial anxiety',
        ],
      };
    }
  }

  // Mood tracking
  Future<void> trackMood(String mood) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In real implementation, save to Firestore
  }

  Future<List<Map<String, dynamic>>> getMoodHistory() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      {'date': DateTime.now(), 'mood': 'Happy', 'score': 90},
      {'date': DateTime.now().subtract(const Duration(days: 1)), 'mood': 'Calm', 'score': 80},
      {'date': DateTime.now().subtract(const Duration(days: 2)), 'mood': 'Stressed', 'score': 60},
      {'date': DateTime.now().subtract(const Duration(days: 3)), 'mood': 'Happy', 'score': 85},
      {'date': DateTime.now().subtract(const Duration(days: 4)), 'mood': 'Anxious', 'score': 50},
    ];
  }
}