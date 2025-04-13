import 'package:lazyreader/models/Feed.dart';

class Subscription {
  final int id;
  final String userId;
  final String feedId;
  final int? groupId;
  final bool isFavorite;
  final String? customTitle;
  final int readCount;
  final int unreadCount;
  final DateTime? lastReadAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Feed? feed; // 关联的Feed对象

  Subscription({
    required this.id,
    required this.userId,
    required this.feedId,
    this.groupId,
    required this.isFavorite,
    this.customTitle,
    required this.readCount,
    required this.unreadCount,
    this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
    this.feed,
  });

  factory Subscription.fromJson(Map<String, dynamic> json, {Feed? feed}) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      feedId: json['feed_id'],
      groupId: json['group_id'],
      isFavorite: json['is_favorite'],
      customTitle: json['custom_title'],
      readCount: json['read_count'],
      unreadCount: json['unread_count'],
      lastReadAt: json['last_read_at'] != null 
          ? DateTime.parse(json['last_read_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      feed: feed ?? (json['feed'] != null ? Feed.fromJson(json['feed']) : null),
    );
  }

  // 创建一个新的Subscription实例，可以覆盖特定属性
  Subscription copyWith({
    int? id,
    String? userId,
    String? feedId,
    int? groupId,
    bool? isFavorite,
    String? customTitle,
    int? readCount,
    int? unreadCount,
    DateTime? lastReadAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Feed? feed,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      feedId: feedId ?? this.feedId,
      groupId: groupId ?? this.groupId,
      isFavorite: isFavorite ?? this.isFavorite,
      customTitle: customTitle ?? this.customTitle,
      readCount: readCount ?? this.readCount,
      unreadCount: unreadCount ?? this.unreadCount,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      feed: feed ?? this.feed,
    );
  }

  // 获取显示的标题（自定义标题或Feed标题）
  String get displayTitle {
    if (customTitle != null && customTitle!.isNotEmpty) {
      return customTitle!;
    }
    return feed?.title ?? "未知订阅源";
  }
}

class SubscriptionGroup {
  final int id;
  final String userId;
  final String name;
  final int sortOrder;
  final int feedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionGroup({
    required this.id,
    required this.userId,
    required this.name,
    required this.sortOrder,
    required this.feedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionGroup.fromJson(Map<String, dynamic> json) {
    return SubscriptionGroup(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      sortOrder: json['sort_order'],
      feedCount: json['feed_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}