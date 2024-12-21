import 'dart:async';

import 'package:lazyreader/models/CustomUser.dart';
import 'package:lazyreader/pages/home_screen.dart';

import 'package:lazyreader/pages/user/login.dart';
import 'package:lazyreader/service/auth_service.dart';
import 'package:lazyreader/service/user_service.dart';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/material.dart';
import 'package:lazyreader/utils/loading_overlay.dart';
import 'package:lazyreader/utils/local_storage_util.dart';

var aId = 866;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnState();
    });
  }

  void _navigateBasedOnState() async {
    bool isLoggedIn = false;
    CustomUser? user = await CustomUser.getFromLocalStorage();
    print("user: $user");
    if (user != null) {
      isLoggedIn = true;
    }

    if (isLoggedIn) {
      // 如果已经登录，跳转到首页
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreenPage()));
    } else {
      // 如果未登录，检查是否是通过动态链接打开的
      final PendingDynamicLinkData? initialLink =
          await FirebaseDynamicLinks.instance.getInitialLink();
      if (initialLink != null) {
        initDynamicLinks(context);
      } else {
        // 如果不是通过动态链接打开，直接跳转到登录页面
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  void initDynamicLinks(BuildContext context) async {
    AuthService authService = AuthService();
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
    }

    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri deepLink = dynamicLinkData.link;
      final email = LocalStorageUtil.getString('emailForSignIn');

      if (email == null) {
        return;
      }
      if (!mounted) return;
      try {
        final user =
            await authService.signInWithEmailLink(email, deepLink.toString());
        print(user);
        if (user != null) {
          UserService userService = UserService();
          var idToken = await user.getIdToken();
          var response = await userService.loginByToken(idToken!);
          if (response["code"] == 200) {
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('登录失败: $response'),
                behavior: SnackBarBehavior.floating));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('用户不存在的错误'), behavior: SnackBarBehavior.floating));
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('错误:$e'), behavior: SnackBarBehavior.floating));
      } finally {
        LoadingOverlay.show(context, isLoading: false);
      }
    }).onError((error) {
      if (!mounted) return;
      LoadingOverlay.show(context, isLoading: false);
      print(error);
      // 处理错误
    });
  }

  @override
  Widget build(BuildContext context) {
    // 由于_navigateBasedOnState已经处理了页面跳转，这里可以直接返回一个空的或加载中的页面
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
