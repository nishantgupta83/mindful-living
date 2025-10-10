import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model with wellness tracking data
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final int wellnessScore;
  final int currentStreak;
  final DateTime joinedDate;
  final DateTime lastActiveDate;
  final Map<String, dynamic> preferences;
  final List<String> wellnessFocus;
  final UserSubscriptionType subscriptionType;
  final DateTime? subscriptionExpiry;
  final Map<String, int> categoryProgress;
  final List<String> achievementIds;
  final UserOnboardingStatus onboardingStatus;

  UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    required this.wellnessScore,
    required this.currentStreak,
    required this.joinedDate,
    required this.lastActiveDate,
    required this.preferences,
    required this.wellnessFocus,
    required this.subscriptionType,
    this.subscriptionExpiry,
    required this.categoryProgress,
    required this.achievementIds,
    required this.onboardingStatus,
  });

  factory UserProfile.createNew({
    required String uid,
    String? email,
    String? displayName,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      wellnessScore: 65,
      currentStreak: 0,
      joinedDate: DateTime.now(),
      lastActiveDate: DateTime.now(),
      preferences: {
        'notifications': true,
        'reminderTime': '09:00',
        'theme': 'light',
        'language': 'en',
      },
      wellnessFocus: [],
      subscriptionType: UserSubscriptionType.free,
      categoryProgress: {
        'Career': 0,
        'Relationships': 0,
        'Family': 0,
        'Health': 0,
        'Personal Growth': 0,
        'Financial': 0,
      },
      achievementIds: [],
      onboardingStatus: UserOnboardingStatus.notStarted,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      wellnessScore: map['wellnessScore'] ?? 65,
      currentStreak: map['currentStreak'] ?? 0,
      joinedDate: (map['joinedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: (map['lastActiveDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      wellnessFocus: List<String>.from(map['wellnessFocus'] ?? []),
      subscriptionType: UserSubscriptionType.values.firstWhere(
        (e) => e.toString() == map['subscriptionType'],
        orElse: () => UserSubscriptionType.free,
      ),
      subscriptionExpiry: (map['subscriptionExpiry'] as Timestamp?)?.toDate(),
      categoryProgress: Map<String, int>.from(map['categoryProgress'] ?? {}),
      achievementIds: List<String>.from(map['achievementIds'] ?? []),
      onboardingStatus: UserOnboardingStatus.values.firstWhere(
        (e) => e.toString() == map['onboardingStatus'],
        orElse: () => UserOnboardingStatus.notStarted,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'wellnessScore': wellnessScore,
      'currentStreak': currentStreak,
      'joinedDate': Timestamp.fromDate(joinedDate),
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'preferences': preferences,
      'wellnessFocus': wellnessFocus,
      'subscriptionType': subscriptionType.toString(),
      'subscriptionExpiry': subscriptionExpiry != null 
          ? Timestamp.fromDate(subscriptionExpiry!) 
          : null,
      'categoryProgress': categoryProgress,
      'achievementIds': achievementIds,
      'onboardingStatus': onboardingStatus.toString(),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    int? wellnessScore,
    int? currentStreak,
    DateTime? joinedDate,
    DateTime? lastActiveDate,
    Map<String, dynamic>? preferences,
    List<String>? wellnessFocus,
    UserSubscriptionType? subscriptionType,
    DateTime? subscriptionExpiry,
    Map<String, int>? categoryProgress,
    List<String>? achievementIds,
    UserOnboardingStatus? onboardingStatus,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      currentStreak: currentStreak ?? this.currentStreak,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      preferences: preferences ?? this.preferences,
      wellnessFocus: wellnessFocus ?? this.wellnessFocus,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      achievementIds: achievementIds ?? this.achievementIds,
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
    );
  }

  bool get isPremium => subscriptionType == UserSubscriptionType.premium;
  bool get isOnboardingComplete => onboardingStatus == UserOnboardingStatus.completed;
  
  String get wellnessLevel {
    if (wellnessScore >= 90) return 'Excellent';
    if (wellnessScore >= 80) return 'Very Good';
    if (wellnessScore >= 70) return 'Good';
    if (wellnessScore >= 60) return 'Fair';
    return 'Needs Attention';
  }

  String get streakText {
    if (currentStreak == 0) return 'Start your streak today!';
    if (currentStreak == 1) return '1 day streak';
    return '$currentStreak days streak';
  }
}

enum UserSubscriptionType {
  free,
  premium,
  family,
}

enum UserOnboardingStatus {
  notStarted,
  inProgress,
  completed,
}