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
        margin: const EdgeInsets.only(top: 50, right: 16, left: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
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

    // 移除对协议的验证，让它在_register方法中单独处理
    return isValid;
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '用户协议与隐私政策',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '请阅读并同意我们的用户协议和隐私政策，以继续完成注册。',
            style: TextStyle(color: AppTheme.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                '取消',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('同意并继续'),
            ),
          ],
        );
      },
    ).then((agreed) {
      if (agreed == true) {
        setState(() {
          _agreeToTerms = true;
        });
        // 同意后继续注册流程
        print(
          '注册信息: 用户名=${_usernameController.text}, 邮箱=${_emailController.text}, 密码=${_passwordController.text}',
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _register() {
    // 先验证表单输入
    if (!_validateInputs()) {
      return;
    }

    // 如果表单验证通过，但没有勾选协议，则显示协议对话框
    if (!_agreeToTerms) {
      _showAgreementDialog();
      return;
    }

    // 如果已勾选协议，则直接进行注册
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
          // 底色背景
          Positioned.fill(child: Container(color: AppTheme.backgroundColor)),

          // 背景渐变装饰
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 2.5,
                  colors: [
                    AppTheme.accentColor.withOpacity(0.2),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // 顶部装饰圆形
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.3),
                    AppTheme.neonTeal.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // 底部装饰圆形
          Positioned(
            bottom: -140,
            right: -60,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppTheme.neonTeal.withOpacity(0.3),
                    AppTheme.neonBlue.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // 添加额外的底部背景元素，确保无缝覆盖
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.backgroundColor.withOpacity(0.0),
                    AppTheme.backgroundColor,
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
              child: Container(
                height: MediaQuery.of(context).size.height - 60, // 调整高度以居中显示
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 调整为居中
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
                                  icon: Icons.person_outline,
                                  errorText: _usernameError,
                                ),

                                const SizedBox(height: 16),

                                // 邮箱输入框
                                _buildTextField(
                                  controller: _emailController,
                                  hint: '请输入邮箱',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  errorText: _emailError,
                                ),

                                const SizedBox(height: 16),

                                // 密码输入框
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: '请输入密码',
                                  icon: Icons.lock_outline,
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
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 注册按钮
                      MicroInteractionButton(
                        text: '注册',
                        onPressed: () {
                          // 只验证表单，不验证协议
                          if (_formKey.currentState!.validate()) {
                            _register();
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      // 用户协议复选框和文本（左对齐）
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Checkbox(
                            value: _agreeToTerms,
                            activeColor: AppTheme.neonTeal,
                            onChanged: (bool? value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: '我已阅读并同意 ',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: '用户协议',
                                    style: TextStyle(
                                      color: AppTheme.neonPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            // 打开用户协议
                                            // Navigator.pushNamed(context, '/terms');
                                          },
                                  ),
                                  TextSpan(text: ' 和 '),
                                  TextSpan(
                                    text: '隐私政策',
                                    style: TextStyle(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            // 打开隐私政策
                                            // Navigator.pushNamed(context, '/privacy');
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                              // 切换到登录页面时重置验证状态
                              _formKey.currentState?.reset();
                              Navigator.pushReplacementNamed(context, '/login');
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 修改表单输入框样式
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
    final borderRadius = BorderRadius.circular(15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: borderRadius,
            // 使用不可见边框保持圆角的一致性
            border: Border.all(
              color:
                  errorText != null ? AppTheme.errorColor : Colors.transparent,
              width: 1,
            ),
          ),
          // 使Container与输入框紧密贴合，避免边距不一致
          clipBehavior: Clip.antiAlias,
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              filled: true,
              fillColor: Colors.transparent,
              // 设置TextField的边框
              border: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color:
                      errorText != null
                          ? AppTheme.errorColor
                          : Colors.transparent,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color:
                      errorText != null
                          ? AppTheme.errorColor
                          : Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color:
                      errorText != null
                          ? AppTheme.errorColor
                          : Colors.transparent,
                  width: 1,
                ),
              ),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: Icon(icon, color: Colors.white70),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: onTogglePassword,
                      )
                      : null,
            ),
          ),
        ),
        if (errorText != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
