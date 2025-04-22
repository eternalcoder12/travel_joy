import 'package:flutter/material.dart';
import '../../app_theme.dart';

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

    return isValid;
  }

  void _register() {
    if (!_validateInputs()) {
      return;
    }

    if (!_acceptTerms) {
      _showErrorSnackBar('请同意用户协议和隐私政策');
      return;
    }

    print(
      '注册信息: 用户名=${_usernameController.text}, 邮箱=${_emailController.text}, 密码=${_passwordController.text}',
    );

    // TODO: 实现注册逻辑
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景装饰元素
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardColor.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardColor.withOpacity(0.2),
              ),
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
                    // 标题
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        '创建账号',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
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
                    // 表单区域
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildFormArea(),
                    ),
                    const SizedBox(height: 20),
                    // 用户协议和隐私政策
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: AppTheme.buttonColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                      color: AppTheme.buttonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' 和 '),
                                  TextSpan(
                                    text: '隐私政策',
                                    style: TextStyle(
                                      color: AppTheme.buttonColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 注册按钮
                    SlideTransition(
                      position: _slideAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            foregroundColor: AppTheme.primaryTextColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            '注册',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // 登录账号链接
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
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
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: Text(
                              '立即登录',
                              style: TextStyle(
                                color: AppTheme.buttonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
          hint: '请输入您的用户名',
          icon: Icons.person_outline,
          errorText: _usernameError,
        ),
        const SizedBox(height: 20),
        // 邮箱输入框
        _buildTextField(
          controller: _emailController,
          hint: '请输入您的邮箱',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
        ),
        const SizedBox(height: 20),
        // 密码输入框
        _buildTextField(
          controller: _passwordController,
          hint: '请输入您的密码',
          icon: Icons.lock_outline,
          isPassword: true,
          errorText: _passwordError,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border:
                errorText != null
                    ? Border.all(color: AppTheme.errorColor, width: 1.5)
                    : null,
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            keyboardType: keyboardType,
            style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 16),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 20,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.hintTextColor),
              prefixIcon: Icon(
                icon,
                color:
                    errorText != null
                        ? AppTheme.errorColor
                        : AppTheme.primaryTextColor.withOpacity(0.7),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.primaryTextColor.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      )
                      : null,
            ),
            onChanged: (_) {
              // 清除输入时的错误提示
              if (errorText != null) {
                setState(() {
                  if (controller == _usernameController) _usernameError = null;
                  if (controller == _emailController) _emailError = null;
                  if (controller == _passwordController) _passwordError = null;
                });
              }
            },
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 14, color: AppTheme.errorColor),
                const SizedBox(width: 4),
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
