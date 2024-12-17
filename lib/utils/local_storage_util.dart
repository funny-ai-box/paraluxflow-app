import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageUtil {
  static SharedPreferences? _preferences;

  // 初始化 SharedPreferences 实例
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // 保存字符串数据
  static Future<bool> setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  // 读取字符串数据
  static String? getString(String key) {
    return _preferences?.getString(key);
  }

  // 保存布尔类型数据
  static Future<bool> setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  // 读取布尔类型数据
  static bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  static Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  static Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  // 这里可以根据需要继续添加其他类型的保存和读取方法
}
