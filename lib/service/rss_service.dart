import 'package:lazyreader/utils/http_util.dart';

class RssService {
  // Future<dynamic> getRssList(String idToken) async {
  Future<dynamic> getRssCategory() async {
    const path = 'v1/rss/category_list'; // 登录API的路径
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

  Future<dynamic> getRssList(parameters) async {
    const path = 'v1/rss/user_unsubscribed_feeds'; // rss list
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

  Future<dynamic> getSubscribeRssList() async {
    const path = 'v1/rss/user_subscribed_feeds'; // rss list
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

  Future<dynamic> subscribeRSS(parameters) async {
    const path = 'v1/rss/subscribe'; // subscribeRSS
    // final parameters = {};
    try {
      final response =
          await HttpUtil.request(path, method: 'POST', parameters: parameters);
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }

  Future<dynamic> getUserSubScribed() async {
    const path = 'v1/rss/user_subscribed_feeds';
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

  Future<dynamic> getUserSubScribedUnRead() async {
    const path = 'v1/rss/user_subscribed_unread'; // 用户订阅的rss列表
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
    const path = 'v1/rss/category_feeds_all'; // 用户订阅的rss列表
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
}
