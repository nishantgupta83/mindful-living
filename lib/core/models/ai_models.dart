import 'package:cloud_firestore/cloud_firestore.dart';

/// AI Personality Profile model for user personalization
class AIPersonalityProfile {
  final String userId;
  final String preferredContentStyle; // 'practical', 'mindful', 'balanced'
  final String complexityPreference; // 'simple', 'detailed', 'adaptive'
  final List<String> primaryInterests;
  final Map<String, double> categoryAffinities;
  final double engagementThreshold;
  final String communicationStyle; // 'direct', 'gentle', 'encouraging'
  final List<String> avoidanceTopics;
  final DateTime lastUpdated;
  final int dataPoints; // Number of interactions used for profiling

  AIPersonalityProfile({
    required this.userId,
    required this.preferredContentStyle,
    required this.complexityPreference,
    required this.primaryInterests,
    required this.categoryAffinities,
    required this.engagementThreshold,
    required this.communicationStyle,
    required this.avoidanceTopics,
    required this.lastUpdated,
    required this.dataPoints,
  });

  factory AIPersonalityProfile.createDefault() {
    return AIPersonalityProfile(
      userId: '',
      preferredContentStyle: 'balanced',
      complexityPreference: 'adaptive',
      primaryInterests: [],
      categoryAffinities: {
        'Career': 0.5,
        'Relationships': 0.5,
        'Family': 0.5,
        'Health': 0.5,
        'Personal Growth': 0.5,
        'Financial': 0.5,
      },
      engagementThreshold: 0.6,
      communicationStyle: 'encouraging',
      avoidanceTopics: [],
      lastUpdated: DateTime.now(),
      dataPoints: 0,
    );
  }

  factory AIPersonalityProfile.fromMap(Map<String, dynamic> map) {
    return AIPersonalityProfile(
      userId: map['userId'] ?? '',
      preferredContentStyle: map['preferredContentStyle'] ?? 'balanced',
      complexityPreference: map['complexityPreference'] ?? 'adaptive',
      primaryInterests: List<String>.from(map['primaryInterests'] ?? []),
      categoryAffinities: Map<String, double>.from(map['categoryAffinities'] ?? {}),
      engagementThreshold: (map['engagementThreshold'] ?? 0.6).toDouble(),
      communicationStyle: map['communicationStyle'] ?? 'encouraging',
      avoidanceTopics: List<String>.from(map['avoidanceTopics'] ?? []),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataPoints: map['dataPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'preferredContentStyle': preferredContentStyle,
      'complexityPreference': complexityPreference,
      'primaryInterests': primaryInterests,
      'categoryAffinities': categoryAffinities,
      'engagementThreshold': engagementThreshold,
      'communicationStyle': communicationStyle,
      'avoidanceTopics': avoidanceTopics,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'dataPoints': dataPoints,
    };
  }

  AIPersonalityProfile copyWith({
    String? userId,
    String? preferredContentStyle,
    String? complexityPreference,
    List<String>? primaryInterests,
    Map<String, double>? categoryAffinities,
    double? engagementThreshold,
    String? communicationStyle,
    List<String>? avoidanceTopics,
    DateTime? lastUpdated,
    int? dataPoints,
  }) {
    return AIPersonalityProfile(
      userId: userId ?? this.userId,
      preferredContentStyle: preferredContentStyle ?? this.preferredContentStyle,
      complexityPreference: complexityPreference ?? this.complexityPreference,
      primaryInterests: primaryInterests ?? this.primaryInterests,
      categoryAffinities: categoryAffinities ?? this.categoryAffinities,
      engagementThreshold: engagementThreshold ?? this.engagementThreshold,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      avoidanceTopics: avoidanceTopics ?? this.avoidanceTopics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }
}

/// AI-generated insight model
class AIInsight {
  final String id;
  final String userId;
  final AIInsightType type;
  final String title;
  final String content;
  final double confidence; // 0.0 to 1.0
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isRead;
  final int? relevanceScore;

  AIInsight({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.confidence,
    required this.metadata,
    required this.createdAt,
    this.isRead = false,
    this.relevanceScore,
  });

  factory AIInsight.fromMap(Map<String, dynamic> map) {
    return AIInsight(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: AIInsightType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => AIInsightType.general,
      ),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      relevanceScore: map['relevanceScore'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'title': title,
      'content': content,
      'confidence': confidence,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'relevanceScore': relevanceScore,
    };
  }

  AIInsight copyWith({
    String? id,
    String? userId,
    AIInsightType? type,
    String? title,
    String? content,
    double? confidence,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isRead,
    int? relevanceScore,
  }) {
    return AIInsight(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }
}

/// Types of AI insights
enum AIInsightType {
  general,
  situationAdvice,
  moodPattern,
  progressTracking,
  goalSuggestion,
  contentRecommendation,
  behaviorAnalysis,
  wellnessAlert,
}

/// Content recommendation model
class ContentRecommendation {
  final String id;
  final ContentRecommendationType type;
  final String title;
  final String description;
  final double score; // 0.0 to 1.0
  final String reason;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool isConsumed;
  final DateTime? consumedAt;

  ContentRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.score,
    required this.reason,
    required this.metadata,
    required this.createdAt,
    this.isConsumed = false,
    this.consumedAt,
  });

  factory ContentRecommendation.fromMap(Map<String, dynamic> map) {
    return ContentRecommendation(
      id: map['id'] ?? '',
      type: ContentRecommendationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ContentRecommendationType.lifeSituation,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      reason: map['reason'] ?? '',
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isConsumed: map['isConsumed'] ?? false,
      consumedAt: (map['consumedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'score': score,
      'reason': reason,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
      'isConsumed': isConsumed,
      'consumedAt': consumedAt != null ? Timestamp.fromDate(consumedAt!) : null,
    };
  }
}

/// Types of content recommendations
enum ContentRecommendationType {
  lifeSituation,
  wellnessPractice,
  journalPrompt,
  mindfulnessExercise,
  goalSuggestion,
  communityContent,
}

/// Mood analysis model
class MoodAnalysis {
  final double averageMood; // 1.0 to 10.0
  final MoodTrend moodTrend;
  final List<String> insights;
  final List<String> recommendations;
  final List<MoodDataPoint> dataPoints;
  final int periodDays;
  final DateTime generatedAt;

  MoodAnalysis({
    required this.averageMood,
    required this.moodTrend,
    required this.insights,
    required this.recommendations,
    required this.dataPoints,
    required this.periodDays,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  factory MoodAnalysis.fromMap(Map<String, dynamic> map) {
    return MoodAnalysis(
      averageMood: (map['averageMood'] ?? 5.0).toDouble(),
      moodTrend: MoodTrend.values.firstWhere(
        (e) => e.toString() == map['moodTrend'],
        orElse: () => MoodTrend.stable,
      ),
      insights: List<String>.from(map['insights'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      dataPoints: (map['dataPoints'] as List<dynamic>? ?? [])
          .map((e) => MoodDataPoint.fromMap(e))
          .toList(),
      periodDays: map['periodDays'] ?? 30,
      generatedAt: (map['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'averageMood': averageMood,
      'moodTrend': moodTrend.toString(),
      'insights': insights,
      'recommendations': recommendations,
      'dataPoints': dataPoints.map((e) => e.toMap()).toList(),
      'periodDays': periodDays,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }
}

/// Mood trend directions
enum MoodTrend {
  improving,
  declining,
  stable,
  volatile,
}

/// Individual mood data point
class MoodDataPoint {
  final DateTime date;
  final double mood; // 1.0 to 10.0
  final List<String> emotions;
  final String? note;

  MoodDataPoint({
    required this.date,
    required this.mood,
    required this.emotions,
    this.note,
  });

  factory MoodDataPoint.fromMap(Map<String, dynamic> map) {
    return MoodDataPoint(
      date: (map['date'] as Timestamp).toDate(),
      mood: (map['mood'] ?? 5.0).toDouble(),
      emotions: List<String>.from(map['emotions'] ?? []),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'mood': mood,
      'emotions': emotions,
      'note': note,
    };
  }
}

/// Wellness goal model with AI-generated targets
class WellnessGoal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final WellnessGoalType type;
  final Map<String, dynamic> target;
  final Map<String, dynamic> progress;
  final DateTime startDate;
  final DateTime targetDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final double aiConfidence;
  final List<String> milestones;

  WellnessGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.progress,
    required this.startDate,
    required this.targetDate,
    required this.isCompleted,
    this.completedAt,
    required this.aiConfidence,
    required this.milestones,
  });

  factory WellnessGoal.fromMap(Map<String, dynamic> map) {
    return WellnessGoal(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: WellnessGoalType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => WellnessGoalType.mindfulness,
      ),
      target: Map<String, dynamic>.from(map['target'] ?? {}),
      progress: Map<String, dynamic>.from(map['progress'] ?? {}),
      startDate: (map['startDate'] as Timestamp).toDate(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      aiConfidence: (map['aiConfidence'] ?? 0.0).toDouble(),
      milestones: List<String>.from(map['milestones'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.toString(),
      'target': target,
      'progress': progress,
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': Timestamp.fromDate(targetDate),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'aiConfidence': aiConfidence,
      'milestones': milestones,
    };
  }
}

/// Types of wellness goals
enum WellnessGoalType {
  mindfulness,
  physicalActivity,
  sleepHygiene,
  stressReduction,
  emotionalWellbeing,
  socialConnection,
  personalGrowth,
  workLifeBalance,
}

/// AI conversation context for voice interactions
class AIConversationContext {
  final String sessionId;
  final String userId;
  final List<ConversationTurn> turns;
  final Map<String, dynamic> context;
  final DateTime lastActivity;
  final ConversationMood mood;

  AIConversationContext({
    required this.sessionId,
    required this.userId,
    required this.turns,
    required this.context,
    required this.lastActivity,
    required this.mood,
  });

  factory AIConversationContext.fromMap(Map<String, dynamic> map) {
    return AIConversationContext(
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      turns: (map['turns'] as List<dynamic>? ?? [])
          .map((e) => ConversationTurn.fromMap(e))
          .toList(),
      context: Map<String, dynamic>.from(map['context'] ?? {}),
      lastActivity: (map['lastActivity'] as Timestamp).toDate(),
      mood: ConversationMood.values.firstWhere(
        (e) => e.toString() == map['mood'],
        orElse: () => ConversationMood.neutral,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'turns': turns.map((e) => e.toMap()).toList(),
      'context': context,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'mood': mood.toString(),
    };
  }
}

/// Individual conversation turn
class ConversationTurn {
  final String speaker; // 'user' or 'ai'
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  ConversationTurn({
    required this.speaker,
    required this.message,
    required this.timestamp,
    required this.metadata,
  });

  factory ConversationTurn.fromMap(Map<String, dynamic> map) {
    return ConversationTurn(
      speaker: map['speaker'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speaker': speaker,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }
}

/// Conversation mood states
enum ConversationMood {
  positive,
  neutral,
  concerned,
  supportive,
  exploratory,
}