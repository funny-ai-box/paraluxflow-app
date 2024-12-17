import 'package:lazyreader/utils/http_util.dart';

class NewsService {
  Future<dynamic> getNewsList(parameters) async {
    const path = 'v1/rss/articles'; // 文章列表
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

  Future<dynamic> getDetailsInfo(parameters) async {
    const path = 'v1/rss/article_detail'; // rss列表
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

  Future<dynamic> getRssList(parameters) async {
    const path = 'v1/rss/list'; // rss列表
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

  Future<dynamic> subscribeRSS(parameters) async {
    const path = 'v1/rss/subscribe'; // 订阅/取消订阅
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
}
