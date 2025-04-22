import 'package:flutter/material.dart';
import '../../app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isLinkSent = false;
  String? _emailError;

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
    _emailController.dispose();
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.primaryTextColor),
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
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  bool _validateEmail() {
    setState(() {
      _emailError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = '请输入邮箱地址';
      });
      return false;
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      setState(() {
        _emailError = '请输入有效的邮箱地址';
      });
      return false;
    }

    return true;
  }

  void _sendResetLink() {
    // 验证邮箱格式
    if (!_validateEmail()) {
      return;
    }

    // 模拟发送重置链接
    setState(() {
      _isLinkSent = true;
    });

    // 显示成功提示
    _showSuccessSnackBar('重置链接已发送至您的邮箱，请查收');

    print('发送重置链接至: ${_emailController.text}');
    // TODO: 实现发送重置链接的逻辑
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 不显示返回按钮
      ),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),
                    // 标题
                    SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        '忘记密码',
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
                        '请输入您的邮箱地址，我们将向您发送重置密码的链接',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.06),
                    // 邮箱输入框
                    SlideTransition(
                      position: _slideAnimation,
                      child: _buildTextField(
                        controller: _emailController,
                        hint: '请输入您的邮箱',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_isLinkSent)
                      SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.successColor,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '重置链接已发送',
                                    style: TextStyle(
                                      color: AppTheme.successColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '重置链接已发送至 ${_emailController.text}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '链接有效期为30分钟，请及时查收邮件并重置密码。',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: size.height * 0.04),
                    // 发送重置链接按钮
                    SlideTransition(
                      position: _slideAnimation,
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLinkSent ? null : _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isLinkSent
                                    ? AppTheme.buttonColor.withOpacity(0.5)
                                    : AppTheme.buttonColor,
                            foregroundColor: AppTheme.primaryTextColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            disabledBackgroundColor: AppTheme.buttonColor
                                .withOpacity(0.5),
                            disabledForegroundColor: AppTheme.primaryTextColor
                                .withOpacity(0.7),
                          ),
                          child: Text(
                            _isLinkSent ? '已发送重置链接' : '发送重置链接',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLinkSent)
                      SlideTransition(
                        position: _slideAnimation,
                        child: Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _isLinkSent = false;
                                _emailController.clear();
                              });
                            },
                            child: Text(
                              '使用其他邮箱地址',
                              style: TextStyle(
                                color: AppTheme.buttonColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
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
    TextInputType keyboardType = TextInputType.text,
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
            ),
            onChanged: (_) {
              // 清除输入时的错误提示
              if (errorText != null) {
                setState(() {
                  _emailError = null;
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
