import 'package:flutter/material.dart';
import '../../app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    print('注册尝试: ${_emailController.text}');
    // 这里只打印日志，模拟注册逻辑
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
                Text('注册', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24.0),
                // 用户名输入框
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    hintText: '请输入您的用户名',
                    prefixIcon: Icon(Icons.person),
                  ),
                  style: TextStyle(color: AppTheme.primaryTextColor),
                ),
                const SizedBox(height: 16.0),
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
                const SizedBox(height: 24.0),
                // 注册按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _register,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('注册'),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // 登录链接
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '已有账号？',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                          TextSpan(
                            text: '登录',
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
