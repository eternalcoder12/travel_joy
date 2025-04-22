import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _agreeToTerms = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // 字段错误状态
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _apiError; // 添加API错误消息

  late TapGestureRecognizer _termsGestureRecognizer;
  late TapGestureRecognizer _privacyGestureRecognizer;

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

    _termsGestureRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            // 显示用户协议
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('用户协议内容')));
          };

    _privacyGestureRecognizer =
        TapGestureRecognizer()
          ..onTap = () {
            // 显示隐私政策
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('隐私政策内容')));
          };
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _termsGestureRecognizer.dispose();
    _privacyGestureRecognizer.dispose();
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
    if (!_agreeToTerms) {
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            _apiError!,
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                    // 标题
                    Text(
                      '创建您的旅行者账户',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 描述文字
                    Text(
                      '加入我们，探索无限旅行体验',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 注册表单
                    GlassCard(
                      borderRadius: 24,
                      blur: 10,
                      opacity: 0.1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 用户名输入框
                              _buildTextField(
                                controller: _usernameController,
                                hint: '请输入用户名',
                                icon: Icons.person,
                                errorText: _usernameError,
                              ),
                              if (_usernameError != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 16.0,
                                    ),
                                    child: Text(
                                      _usernameError!,
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
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
                              if (_emailError != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 16.0,
                                    ),
                                    child: Text(
                                      _emailError!,
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
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
                              if (_passwordError != null)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 16.0,
                                    ),
                                    child: Text(
                                      _passwordError!,
                                      style: TextStyle(
                                        color: AppTheme.errorColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 用户协议和隐私政策
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // 左对齐
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '我已阅读并同意用户协议和隐私政策',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 注册按钮
                    MicroInteractionButton(
                      text: '注册',
                      onPressed: () {
                        // 验证表单
                        if (_formKey.currentState?.validate() == true) {
                          _register();
                        }
                      },
                    ),

                    // 协议说明
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft, // 左对齐
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _agreeToTerms,
                              activeColor: AppTheme.neonBlue,
                              onChanged: (bool? value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: '我已阅读并同意 '),
                                  TextSpan(
                                    text: '用户协议',
                                    style: TextStyle(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: _termsGestureRecognizer,
                                  ),
                                  const TextSpan(text: ' 和 '),
                                  TextSpan(
                                    text: '隐私政策',
                                    style: TextStyle(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: _privacyGestureRecognizer,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 已有账号链接
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已有账号? ',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            '立即登录',
                            style: TextStyle(
                              color: AppTheme.neonPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
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
