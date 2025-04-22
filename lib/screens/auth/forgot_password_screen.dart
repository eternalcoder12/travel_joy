import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/micro_interaction_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;
  String? _apiError;
  bool _linkSent = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppTheme.primaryTextColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "重置密码链接已发送，请检查您的邮箱",
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 5),
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

  bool _validateEmail() {
    setState(() {
      _emailError = null;
      _apiError = null;
    });

    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = '请输入您的邮箱地址';
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
    if (!_validateEmail()) {
      return;
    }

    setState(() {
      _linkSent = true;
    });

    _showSuccessSnackBar();

    print('发送重置链接到: ${_emailController.text}');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.8,
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.2),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),

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
                    AppTheme.neonBlue.withOpacity(0.2),
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
                    AppTheme.neonPurple.withOpacity(0.3),
                    AppTheme.neonPink.withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.06),

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
                                  AppTheme.neonBlue,
                                  AppTheme.neonPurple,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.lock_reset,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '忘记密码',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                              shadows: [
                                Shadow(
                                  color: AppTheme.neonBlue.withOpacity(0.5),
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
                        '请输入您的邮箱地址，我们将发送重置密码链接',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    SlideTransition(
                      position: _slideAnimation,
                      child: GlassCard(
                        borderRadius: 24,
                        blur: 10,
                        opacity: 0.1,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _buildEmailField(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SlideTransition(
                      position: _slideAnimation,
                      child:
                          _linkSent
                              ? _buildLinkSentConfirmation()
                              : MicroInteractionButton(
                                text: '发送重置链接',
                                icon: Icons.send,
                                backgroundColor: AppTheme.buttonColor,
                                onPressed: _sendResetLink,
                              ),
                    ),

                    const SizedBox(height: 24),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '记起密码了？',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '登录',
                              style: TextStyle(
                                color: AppTheme.neonBlue,
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow:
                _emailError != null
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
                _emailError != null
                    ? Border.all(color: AppTheme.errorColor, width: 1)
                    : null,
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: AppTheme.primaryTextColor),
            decoration: InputDecoration(
              hintText: '请输入您的邮箱',
              hintStyle: TextStyle(color: AppTheme.hintTextColor),
              prefixIcon: Icon(Icons.email, color: AppTheme.secondaryTextColor),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
        if (_emailError != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 6, left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, size: 14, color: AppTheme.errorColor),
                const SizedBox(width: 5),
                Text(
                  _emailError!,
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLinkSentConfirmation() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '重置链接已发送',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '请检查您的邮箱 ${_emailController.text}',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GradientButton(
          gradient: LinearGradient(
            colors: [AppTheme.neonBlue, AppTheme.neonPurple],
          ),
          text: '重新发送',
          onPressed: _sendResetLink,
        ),
      ],
    );
  }
}
