import 'package:lazyreader/utils/http_util.dart';

class HottopicService {
  // Future<dynamic> getRssList(String idToken) async {
  Future<dynamic> getHottopicDaily() async {
    const path = 'hottopic/daily'; // 登录API的路径
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

  Future<dynamic> getConsolidatedHotTopics() async {
    const path = 'hottopic/consolidated'; // 登录API的路径
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
}
