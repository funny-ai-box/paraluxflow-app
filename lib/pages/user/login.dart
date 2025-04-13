// lib/pages/user/login.dart
import 'dart:io';

import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/pages/home_screen.dart';
import 'package:lazyreader/pages/user/email_login.dart';
import 'package:lazyreader/service/user_service.dart';
import 'package:lazyreader/utils/loading_overlay.dart';
import 'package:lazyreader/utils/local_storage_util.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lazyreader/service/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _onEmailLoginPressed() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EmailLoginPage()),
    );
  }

  Future<void> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName =
        packageInfo.packageName; // Bundle ID (iOS) 或 应用包名 (Android)
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    print("应用名称: $appName");
    print("包名/Bundle ID: $packageName");
    print("版本: $version");
    print("构建号: $buildNumber");
  }

  void _onAppleLoginPressed() async {
    try {
      AuthService authService = AuthService();
      UserService userService = UserService();
      LoadingOverlay.show(context, isLoading: true);
      var user = await authService.signInWithApple();

      if (user != null) {
        var idToken = await user.getIdToken();

        var response = await userService.loginByToken(idToken!);

        if (response["code"] == 200) {
          // 保存用户数据
          CustomUser customUser = CustomUser(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
              photoURL: user.photoURL);
          await customUser.setToLocalStorage();
          
          // 保存token
          await LocalStorageUtil.setString('token', response['data']['token']);
          
          // 跳转到首页
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomeScreenPage()));
          });
        } else {
          // 登录失败，显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('登录失败: ${response["message"]}'),
              behavior: SnackBarBehavior.floating));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('获取用户信息失败'), 
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('登录异常: $e'), behavior: SnackBarBehavior.floating));
    } finally {
      LoadingOverlay.show(context, isLoading: false);
    }
  }

  void _onGoogleLoginPressed() async {
    try {
      AuthService authService = AuthService();
      UserService userService = UserService();
      LoadingOverlay.show(context, isLoading: true);
      var user = await authService.signInWithGoogle();

      if (user != null) {
        var idToken = await user.getIdToken();

        var response = await userService.loginByToken(idToken!);

        if (response["code"] == 200) {
          // 保存用户数据
          CustomUser customUser = CustomUser(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
              photoURL: user.photoURL);
          await customUser.setToLocalStorage();
          
          // 保存token
          await LocalStorageUtil.setString('token', response['data']['token']);
          
          // 跳转到首页
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomeScreenPage()));
          });
        } else {
          // 登录失败，显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('登录失败: ${response["message"]}'),
              behavior: SnackBarBehavior.floating));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('获取用户信息失败'), 
            behavior: SnackBarBehavior.floating));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('登录异常: $e'), behavior: SnackBarBehavior.floating));
    } finally {
      LoadingOverlay.show(context, isLoading: false);
    }
  }

  Widget _buildSocialButtons(context) {
    List<Widget> buttons = [
      SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildSocialButton(context,
            assetName: 'assets/google_icon.svg',
            text: '使用Google账号登录',
            onPressed: _onGoogleLoginPressed,
            backgroundColor: Colors.indigo),
      ),

      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildSocialButton(context,
            assetName: 'assets/email_icon.svg',
            text: '使用邮箱登录',
            onPressed: _onEmailLoginPressed,
            backgroundColor: Colors.indigo),
      ),
    ];

    // 检查是否在iOS平台并添加Apple登录按钮
    if (Platform.isIOS) {
      buttons.insertAll(0, [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _buildSocialButton(context,
              assetName:
                  'assets/apple_icon.svg',
              text: '使用Apple账号登录',
              onPressed: _onAppleLoginPressed,
              backgroundColor: Colors
                  .black),
        ),
        const SizedBox(height: 16),
      ]);
    }

    return Column(
      children: buttons,
    );
  }

  @override
  Widget build(BuildContext context) {
    getAppInfo();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          Container(
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                const Image(
                                    image: AssetImage('images/logo.png'),
                                    width: 60,
                                    height: 60),
                                const SizedBox(height: 20),
                                const Text(
                                  "欢迎使用",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "现在，您可以轻松获取最新资讯。专为便捷和速度而设计，将全球当前事件直接呈现在您的指尖",
                            style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(221, 56, 56, 56)),
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2),
                          _buildSocialButtons(context),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                      children: <TextSpan>[
                        const TextSpan(
                            text: "使用本服务即表示您同意我们的"),
                        TextSpan(
                          text: '使用条款',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse("https://www.example.com/terms"),
                                mode: LaunchMode.inAppWebView,
                              );
                            },
                        ),
                        const TextSpan(
                          text: "和",
                        ),
                        TextSpan(
                          text: '隐私政策',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse("https://www.example.com/privacy"),
                                mode: LaunchMode.inAppWebView,
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String assetName,
    required String text,
    VoidCallback? onPressed,
    required backgroundColor,
  }) {
    return ElevatedButton.icon(
      icon: SvgPicture.asset(assetName, height: 24, width: 24),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        foregroundColor: Colors.black87,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}