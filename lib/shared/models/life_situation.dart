import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'life_situation.g.dart';

@HiveType(typeId: 0)
class LifeSituation extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String mindfulApproach;
  
  @HiveField(4)
  final String practicalSteps;
  
  @HiveField(5)
  final String keyInsights;
  
  @HiveField(6)
  final String lifeArea;
  
  @HiveField(7)
  final List<String> tags;
  
  @HiveField(8)
  final int difficultyLevel; // 1-5
  
  @HiveField(9)
  final int estimatedReadTime; // minutes
  
  @HiveField(10)
  final String wellnessFocus; // stress, relationships, work, etc.
  
  // NEW: Voice-specific fields for Alexa and Apple Watch integration
  @HiveField(11)
  final List<String> voiceKeywords; // "toddler", "tantrum", "meltdown"
  
  @HiveField(12)
  final List<String> synonyms; // Alternative terms
  
  @HiveField(13)
  final String spokenTitle; // Voice-friendly version
  
  @HiveField(14)
  final String spokenActionSteps; // Conversational format
  
  @HiveField(15)
  final int voicePopularity; // Usage tracking for caching
  
  @HiveField(16)
  final String? audioResponseUrl; // Pre-generated audio responses
  
  @HiveField(17)
  final DateTime createdAt;
  
  @HiveField(18)
  final DateTime updatedAt;
  
  @HiveField(19)
  final bool isVoiceOptimized; // Flag for voice-ready content

  LifeSituation({
    String? id,
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
    List<String>? voiceKeywords,
    List<String>? synonyms,
    String? spokenTitle,
    String? spokenActionSteps,
    int? voicePopularity,
    this.audioResponseUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVoiceOptimized,
  }) : id = id ?? const Uuid().v4(),
       voiceKeywords = voiceKeywords ?? [],
       synonyms = synonyms ?? [],
       spokenTitle = spokenTitle ?? title,
       spokenActionSteps = spokenActionSteps ?? _generateSpokenSteps(practicalSteps),
       voicePopularity = voicePopularity ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       isVoiceOptimized = isVoiceOptimized ?? false;

  // Helper method to generate conversational action steps
  static String _generateSpokenSteps(String practicalSteps) {
    // Convert bullet points and formal text to conversational format
    return practicalSteps
        .replaceAll('•', 'First,')
        .replaceAll('\n•', '. Next,')
        .replaceAll('\n-', '. Also,')
        .replaceAll('\n', '. ')
        .replaceAll('  ', ' ')
        .trim();
  }

  // Create a copy with updated voice optimization
  LifeSituation copyWithVoiceOptimization({
    List<String>? voiceKeywords,
    List<String>? synonyms,
    String? spokenTitle,
    String? spokenActionSteps,
    String? audioResponseUrl,
    bool? isVoiceOptimized,
  }) {
    return LifeSituation(
      id: id,
      title: title,
      description: description,
      mindfulApproach: mindfulApproach,
      practicalSteps: practicalSteps,
      keyInsights: keyInsights,
      lifeArea: lifeArea,
      tags: tags,
      difficultyLevel: difficultyLevel,
      estimatedReadTime: estimatedReadTime,
      wellnessFocus: wellnessFocus,
      voiceKeywords: voiceKeywords ?? this.voiceKeywords,
      synonyms: synonyms ?? this.synonyms,
      spokenTitle: spokenTitle ?? this.spokenTitle,
      spokenActionSteps: spokenActionSteps ?? this.spokenActionSteps,
      voicePopularity: voicePopularity,
      audioResponseUrl: audioResponseUrl ?? this.audioResponseUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isVoiceOptimized: isVoiceOptimized ?? this.isVoiceOptimized,
    );
  }

  // Increment voice usage for popularity tracking
  LifeSituation incrementVoiceUsage() {
    return LifeSituation(
      id: id,
      title: title,
      description: description,
      mindfulApproach: mindfulApproach,
      practicalSteps: practicalSteps,
      keyInsights: keyInsights,
      lifeArea: lifeArea,
      tags: tags,
      difficultyLevel: difficultyLevel,
      estimatedReadTime: estimatedReadTime,
      wellnessFocus: wellnessFocus,
      voiceKeywords: voiceKeywords,
      synonyms: synonyms,
      spokenTitle: spokenTitle,
      spokenActionSteps: spokenActionSteps,
      voicePopularity: voicePopularity + 1,
      audioResponseUrl: audioResponseUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isVoiceOptimized: isVoiceOptimized,
    );
  }

  // Get all searchable terms for voice matching
  List<String> get allSearchableTerms {
    return [
      title.toLowerCase(),
      description.toLowerCase(),
      spokenTitle.toLowerCase(),
      ...voiceKeywords.map((k) => k.toLowerCase()),
      ...synonyms.map((s) => s.toLowerCase()),
      ...tags.map((t) => t.toLowerCase()),
      lifeArea.toLowerCase(),
      wellnessFocus.toLowerCase(),
    ].where((term) => term.isNotEmpty).toList();
  }

  // Check if this situation matches a voice query
  double matchesQuery(String query) {
    final queryWords = query.toLowerCase().split(' ');
    final searchTerms = allSearchableTerms;
    
    double score = 0.0;
    int totalWords = queryWords.length;
    
    for (final word in queryWords) {
      // Direct match in keywords (highest priority)
      if (voiceKeywords.any((k) => k.toLowerCase().contains(word))) {
        score += 3.0;
      }
      // Direct match in synonyms
      else if (synonyms.any((s) => s.toLowerCase().contains(word))) {
        score += 2.5;
      }
      // Match in title
      else if (title.toLowerCase().contains(word)) {
        score += 2.0;
      }
      // Match in tags
      else if (tags.any((t) => t.toLowerCase().contains(word))) {
        score += 1.5;
      }
      // Match in other searchable terms
      else if (searchTerms.any((term) => term.contains(word))) {
        score += 1.0;
      }
    }
    
    // Normalize score by query length and add popularity bonus
    double normalizedScore = score / totalWords;
    double popularityBonus = (voicePopularity / 100.0).clamp(0.0, 1.0);
    
    return normalizedScore + popularityBonus;
  }

  // Convert to JSON for API responses
  Map<String, dynamic> toJson() {
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
      'synonyms': synonyms,
      'spokenTitle': spokenTitle,
      'spokenActionSteps': spokenActionSteps,
      'voicePopularity': voicePopularity,
      'audioResponseUrl': audioResponseUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVoiceOptimized': isVoiceOptimized,
    };
  }

  // Create from JSON for API consumption
  factory LifeSituation.fromJson(Map<String, dynamic> json) {
    return LifeSituation(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mindfulApproach: json['mindfulApproach'] as String,
      practicalSteps: json['practicalSteps'] as String,
      keyInsights: json['keyInsights'] as String,
      lifeArea: json['lifeArea'] as String,
      tags: List<String>.from(json['tags'] as List),
      difficultyLevel: json['difficultyLevel'] as int,
      estimatedReadTime: json['estimatedReadTime'] as int,
      wellnessFocus: json['wellnessFocus'] as String,
      voiceKeywords: List<String>.from(json['voiceKeywords'] as List? ?? []),
      synonyms: List<String>.from(json['synonyms'] as List? ?? []),
      spokenTitle: json['spokenTitle'] as String?,
      spokenActionSteps: json['spokenActionSteps'] as String?,
      voicePopularity: json['voicePopularity'] as int? ?? 0,
      audioResponseUrl: json['audioResponseUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isVoiceOptimized: json['isVoiceOptimized'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'LifeSituation{id: $id, title: $title, voiceKeywords: $voiceKeywords, voicePopularity: $voicePopularity}';
  }
}