import 'dart:io';

import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/pages/home_screen.dart';
import 'package:lazyreader/pages/user/email_login.dart';
import 'package:lazyreader/service/user_service.dart';
import 'package:lazyreader/utils/loading_overlay.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart'; // 如果需要SVG图标，需添加flutter_svg包
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

    // 使用这些信息
    print("应用名称: $appName");
    print("包名/Bundle ID: $packageName");
    print("版本: $version");
    print("构建号: $buildNumber");
  }

  void _onAppleLoginPressed() async {
    // 模拟登录逻辑

    try {
      AuthService authService = AuthService();
      UserService userService = UserService();
      LoadingOverlay.show(context, isLoading: true);
      var user = await authService.signInWithApple();

      if (user != null) {
        var idToken = await user.getIdToken();

        var response = await userService.loginByToken(idToken!);

        print(response);
        // 根据response的结果进行处理
        if (response["code"] == 200) {
          print(user);
          CustomUser customUser = CustomUser(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
              photoURL: user.photoURL);
          customUser.setToLocalStorage();
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomeScreenPage()));
          });
        } else {
          // 登录失败，显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('登录失败: $response'),
              behavior: SnackBarBehavior.floating));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('获取用户信息失败'), behavior: SnackBarBehavior.floating));
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
    // 模拟登录逻辑
    try {
      AuthService authService = AuthService();
      UserService userService = UserService();
      LoadingOverlay.show(context, isLoading: true);
      var user = await authService.signInWithGoogle();

      if (user != null) {
        var idToken = await user.getIdToken();

        var response = await userService.loginByToken(idToken!);

        print(response);
        // 根据response的结果进行处理
        if (response["code"] == 200) {
          print(user);
          CustomUser customUser = CustomUser(
              uid: user.uid,
              email: user.email,
              displayName: user.displayName,
              photoURL: user.photoURL);
          customUser.setToLocalStorage();
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const HomeScreenPage()));
          });
        } else {
          // 登录失败，显示错误提示
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('登录失败: $response'),
              behavior: SnackBarBehavior.floating));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('获取用户信息失败'), behavior: SnackBarBehavior.floating));
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
        height: 50, // Adjust the height as needed
        child: _buildSocialButton(context,
            assetName: 'assets/google_icon.svg',
            text: 'Continue With Google',
            onPressed: _onGoogleLoginPressed,
            backgroundColor: Colors.indigo),
      ),

      const SizedBox(height: 16), // Spacer between buttons
      SizedBox(
        width: double.infinity,
        height: 50, // Adjust the height as needed
        child: _buildSocialButton(context,
            assetName: 'assets/email_icon.svg',
            text: 'Continue With Email',
            onPressed: _onEmailLoginPressed,
            backgroundColor: Colors.indigo),
      ),
    ];

    // Check if the platform is iOS and add the Apple sign-in button
    if (Platform.isIOS) {
      buttons.insertAll(0, [
        // Spacer between buttons
        SizedBox(
          width: double.infinity,
          height: 50, // Adjust the height as needed
          child: _buildSocialButton(context,
              assetName:
                  'assets/apple_icon.svg', // Ensure you have an Apple icon asset
              text: 'Continue With Apple',
              onPressed: _onAppleLoginPressed,
              backgroundColor: Colors
                  .black), // Apple's brand guidelines suggest using a black background for the button
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
                          // Logo Placeholder
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
                                  "Welcome",
                                  style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            "Now, you can easily stay updated with the latest news. Designed for convenience and speed, it brings the world's current events right to your fingertips",
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
                            text: "By using this service, you agree to our "),
                        TextSpan(
                          text: 'Terms of Use',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrl(
                                Uri.parse("https://www.google.com"),
                                mode: LaunchMode.inAppWebView,
                              );
                            },
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // TODO: Add navigation to Privacy Policy link
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
        minimumSize: const Size(double.infinity, 50), // Button height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
