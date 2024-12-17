import 'package:flutter/material.dart';

class LoadingOverlay {
  static const _loadingWidget = Center(
    child: CircularProgressIndicator(),
  );

  static void show(BuildContext context, {bool isLoading = true}) {
    if (isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false, // 用户不能通过点击外部来关闭对话框
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false, // 防止用户通过返回键关闭对话框
            child: Scaffold(
              backgroundColor: Colors.black.withAlpha(150), // 半透明的黑色背景
              body: _loadingWidget,
            ),
          );
        },
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop(); // 关闭对话框
    }
  }
}
