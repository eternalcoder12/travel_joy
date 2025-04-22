import 'package:flutter/material.dart';
import '../../app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    print('发送重置链接到: ${_emailController.text}');
    // 这里只打印日志，模拟发送重置链接逻辑
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
                Text('忘记密码', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16.0),
                // 描述文字
                Text(
                  '请输入您的邮箱以接收重置链接',
                  style: Theme.of(context).textTheme.bodyMedium,
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
                const SizedBox(height: 24.0),
                // 发送重置链接按钮
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _sendResetLink,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('发送重置链接'),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // 返回登录链接
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      '返回登录',
                      style: TextStyle(color: AppTheme.primaryTextColor),
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
