import 'package:lazyreader/pages/user/email_login_check.dart';
import 'package:lazyreader/service/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:email_validator/email_validator.dart'; // 添加email_validator包以验证电子邮件地址

const Color deepBlue = Color.fromARGB(255, 88, 105, 228); // 定义深蓝色

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final email = _emailController.text;
    setState(() {
      _isEmailValid =
          EmailValidator.validate(email); // 使用EmailValidator验证电子邮件地址
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter your email',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter your email address to continue',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontSize: 14),
                        keyboardType:
                            TextInputType.emailAddress, // 为电子邮件输入设置键盘类型
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildLoginButton(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  children: <TextSpan>[
                    const TextSpan(
                      text: "By using this service, you agree to our ",
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO: Add navigation to Terms of Use link
                        },
                    ),
                    const TextSpan(
                      text: " and ",
                    ),
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
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isEmailValid
              ? () async {
                  try {
                    AuthService authService = AuthService();
                    final result = await authService
                        .sendSignInLinkToEmail(_emailController.text);

                    if (result) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailLoginCheckPage(
                            email: _emailController.text, // 将电子邮件地址作为参数传递
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('登录失败: $e'),
                        behavior: SnackBarBehavior.floating));
                  }
                }
              : null, // 按钮仅在电子邮件有效时启用
          style: ElevatedButton.styleFrom(
            backgroundColor: deepBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              )),
        ),
      ),
    );
  }
}
