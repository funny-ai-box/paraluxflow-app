// lib/utils/http_util.dart
import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/utils/event_bus_util.dart';
import 'package:lazyreader/utils/local_storage_util.dart';
import 'package:path_provider/path_provider.dart';

class HttpUtil {
  // static const String _baseUrl = 'https://jdai.ezretailpro.com';
  // static const String _baseUrl = 'http://192.168.31.102:8002';
  static const String _baseUrl = 'http://127.0.0.1:8000'; // 移除末尾的斜杠
  static late PersistCookieJar _cookieJar;

  // 初始化CookieJar
  static Future<void> initCookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage(dir.path));
  }

  static Future<dynamic> request(String path,
      {String method = 'GET', Map<String, dynamic>? parameters}) async {
    // 确保path不以斜杠开头，避免双斜杠问题
    String normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    
    var url = normalizedPath.contains('http')
        ? Uri.parse('$normalizedPath')
        : Uri.parse('$_baseUrl/$normalizedPath');
    print('请求URL: $url');

    try {
      // 获取JWT令牌
      final token = await LocalStorageUtil.getString('token');
      
      // 准备请求头
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      // 如果有token，添加到请求头
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print("添加认证头: Bearer $token");
      } else {
        print("警告: 没有找到token");
      }

      http.Response response;
      if (method == 'GET') {
        final queryParameters =
            parameters?.map((key, value) => MapEntry(key, value.toString()));
        
        url = normalizedPath.contains('http')
            ? Uri.parse('$normalizedPath')
            : Uri.parse('$_baseUrl/$normalizedPath')
                .replace(queryParameters: queryParameters);
        
        print("完整URL: $url");
        response = await http.get(url, headers: headers);
        
      } else if (method == 'POST') {
        response = await http.post(
          url, 
          body: json.encode(parameters), 
          headers: headers
        );
      } else {
        throw Exception('不支持的HTTP方法: $method');
      }

      return _processResponse(response);
    } catch (e) {
      print("请求错误: $e");
      Fluttertoast.showToast(msg: '网络请求失败: $e');
      throw e;
    }
  }

  static Stream<String> requestSSE(String path) async* {
    // 确保path不以斜杠开头
    String normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    
    var url = normalizedPath.contains('http')
        ? Uri.parse('$normalizedPath')
        : Uri.parse('$_baseUrl/$normalizedPath');
    try {
      // 获取JWT令牌
      final token = await LocalStorageUtil.getString('token');
      final headers = <String, String>{};
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final client = http.Client();
      final request = http.Request('GET', url)
        ..headers.addAll(headers);

      final response = await client.send(request);
      print("SSE响应头: ${response.headers}");

      if (response.headers.containsKey('content-type') &&
          response.headers['content-type']!.startsWith('text/event-stream')) {
        final controller = StreamController<String>.broadcast();
        StringBuffer buffer = StringBuffer();

        response.stream.listen((data) {
          String lines = utf8.decode(data);
          for (String line in lines.split('\n')) {
            buffer.write(line);
            if (line.isEmpty) {
              controller.add(buffer.toString());
              buffer.clear();
            }
          }
        });

        yield* controller.stream;
      } else {
        throw Exception('服务器不支持Server-Sent Events');
      }
    } catch (e) {
      print("SSE错误: $e");
      Fluttertoast.showToast(msg: 'SSE请求失败: $e');
      throw e;
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      
      // 检查API返回的状态码
      if (jsonResponse['code'] != 200) {
        // 状态码不为200，表示业务逻辑错误
        if (jsonResponse['code'] == 20001 || 
            jsonResponse['code'] == 20002 || 
            jsonResponse['code'] == 20003) {
          // 认证失败、令牌过期、无效令牌
          _handleNotLoggedIn();
        }
        throw Exception(jsonResponse['message'] ?? '服务器错误');
      }
      
      // 返回数据
      return jsonResponse;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // 身份验证失败
      print("认证失败: ${response.statusCode} - ${response.body}");
      _handleNotLoggedIn();
      throw Exception('未授权，请重新登录');
    } else {
      print("请求失败: ${response.statusCode} - ${response.body}");
      throw Exception('请求失败，状态码: ${response.statusCode}');
    }
  }

  static Future<void> _handleNotLoggedIn() async {
    // 删除本地存储的用户信息
    await CustomUser.removeFromLocalStorage();
    await LocalStorageUtil.remove('token');

    // 删除所有Cookie
    _cookieJar.deleteAll();
    
    // 发布用户未授权事件
    print("发布登录失效事件");
    eventBus.fire(UserUnauthorizedEvent());
  }
}