import 'package:lazyreader/models/Article.dart';
import 'package:lazyreader/utils/http_util.dart';

class ArticleService {
  // 获取指定Feed的文章列表
  Future<Map<String, dynamic>> getFeedArticles({
    required String feedId,
    int page = 1,
    int perPage = 20,
  }) async {
    final path = '/api/client/v1/article/feed_articles';
    final Map<String, dynamic> parameters = {
      'feed_id': feedId,
      'page': page,
      'per_page': perPage,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: parameters,
      );

      final List<Article> articles = (response['data']['list'] as List)
          .map((item) => Article.fromJson(item))
          .toList();

      return {
        'articles': articles,
        'total': response['data']['total'],
        'pages': response['data']['pages'],
        'current_page': response['data']['current_page'],
        'per_page': response['data']['per_page'],
      };
    } catch (e) {
      print('获取Feed文章列表失败: $e');
      throw Exception('获取文章列表失败');
    }
  }

  // 获取文章详情
  Future<Map<String, dynamic>> getArticleDetail(int articleId) async {
    final path = '/api/client/v1/article/detail';
    final Map<String, dynamic> parameters = {
      'article_id': articleId,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: parameters,
      );

      final Article article = Article.fromJson(
        response['data']['article'],
        includeContent: true,
      );
      
      final ReadingHistory? reading = response['data']['reading'] != null
          ? ReadingHistory.fromJson(response['data']['reading'])
          : null;

      return {
        'article': article,
        'reading': reading,
      };
    } catch (e) {
      print('获取文章详情失败: $e');
      throw Exception('获取文章详情失败');
    }
  }

  // 更新阅读记录
  Future<ReadingHistory> updateReading({
    required int articleId,
    int? readPosition,
    int? readProgress,
    int? readTime,
    bool? isRead,
  }) async {
    final path = '/api/client/v1/article/update_reading';
    final Map<String, dynamic> parameters = {
      'article_id': articleId,
    };

    if (readPosition != null) parameters['read_position'] = readPosition;
    if (readProgress != null) parameters['read_progress'] = readProgress;
    if (readTime != null) parameters['read_time'] = readTime;
    if (isRead != null) parameters['is_read'] = isRead ? 1 : 0; // 将布尔值转换为整数

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return ReadingHistory.fromJson(response['data']);
    } catch (e) {
      print('更新阅读记录失败: $e');
      throw Exception('更新阅读记录失败');
    }
  }

  // 切换收藏状态
  Future<Map<String, dynamic>> toggleFavorite(int articleId) async {
    final path = '/api/client/v1/article/toggle_favorite';
    final Map<String, dynamic> parameters = {
      'article_id': articleId,
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return {
        'article_id': response['data']['article_id'],
        'is_favorite': response['data']['is_favorite'],
      };
    } catch (e) {
      print('切换收藏状态失败: $e');
      throw Exception('切换收藏状态失败');
    }
  }

  // 标记文章已读/未读
  Future<Map<String, dynamic>> markRead({
    required int articleId,
    required bool isRead,
  }) async {
    final path = '/api/client/v1/article/mark_read';
    final Map<String, dynamic> parameters = {
      'article_id': articleId,
      'is_read': isRead ? 1 : 0, // 将布尔值转换为整数
    };

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return {
        'article_id': response['data']['article_id'],
        'is_read': response['data']['is_read'],
      };
    } catch (e) {
      print('标记文章读取状态失败: $e');
      throw Exception('标记文章读取状态失败');
    }
  }

  // 标记全部已读
  Future<Map<String, dynamic>> markAllRead({String? feedId}) async {
    final path = '/api/client/v1/article/mark_all_read';
    final Map<String, dynamic> parameters = feedId != null ? {'feed_id': feedId} : {};

    try {
      final response = await HttpUtil.request(
        path,
        method: 'POST',
        parameters: parameters,
      );

      return {
        'count': response['data']['count'],
        'feed_id': response['data']['feed_id'],
      };
    } catch (e) {
      print('标记全部已读失败: $e');
      throw Exception('标记全部已读失败');
    }
  }

  // 获取未读文章数量
  Future<int> getUnreadCount({String? feedId}) async {
    final path = '/api/client/v1/article/unread_count';
    final Map<String, dynamic> parameters = feedId != null ? {'feed_id': feedId} : {};

    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: parameters,
      );

      return response['data']['unread_count'];
    } catch (e) {
      print('获取未读文章数量失败: $e');
      throw Exception('获取未读文章数量失败');
    }
  }

  // 获取用户的阅读历史
  Future<List<Article>> getUserHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    const path = '/api/client/v1/user/history';
    
    try {
      final response = await HttpUtil.request(
        path, 
        method: 'GET',
        parameters: {
          'limit': limit,
          'offset': offset
        }
      );

      final List<dynamic> historyData = response['data'];
      final List<Article> articles = [];
      
      // 这里假设API返回的是完整的文章信息
      // 如果不是，需要根据实际情况调整
      for (var item in historyData) {
        articles.add(Article.fromJson(item));
      }
      
      return articles;
    } catch (e) {
      print('获取阅读历史失败: $e');
      throw Exception('获取阅读历史失败');
    }
  }

  // 获取用户的收藏文章
  Future<List<Article>> getUserFavorites({
    int limit = 20,
    int offset = 0,
  }) async {
    const path = '/api/client/v1/user/favorites';
    
    try {
      final response = await HttpUtil.request(
        path, 
        method: 'GET',
        parameters: {
          'limit': limit,
          'offset': offset
        }
      );

      final List<dynamic> favoritesData = response['data'];
      final List<Article> articles = [];
      
      // 同样，假设API返回的是完整的文章信息
      for (var item in favoritesData) {
        articles.add(Article.fromJson(item));
      }
      
      return articles;
    } catch (e) {
      print('获取收藏文章失败: $e');
      throw Exception('获取收藏文章失败');
    }
  }
}