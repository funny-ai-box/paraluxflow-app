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

  Future<bool> getSubscriptionStatus(int feedId) async {
    const path = 'feed/user_subscription_status';
    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: {'feed_id': feedId},
      );
      return response['data']['is_subscribed'] ?? false;
    } catch (e) {
      throw Exception('获取订阅状态失败: $e');
    }
  }

  // 订阅 RSS 源
  Future<void> subscribeFeed(int feedId) async {
    const path = 'feed/subscribe';
    try {
      await HttpUtil.request(
        path,
        method: 'POST',
        parameters: {'feed_id': feedId},
      );
    } catch (e) {
      throw Exception('订阅失败: $e');
    }
  }

  // 取消订阅 RSS 源
  Future<void> unsubscribeFeed(int feedId) async {
    const path = 'feed/unsubscribe';
    try {
      await HttpUtil.request(
        path,
        method: 'POST',
        parameters: {'feed_id': feedId},
      );
    } catch (e) {
      throw Exception('取消订阅失败: $e');
    }
  }

  // 获取用户订阅的所有 RSS 源
  Future<dynamic> getUserSubscriptions({int page = 1, int perPage = 20}) async {
    const path = 'feed/user_subscriptions';
    try {
      final response = await HttpUtil.request(
        path,
        method: 'GET',
        parameters: {
          'page': page,
          'per_page': perPage,
        },
      );
      return response['data'];
    } catch (e) {
      throw Exception('获取订阅列表失败: $e');
    }
  }
}
