import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'dart:math' as math;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _contentAnimationController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _contentAnimation;
  late Animation<double> _backgroundAnimation;

  // 设置状态变量
  bool _notificationsEnabled = true;
  bool _messageNotificationsEnabled = true;
  bool _activityNotificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _autoPlayVideos = false;
  bool _locationTrackingEnabled = true;
  bool _privacyModeEnabled = false;
  bool _highQualityImages = true;
  String _selectedLanguage = '简体中文';
  double _fontSizeScale = 1.0;
  bool _dataUsageLimitEnabled = false;
  String _selectedTheme = '深色';

  final List<String> _themeOptions = ['深色', '浅色', '系统默认'];
  final List<String> _languageOptions = ['简体中文', 'English', '日本語', '한국어'];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    );

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // 初始化背景动画
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动动画
    _animationController.forward();
    _contentAnimationController.forward();
    _backgroundAnimController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentAnimationController.dispose();
    _backgroundAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景霓虹效果
          _buildAnimatedBackground(),

          // 内容
          SafeArea(
            child: Column(
              children: [
                // 顶部导航栏
                _buildAppBar(),

                // 滚动内容
                Expanded(
                  child: FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          // 头像和用户名
                          _buildProfileHeader(),

                          const SizedBox(height: 24),

                          // 设置项
                          _buildMenuSection(),

                          const SizedBox(height: 30),

                          // 退出登录按钮
                          _buildLogoutButton(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 基础背景
            Container(
              decoration: BoxDecoration(color: AppTheme.backgroundColor),
            ),

            // 动态光晕效果1
            Positioned(
              left:
                  MediaQuery.of(context).size.width *
                  (0.3 + 0.1 * math.sin(_backgroundAnimation.value * math.pi)),
              top:
                  MediaQuery.of(context).size.height *
                  (0.2 + 0.05 * math.cos(_backgroundAnimation.value * math.pi)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonBlue.withOpacity(0.2),
                      AppTheme.neonBlue.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // 动态光晕效果2
            Positioned(
              right:
                  MediaQuery.of(context).size.width *
                  (0.1 + 0.1 * math.cos(_backgroundAnimation.value * math.pi)),
              bottom:
                  MediaQuery.of(context).size.height *
                  (0.1 + 0.05 * math.sin(_backgroundAnimation.value * math.pi)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.2),
                      AppTheme.neonPurple.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppTheme.neonBlue,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.of(context).pop(),
          ),

          Expanded(
            child: Center(
              child: Text(
                '设置',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 保持对称
          SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardColor.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.neonBlue, AppTheme.neonPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),

          const SizedBox(width: 16),

          // 用户信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '用户名',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'user@example.com',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const Spacer(),

          // 编辑按钮
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.neonTeal.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.edit, color: AppTheme.neonTeal, size: 18),
              padding: EdgeInsets.zero,
              onPressed: () {
                // 跳转到个人资料编辑页面
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardColor.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.notifications_active,
            iconColor: AppTheme.neonBlue,
            title: '通知设置',
            onTap: () {
              _showNotificationsDialog();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.dark_mode,
            iconColor: AppTheme.neonPurple,
            title: '深色模式',
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
              activeColor: Colors.white,
              activeTrackColor: AppTheme.neonPurple,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.language,
            iconColor: AppTheme.neonOrange,
            title: '语言',
            onTap: () {
              _showLanguageDialog();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.security,
            iconColor: AppTheme.neonPink,
            title: '隐私与安全',
            onTap: () {
              // 显示隐私与安全设置
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.cleaning_services,
            iconColor: AppTheme.neonGreen,
            title: '清除缓存',
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help_center,
            iconColor: AppTheme.neonTeal,
            title: '帮助中心',
            onTap: () {
              _showHelpCenterDialog();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.contact_support,
            iconColor: AppTheme.neonYellow,
            title: '联系我们',
            onTap: () {
              _showContactUsDialog();
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info,
            iconColor: AppTheme.neonBlue,
            title: '关于',
            subtitle: '版本 1.0.0',
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryTextColor.withOpacity(0.7),
                  size: 16,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.secondaryTextColor.withOpacity(0.1),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () {
        _showLogoutDialog();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppTheme.neonPink.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.neonPink.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '退出登录',
            style: TextStyle(
              color: AppTheme.neonPink,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // 对话框相关
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '通知设置',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text(
                    '接收通知',
                    style: TextStyle(color: AppTheme.primaryTextColor),
                  ),
                  subtitle: Text(
                    '开启或关闭所有通知',
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppTheme.neonBlue,
                ),
                Divider(),
                ListTile(
                  title: Text(
                    '更多通知设置',
                    style: TextStyle(color: AppTheme.primaryTextColor),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.secondaryTextColor,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // 导航到更多通知设置
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('关闭', style: TextStyle(color: AppTheme.neonBlue)),
              ),
            ],
          ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '选择语言',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  _languageOptions.map((language) {
                    return RadioListTile<String>(
                      title: Text(
                        language,
                        style: TextStyle(color: AppTheme.primaryTextColor),
                      ),
                      value: language,
                      groupValue: _selectedLanguage,
                      onChanged: (value) {
                        Navigator.pop(context);
                        if (value != null) {
                          setState(() {
                            _selectedLanguage = value;
                          });
                        }
                      },
                      activeColor: AppTheme.neonOrange,
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                ),
              ),
            ],
          ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '清除缓存',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '确定要清除所有缓存数据吗？这将删除临时文件，但不会影响您的个人数据。',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  // 执行清理缓存操作
                  Navigator.pop(context);
                  _showCacheSuccessSnackbar();
                },
                child: Text('确定', style: TextStyle(color: AppTheme.neonBlue)),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '退出登录',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '确定要退出登录吗？',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: AppTheme.secondaryTextColor),
                ),
              ),
              TextButton(
                onPressed: () {
                  // 执行退出登录操作
                  Navigator.pop(context);
                  // 退出登录逻辑
                },
                child: Text('确定', style: TextStyle(color: AppTheme.neonBlue)),
              ),
            ],
          ),
    );
  }

  void _showHelpCenterDialog() {
    // Help center dialog implementation
  }

  void _showContactUsDialog() {
    // Contact us dialog implementation
  }

  void _showAboutDialog() {
    // About dialog implementation
  }

  void _showCacheSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('缓存已成功清除'),
        backgroundColor: AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
