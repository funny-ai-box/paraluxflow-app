import 'package:flutter/material.dart';

class EmailLoginCheckPage extends StatelessWidget {
  final String email;

  const EmailLoginCheckPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // 使内容尽可能居中
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.email, size: 50), // 邮箱图标
            const SizedBox(height: 20), // 添加一些垂直间距
            const Text('Check your email',
                style: TextStyle(fontSize: 24)), // 第二行文本
            const SizedBox(height: 10), // 添加一些垂直间距
            Text(
              'Tap the link we sent to $email to verify your account and finish setting up.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center, // 文本对齐方式
            ), // 第三行文本，包含email变量
          ],
        ),
      ),
    );
  }
}
