import 'package:lazyreader/utils/http_util.dart';

class UserService {
  Future<dynamic> loginByToken(String idToken) async {
    const path = '/api/client/v1/auth/login_by_token'; // 登录API的路径
    final parameters = {
      'id_token': idToken,
    };

    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: parameters);
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('登录失败: $e');
    }
  }

  Future<dynamic> getCurrentUser() async {
    const path = 'user/get_current_user';
    final response = await HttpUtil.request(path, method: 'GET');
    // 处理响应
    return response;
  }

  Future<dynamic> logout() async {
    const path = 'user/logout';
    try {
      final response = await HttpUtil.request(path, method: 'GET');
      // 处理响应
      return response;
    } catch (e) {
      // 处理异常
      throw Exception('登出失败: $e');
    }
  }
}
