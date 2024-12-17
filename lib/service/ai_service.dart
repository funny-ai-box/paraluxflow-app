import 'package:lazyreader/utils/http_util.dart';

class AiService {
  Future<dynamic> getRecommendArticles() async {
    const path = 'v1/ai/recommend'; // 推荐文章
    // final parameters = {};
    try {
      final response = await HttpUtil.request(path, method: 'GET');
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('获取失败: $e');
    }
  }
}
