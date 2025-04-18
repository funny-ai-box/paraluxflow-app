import 'dart:convert';

import 'package:lazyreader/utils/local_storage_util.dart';

class CustomUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  CustomUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  // 从 JSON 创建 CustomUser 对象
  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
    );
  }

  // 将 CustomUser 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
    };
  }

  // 复制 CustomUser 与新属性
  CustomUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return CustomUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  @override
  String toString() {
    return 'CustomUser(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL)';
  }

  Future<void> setToLocalStorage() async {
    String userJson = jsonEncode(this.toJson()); // 将 CustomUser 对象转换为 JSON 字符串
    await LocalStorageUtil.setString('customUser', userJson); // 保存 JSON 字符串
  }

  // 从本地存储获取 CustomUser
  static Future<CustomUser?> getFromLocalStorage() async {
    String? userJson = LocalStorageUtil.getString('customUser');
    if (userJson == null) {
      return null; // 如果没有存储的用户数据，返回 null
    }

    try {
      Map<String, dynamic> jsonMap = jsonDecode(userJson);
      return CustomUser.fromJson(jsonMap);
    } catch (e) {
      print('Error parsing user data: $e');
      // 如果解析失败，删除可能损坏的数据
      await removeFromLocalStorage();
      return null;
    }
  }

  static Future<void> removeFromLocalStorage() async {
    await LocalStorageUtil.remove('customUser');
  }
}
