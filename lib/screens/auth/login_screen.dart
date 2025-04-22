import 'package:flutter/material.dart';
import '../../app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    print('登录尝试: ${_emailController.text}');
    // 这里只打印日志，模拟登录逻辑
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部返回按钮
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.iconColor),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
                // 标题
                Text('登录', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24.0),
                // 邮箱输入框
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入您的邮箱',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                const SizedBox(height: 16.0),
                // 密码输入框
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    hintText: '请输入您的密码',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                // 忘记密码链接
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot_password');
                    },
                    child: Text(
                      '忘记密码？',
                      style: TextStyle(color: AppTheme.secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('登录'),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // 注册链接
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '还没有账号？',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                          TextSpan(
                            text: '注册',
                            style: TextStyle(color: AppTheme.primaryTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
