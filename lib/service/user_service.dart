// lib/service/user_service.dart
import 'package:lazyreader/utils/http_util.dart';

class UserService {
  Future<dynamic> loginByToken(String idToken) async {
    const path = '/api/client/v1/auth/login_by_token'; 
    final parameters = {
      'id_token': idToken,
    };

    try {
      final response =
          await HttpUtil.request(path, method: 'GET', parameters: parameters);
      return response;
    } catch (e) {
      throw Exception('登录失败: $e');
    }
  }

  Future<dynamic> getCurrentUser() async {
    const path = '/api/client/v1/user/info';
    try {
      final response = await HttpUtil.request(path, method: 'GET');
      return response;
    } catch (e) {
      throw Exception('获取用户信息失败: $e');
    }
  }

  Future<dynamic> getUserStats() async {
    const path = '/api/client/v1/user/stats';
    try {
      final response = await HttpUtil.request(path, method: 'GET');
      return response;
    } catch (e) {
      throw Exception('获取用户统计信息失败: $e');
    }
  }

  Future<dynamic> getUserHistory({int limit = 20, int offset = 0}) async {
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
      return response;
    } catch (e) {
      throw Exception('获取阅读历史失败: $e');
    }
  }

  Future<dynamic> getUserFavorites({int limit = 20, int offset = 0}) async {
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
      return response;
    } catch (e) {
      throw Exception('获取收藏文章失败: $e');
    }
  }
}