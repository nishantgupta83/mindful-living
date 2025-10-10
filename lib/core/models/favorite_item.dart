import 'package:cloud_firestore/cloud_firestore.dart';

/// Favorite item model with AI-powered categorization and insights
class FavoriteItem {
  final String id;
  final String userId;
  final String itemId;
  final FavoriteItemType type;
  final String title;
  final String description;
  final DateTime addedAt;
  final DateTime lastAccessedAt;
  final int accessCount;
  final String? aiCategory;
  final String? aiInsight;
  final Map<String, dynamic> metadata;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.title,
    required this.description,
    required this.addedAt,
    required this.lastAccessedAt,
    required this.accessCount,
    this.aiCategory,
    this.aiInsight,
    required this.metadata,
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      type: FavoriteItemType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => FavoriteItemType.lifeSituation,
      ),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAccessedAt: (map['lastAccessedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      accessCount: map['accessCount'] ?? 0,
      aiCategory: map['aiCategory'],
      aiInsight: map['aiInsight'],
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'type': type.toString(),
      'title': title,
      'description': description,
      'addedAt': Timestamp.fromDate(addedAt),
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'accessCount': accessCount,
      'aiCategory': aiCategory,
      'aiInsight': aiInsight,
      'metadata': metadata,
    };
  }

  FavoriteItem copyWith({
    String? id,
    String? userId,
    String? itemId,
    FavoriteItemType? type,
    String? title,
    String? description,
    DateTime? addedAt,
    DateTime? lastAccessedAt,
    int? accessCount,
    String? aiCategory,
    String? aiInsight,
    Map<String, dynamic>? metadata,
  }) {
    return FavoriteItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      addedAt: addedAt ?? this.addedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
      aiCategory: aiCategory ?? this.aiCategory,
      aiInsight: aiInsight ?? this.aiInsight,
      metadata: metadata ?? this.metadata,
    );
  }

  String get categoryDisplayName => aiCategory ?? 'Uncategorized';
  
  bool get isRecentlyAdded {
    final difference = DateTime.now().difference(addedAt);
    return difference.inDays <= 7;
  }

  bool get isFrequentlyAccessed => accessCount >= 5;

  String get accessFrequencyText {
    if (accessCount == 0) return 'Not accessed yet';
    if (accessCount == 1) return 'Accessed once';
    if (accessCount < 5) return 'Accessed $accessCount times';
    if (accessCount < 10) return 'Frequently accessed';
    return 'Very popular';
  }

  String get timeAgoText {
    final now = DateTime.now();
    final difference = now.difference(addedAt);

    if (difference.inDays > 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }
}

/// Types of items that can be favorited
enum FavoriteItemType {
  lifeSituation,
  wellnessPractice,
  journalEntry,
  goal,
}