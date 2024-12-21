import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/utils/event_bus_util.dart';
import 'package:path_provider/path_provider.dart';

class HttpUtil {
  //static const String _baseUrl = 'https://jdai.ezretailpro.com';
  static const String _baseUrl = 'http://192.168.31.102:8002';
  static late PersistCookieJar _cookieJar;

  // 初始化CookieJar
  static Future<void> initCookieJar() async {
    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(storage: FileStorage(dir.path));
  }

  static Future<dynamic> request(String path,
      {String method = 'GET', Map<String, dynamic>? parameters}) async {
    var url = path.contains('http')
        ? Uri.parse('$path')
        : Uri.parse('$_baseUrl/$path');
    print('url=${url}');

    try {
      // 加载对应请求的cookie
      final cookies = await _cookieJar.loadForRequest(url);
      final cookieHeader =
          cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
      print("______-cookieHeader:$cookieHeader");
      http.Response response;
      if (method == 'GET') {
        final queryParameters =
            parameters?.map((key, value) => MapEntry(key, value.toString()));
        // url = Uri.parse('$_baseUrl/$path')
        url = path.contains('http')
            ? Uri.parse('$path')
            : Uri.parse('$_baseUrl/$path')
                .replace(queryParameters: queryParameters);
        print("url-----$url");
        response = await http.get(
          url,
          headers: cookieHeader.isNotEmpty
              ? {'Cookie': cookieHeader, 'ismock': 'true'}
              : {},
        );
        print("response-----$response");
      } else if (method == 'POST') {
        response =
            await http.post(url, body: json.encode(parameters), headers: {
          'ismock': 'true',
          'Content-Type': 'application/json',
          if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
        });
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }
      var c = response.headers['set-cookie'];

      if (c != null) {
        // 使用正则表达式匹配cookie分隔符，避免破坏日期
        var cookiePattern = RegExp(r'(?<=\),|\)$)');
        var cookies = c.split(cookiePattern);
        for (var cookie in cookies) {
          print("Cookie: $cookie");
        }

        // 保存处理后的cookies
        _cookieJar.saveFromResponse(
            Uri.parse(_baseUrl),
            cookies
                .map((str) => Cookie.fromSetCookieValue(str.trim()))
                .toList());
      }

      return _processResponse(response);
    } catch (e) {
      print("error: $e");
      Fluttertoast.showToast(msg: '网络请求失败: $e');
    }
  }

  static Stream<String> requestSSE(String path) async* {
    var url = path.contains('http')
        ? Uri.parse('$path')
        : Uri.parse('$_baseUrl/$path');
    try {
      final cookies = await _cookieJar.loadForRequest(url);
      final cookieHeader =
          cookies.map((cookie) => '${cookie.name}=${cookie.value}').join('; ');
      print("______-cookieHeader:$cookieHeader");
      final client = http.Client();
      final request = http.Request('GET', url)
        ..headers['Cookie'] = cookieHeader; // Adding cookie header

      final response = await client.send(request);
      print("--------------");
      print(response.headers);

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
        throw Exception('Server sent event not supported by server');
      }
    } catch (e) {
      print("SSE error: $e");
      Fluttertoast.showToast(msg: 'SSE请求失败: $e');
    }
  }

  static dynamic _processResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // 删除本地存储的用户信息并跳转到登录页面
      _handleNotLoggedIn();
    } else {
      throw Exception('The network is busy, please try again later');
      // throw Exception('Request failed with status: ${response.statusCode}.');
    }
  }

  static Future<void> _handleNotLoggedIn() async {
    // 删除本地存储的用户信息
    await CustomUser.removeFromLocalStorage();

    _cookieJar.delete(Uri.parse(_baseUrl));
    print("提交登录事件");
    eventBus.fire(UserUnauthorizedEvent());
  }
}
