class Article {
  final int id;
  final String feedId;
  final String? feedLogo;
  final String feedTitle;
  final String link;
  final int contentId;
  final int status;
  final String title;
  final String? summary;
  final String? thumbnailUrl;
  final DateTime publishedDate;
  final bool isRead;
  final bool isFavorite;
  final int? readProgress;
  final ArticleContent? content;

  Article({
    required this.id,
    required this.feedId,
    this.feedLogo,
    required this.feedTitle,
    required this.link,
    required this.contentId,
    required this.status,
    required this.title,
    this.summary,
    this.thumbnailUrl,
    required this.publishedDate,
    required this.isRead,
    required this.isFavorite,
    this.readProgress,
    this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json, {bool includeContent = false}) {
    ArticleContent? content;
    if (includeContent && json['content'] != null) {
      content = ArticleContent.fromJson(json['content']);
    }

    return Article(
      id: json['id'],
      feedId: json['feed_id'],
      feedLogo: json['feed_logo'],
      feedTitle: json['feed_title'],
      link: json['link'],
      contentId: json['content_id'],
      status: json['status'],
      title: json['title'],
      summary: json['summary'],
      thumbnailUrl: json['thumbnail_url'],
      publishedDate: DateTime.parse(json['published_date']),
      isRead: json['is_read'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      readProgress: json['read_progress'],
      content: content,
    );
  }

  // 创建带有新属性的副本
  Article copyWith({
    int? id,
    String? feedId,
    String? feedLogo,
    String? feedTitle,
    String? link,
    int? contentId,
    int? status,
    String? title,
    String? summary,
    String? thumbnailUrl,
    DateTime? publishedDate,
    bool? isRead,
    bool? isFavorite,
    int? readProgress,
    ArticleContent? content,
  }) {
    return Article(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      feedLogo: feedLogo ?? this.feedLogo,
      feedTitle: feedTitle ?? this.feedTitle,
      link: link ?? this.link,
      contentId: contentId ?? this.contentId,
      status: status ?? this.status,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      publishedDate: publishedDate ?? this.publishedDate,
      isRead: isRead ?? this.isRead,
      isFavorite: isFavorite ?? this.isFavorite,
      readProgress: readProgress ?? this.readProgress,
      content: content ?? this.content,
    );
  }
}

class ArticleContent {
  final int id;
  final String htmlContent;
  final String textContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  ArticleContent({
    required this.id,
    required this.htmlContent,
    required this.textContent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArticleContent.fromJson(Map<String, dynamic> json) {
    return ArticleContent(
      id: json['id'],
      htmlContent: json['html_content'],
      textContent: json['text_content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ReadingHistory {
  final int id;
  final String userId;
  final int articleId;
  final String feedId;
  final bool isFavorite;
  final bool isRead;
  final int readPosition;
  final int readProgress;
  final int readTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReadingHistory({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.feedId,
    required this.isFavorite,
    required this.isRead,
    required this.readPosition,
    required this.readProgress,
    required this.readTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      id: json['id'],
      userId: json['user_id'],
      articleId: json['article_id'],
      feedId: json['feed_id'],
      isFavorite: json['is_favorite'],
      isRead: json['is_read'],
      readPosition: json['read_position'],
      readProgress: json['read_progress'],
      readTime: json['read_time'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}