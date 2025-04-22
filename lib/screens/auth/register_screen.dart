import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/micro_interaction_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // 字段错误状态
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _apiError; // 添加API错误消息

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuint),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.primaryTextColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: AppTheme.primaryTextColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '知道了',
          textColor: AppTheme.primaryTextColor,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  bool _validateInputs() {
    bool isValid = true;

    // 重置所有错误信息
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _apiError = null;
    });

    // 验证用户名
    if (_usernameController.text.isEmpty) {
      setState(() {
        _usernameError = '请输入用户名';
      });
      isValid = false;
    } else if (_usernameController.text.length < 3) {
      setState(() {
        _usernameError = '用户名至少需要3个字符';
      });
      isValid = false;
    }

    // 验证邮箱
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = '请输入邮箱地址';
      });
      isValid = false;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      setState(() {
        _emailError = '请输入有效的邮箱地址';
      });
      isValid = false;
    }

    // 验证密码
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = '请输入密码';
      });
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() {
        _passwordError = '密码至少需要6个字符';
      });
      isValid = false;
    }

    // 验证是否同意协议
    if (!_acceptTerms) {
      _showErrorSnackBar('请同意用户协议和隐私政策');
      isValid = false;
    }

    return isValid;
  }

  void _register() {
    // 先验证输入
    if (!_validateInputs()) {
      return;
    }

    print(
      '注册信息: 用户名=${_usernameController.text}, 邮箱=${_emailController.text}, 密码=${_passwordController.text}',
    );

    // TODO: 实现注册逻辑
    // 模拟API错误示例:
    // setState(() {
    //   _apiError = "该邮箱已被注册，请使用其他邮箱或找回密码";
    // });
    // return;

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景渐变装饰
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.8,
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.2),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // 背景装饰元素
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.neonTeal.withOpacity(0.3),
                    AppTheme.neonPurple.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -80,
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.3),
                    AppTheme.neonPink.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // 模糊效果
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 主内容
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.04),

                    // API错误消息（如果有）
                    if (_apiError != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.errorColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: AppTheme.errorColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _apiError!,
                                style: TextStyle(
                                  color: AppTheme.errorColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 标题
                    SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonOrange,
                                  AppTheme.neonPink,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPink.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '创建账号',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                              shadows: [
                                Shadow(
                                  color: AppTheme.neonOrange.withOpacity(0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        '请填写以下信息完成注册',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.03),

                    // 表单区域 - 使用毛玻璃效果
                    SlideTransition(
                      position: _slideAnimation,
                      child: GlassCard(
                        borderRadius: 24,
                        blur: 10,
                        opacity: 0.1,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildFormArea(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 用户协议和隐私政策
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.9,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: AppTheme.neonPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          // 移除Expanded使文字靠近checkbox
                          Text(
                            '我已阅读并同意用户协议和隐私政策',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 注册按钮
                    SlideTransition(
                      position: _slideAnimation,
                      child: MicroInteractionButton(
                        text: '注册',
                        icon: Icons.app_registration,
                        backgroundColor: AppTheme.buttonColor,
                        onPressed: _register,
                      ),
                    ),

                    // 删除底部返回登录按钮，只保留空间
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 用户名输入框
        _buildTextField(
          controller: _usernameController,
          hint: '请输入用户名',
          icon: Icons.person,
          errorText: _usernameError,
        ),
        const SizedBox(height: 20),
        // 邮箱输入框
        _buildTextField(
          controller: _emailController,
          hint: '请输入邮箱',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
        ),
        const SizedBox(height: 20),
        // 密码输入框
        _buildTextField(
          controller: _passwordController,
          hint: '请输入密码',
          icon: Icons.lock,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onTogglePassword: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          errorText: _passwordError,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // 改为左对齐
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            boxShadow:
                errorText != null
                    ? [
                      BoxShadow(
                        color: AppTheme.errorColor.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            border:
                errorText != null
                    ? Border.all(color: AppTheme.errorColor, width: 1)
                    : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            style: TextStyle(color: AppTheme.primaryTextColor),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.hintTextColor),
              prefixIcon: Icon(icon, color: AppTheme.secondaryTextColor),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.secondaryTextColor,
                        ),
                        onPressed: onTogglePassword,
                      )
                      : null,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 改为左对齐
              children: [
                Icon(Icons.error_outline, size: 14, color: AppTheme.errorColor),
                const SizedBox(width: 5),
                Text(
                  errorText,
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
