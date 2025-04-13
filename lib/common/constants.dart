// lib/common/constants.dart
class ApiConstants {
  // API基础URL
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // 认证相关API
  static const String login = '/api/client/v1/auth/login_by_token';
  static const String validateToken = '/api/client/v1/auth/validate';
  static const String refreshToken = '/api/client/v1/auth/refresh_token';
  static const String logout = '/api/client/v1/auth/logout';
  
  // 用户相关API
  static const String userInfo = '/api/client/v1/user/info';
  static const String updateUser = '/api/client/v1/user/update';
  static const String userStats = '/api/client/v1/user/stats';
  static const String userHistory = '/api/client/v1/user/history';
  static const String userFavorites = '/api/client/v1/user/favorites';
  
  // 订阅相关API
  static const String subscriptionList = '/api/client/v1/subscription/list';
  static const String addSubscription = '/api/client/v1/subscription/add';
  static const String updateSubscription = '/api/client/v1/subscription/update';
  static const String removeSubscription = '/api/client/v1/subscription/remove';
  static const String subscriptionGroups = '/api/client/v1/subscription/groups';
  
  // Feed相关API
  static const String discoverFeed = '/api/client/v1/feed/discover';
  static const String feedDetail = '/api/client/v1/feed/detail';
  static const String feedCategories = '/api/client/v1/feed/categories';
  static const String discoverByUrl = '/api/client/v1/feed/discover_by_url';
  static const String requestAddFeed = '/api/client/v1/feed/request_add';
  
  // 文章相关API
  static const String feedArticles = '/api/client/v1/article/feed_articles';
  static const String articleDetail = '/api/client/v1/article/detail';
  static const String updateReading = '/api/client/v1/article/update_reading';
  static const String toggleFavorite = '/api/client/v1/article/toggle_favorite';
  static const String markRead = '/api/client/v1/article/mark_read';
  static const String markAllRead = '/api/client/v1/article/mark_all_read';
  static const String unreadCount = '/api/client/v1/article/unread_count';
  
  // 热点相关API
  static const String hottopicDaily = '/api/client/v1/hottopic/daily';
  static const String hottopicConsolidated = '/api/client/v1/hottopic/consolidated';
  
  // AI相关API
  static const String aiSummarize = '/api/client/v1/assistant/article_summarize';
}