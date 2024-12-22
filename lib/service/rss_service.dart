import 'package:lazyreader/utils/http_util.dart';

class RssService {
  // Future<dynamic> getRssList(String idToken) async {
  Future<dynamic> getRssCategory() async {
    const path = 'feed/categories'; // 登录API的路径
    // final parameters = {};
    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: {});
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }

  Future<dynamic> getRssSourcesByCategory(id) async {
    const path = 'feed/category_feeds'; // 用户订阅的rss列表
    try {
      final response = await HttpUtil.request(path,
          method: 'GET', parameters: {'category_id': id});
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }

  Future<dynamic> getFeedDetail(int feedId) async {
    final path = 'feed/feed_detail';
    try {
      final response = await HttpUtil.request(path,
          method: 'GET', parameters: {'feed_id': feedId});
      return response['data'];
    } catch (e) {
      throw Exception('获取RSS源详情失败: $e');
    }
  }

  Future<dynamic> getFeedPreviewArticles(int feedId,
      {int page = 1, int perPage = 20}) async {
    final path = 'feed/preview_articles';
    try {
      final response = await HttpUtil.request(path,
          method: 'GET', parameters: {'feed_id': feedId});
      return response['data'];
    } catch (e) {
      throw Exception('获取文章列表失败: $e');
    }
  }

  Future<bool> getSubscriptionStatus(int sourceId) async {
    final path = 'feed/user_subscription_status';
    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: {});
      print(response);
      return response['data']['is_subscribed'] ?? false;
    } catch (e) {
      throw Exception('获取订阅状态失败: $e');
    }
  }
}
