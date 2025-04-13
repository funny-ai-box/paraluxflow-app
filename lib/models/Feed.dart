class Feed {
  final String id;
  final String url;
  final String title;
  final String? logo;
  final String? description;
  final int? categoryId;
  final bool isActive;
  final DateTime? lastFetchAt;
  final bool isSubscribed;

  Feed({
    required this.id,
    required this.url,
    required this.title,
    this.logo,
    this.description,
    this.categoryId,
    required this.isActive,
    this.lastFetchAt,
    this.isSubscribed = false,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      logo: json['logo'],
      description: json['description'],
      categoryId: json['category_id'],
      isActive: json['is_active'] ?? true,
      lastFetchAt: json['last_fetch_at'] != null 
          ? DateTime.parse(json['last_fetch_at']) 
          : null,
      isSubscribed: json['is_subscribed'] ?? false,
    );
  }

  // 创建一个新的Feed实例，可以覆盖特定属性
  Feed copyWith({
    String? id,
    String? url,
    String? title,
    String? logo,
    String? description,
    int? categoryId,
    bool? isActive,
    DateTime? lastFetchAt,
    bool? isSubscribed,
  }) {
    return Feed(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      lastFetchAt: lastFetchAt ?? this.lastFetchAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

class FeedCategory {
  final int id;
  final String name;
  final bool isDelete;

  FeedCategory({
    required this.id,
    required this.name,
    required this.isDelete,
  });

  factory FeedCategory.fromJson(Map<String, dynamic> json) {
    return FeedCategory(
      id: json['id'],
      name: json['name'],
      isDelete: json['is_delete'] == 1,
    );
  }
}