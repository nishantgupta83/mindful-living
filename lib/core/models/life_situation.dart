import 'package:cloud_firestore/cloud_firestore.dart';

/// Life situation model representing wellness guidance content
class LifeSituation {
  final String id;
  final String title;
  final String description;
  final String mindfulApproach;
  final List<String> practicalSteps;
  final List<String> keyInsights;
  final String lifeArea;
  final List<String> tags;
  final int difficultyLevel; // 1-5
  final int estimatedReadTime; // minutes
  final List<String> wellnessFocus;
  final List<String> voiceKeywords;
  final String spokenTitle;
  final List<String> spokenActionSteps;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final Map<String, dynamic> metadata;

  LifeSituation({
    required this.id,
    required this.title,
    required this.description,
    required this.mindfulApproach,
    required this.practicalSteps,
    required this.keyInsights,
    required this.lifeArea,
    required this.tags,
    required this.difficultyLevel,
    required this.estimatedReadTime,
    required this.wellnessFocus,
    required this.voiceKeywords,
    required this.spokenTitle,
    required this.spokenActionSteps,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.metadata,
  });

  factory LifeSituation.fromMap(Map<String, dynamic> map) {
    return LifeSituation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      mindfulApproach: map['mindfulApproach'] ?? '',
      practicalSteps: List<String>.from(map['practicalSteps'] ?? []),
      keyInsights: List<String>.from(map['keyInsights'] ?? []),
      lifeArea: map['lifeArea'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      difficultyLevel: map['difficultyLevel'] ?? 1,
      estimatedReadTime: map['estimatedReadTime'] ?? 3,
      wellnessFocus: List<String>.from(map['wellnessFocus'] ?? []),
      voiceKeywords: List<String>.from(map['voiceKeywords'] ?? []),
      spokenTitle: map['spokenTitle'] ?? '',
      spokenActionSteps: List<String>.from(map['spokenActionSteps'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mindfulApproach': mindfulApproach,
      'practicalSteps': practicalSteps,
      'keyInsights': keyInsights,
      'lifeArea': lifeArea,
      'tags': tags,
      'difficultyLevel': difficultyLevel,
      'estimatedReadTime': estimatedReadTime,
      'wellnessFocus': wellnessFocus,
      'voiceKeywords': voiceKeywords,
      'spokenTitle': spokenTitle,
      'spokenActionSteps': spokenActionSteps,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  LifeSituation copyWith({
    String? id,
    String? title,
    String? description,
    String? mindfulApproach,
    List<String>? practicalSteps,
    List<String>? keyInsights,
    String? lifeArea,
    List<String>? tags,
    int? difficultyLevel,
    int? estimatedReadTime,
    List<String>? wellnessFocus,
    List<String>? voiceKeywords,
    String? spokenTitle,
    List<String>? spokenActionSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) {
    return LifeSituation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mindfulApproach: mindfulApproach ?? this.mindfulApproach,
      practicalSteps: practicalSteps ?? this.practicalSteps,
      keyInsights: keyInsights ?? this.keyInsights,
      lifeArea: lifeArea ?? this.lifeArea,
      tags: tags ?? this.tags,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
      wellnessFocus: wellnessFocus ?? this.wellnessFocus,
      voiceKeywords: voiceKeywords ?? this.voiceKeywords,
      spokenTitle: spokenTitle ?? this.spokenTitle,
      spokenActionSteps: spokenActionSteps ?? this.spokenActionSteps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
    );
  }

  String get difficultyText {
    switch (difficultyLevel) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Easy';
      case 3:
        return 'Moderate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return 'Unknown';
    }
  }

  String get readTimeText {
    if (estimatedReadTime <= 1) return '1 min read';
    return '$estimatedReadTime min read';
  }

  bool matchesKeywords(List<String> keywords) {
    final allText = '$title $description ${tags.join(' ')} ${voiceKeywords.join(' ')}'.toLowerCase();
    return keywords.any((keyword) => allText.contains(keyword.toLowerCase()));
  }

  bool isInCategory(String category) {
    return lifeArea.toLowerCase() == category.toLowerCase();
  }

  bool hasWellnessFocus(String focus) {
    return wellnessFocus.any((f) => f.toLowerCase() == focus.toLowerCase());
  }
}