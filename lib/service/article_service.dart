import 'package:lazyreader/utils/http_util.dart';

class ArticleService {
  Future<dynamic> getSubscriptionArticles(parameters) async {
    const path = 'feed/subscription_articles'; // 文章列表
    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: parameters);
      // 处理响应
      print(response);
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }

  Future<dynamic> getUserSubscriptions(parameters) async {
    try {
      final response = await HttpUtil.request('feed/user_subscriptions',
          parameters: parameters);
      return response;
    } catch (e) {
      throw Exception('获取失败: $e');
    }
  }

  Future<dynamic> getDetailsInfo(parameters) async {
    const path = 'feed/article_detail'; // rss列表
    // final parameters = {};
    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: parameters);
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }
}
