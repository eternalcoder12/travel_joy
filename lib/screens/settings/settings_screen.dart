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
              _showPrivacySecurityDialog();
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
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 主容器
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardColor.withOpacity(0.95),
                      AppTheme.backgroundColor.withOpacity(0.90),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      "帮助中心",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonGreen.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 分隔线
                    Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.neonGreen.withOpacity(0.5),
                            AppTheme.neonBlue.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonGreen.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 帮助项目列表
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildHelpItem(
                            "如何编辑个人资料？",
                            "进入"我的信息"页面，点击右上角的编辑按钮即可修改您的个人信息。",
                            Icons.person,
                            AppTheme.neonTeal,
                          ),
                          
                          Divider(
                            color: AppTheme.secondaryTextColor.withOpacity(0.15),
                            thickness: 1,
                            height: 30,
                          ),
                          
                          _buildHelpItem(
                            "如何查看我的旅行足迹？",
                            "在"我的"页面点击"旅行足迹"，您可以查看所有已记录的旅行历史。",
                            Icons.map,
                            AppTheme.neonPurple,
                          ),
                          
                          Divider(
                            color: AppTheme.secondaryTextColor.withOpacity(0.15),
                            thickness: 1,
                            height: 30,
                          ),
                          
                          _buildHelpItem(
                            "如何兑换积分？",
                            "在"积分兑换"页面，您可以查看所有可兑换的物品并使用积分进行兑换。",
                            Icons.card_giftcard,
                            AppTheme.neonBlue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 按钮
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppTheme.neonGreen.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.neonGreen.withOpacity(0.9),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 顶部图标
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonGreen.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.help_center,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建帮助项目
  Widget _buildHelpItem(String question, String answer, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18.0),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                question,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 38.0, top: 8.0),
          child: Text(
            answer,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14.0,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  void _showContactUsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 主容器
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardColor.withOpacity(0.95),
                      AppTheme.backgroundColor.withOpacity(0.90),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonBlue.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.neonBlue.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      "联系我们",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonBlue.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 分隔线
                    Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.neonBlue.withOpacity(0.5),
                            AppTheme.neonPurple.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonBlue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 说明文本
                    Text(
                      "如果您在使用过程中遇到任何问题，或者有任何建议，欢迎随时与我们联系。",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16.0,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // 联系方式卡片
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: AppTheme.neonBlue.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 邮箱信息
                          _buildContactItem(
                            icon: Icons.email_outlined,
                            title: "联系邮箱",
                            value: "support@traveljoy.com",
                            color: AppTheme.neonBlue,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Divider(
                              color: AppTheme.secondaryTextColor.withOpacity(0.15),
                              thickness: 1,
                            ),
                          ),

                          // 电话信息
                          _buildContactItem(
                            icon: Icons.phone_outlined,
                            title: "客服热线",
                            value: "400-888-8888",
                            color: AppTheme.neonPurple,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 社交媒体按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.public, AppTheme.neonBlue),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.chat_bubble, AppTheme.neonGreen),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.share, AppTheme.neonPurple),
                      ],
                    ),

                    const SizedBox(height: 30.0),

                    // 关闭按钮
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppTheme.neonBlue.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.neonBlue.withOpacity(0.9),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 顶部图标
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonBlue.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.contact_support,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建联系信息项
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 22.0),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建社交媒体按钮
  Widget _buildSocialButton(IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 主容器
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.cardColor.withOpacity(0.95),
                      AppTheme.backgroundColor.withOpacity(0.90),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonTeal.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.neonTeal.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      "关于 Travel Joy",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonTeal.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // 分隔线
                    Container(
                      height: 3,
                      width: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.neonTeal.withOpacity(0.5),
                            AppTheme.neonBlue.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonTeal.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 应用Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.neonBlue, AppTheme.neonPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonTeal.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.travel_explore,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 版本信息
                    Text(
                      "版本 1.0.0",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    
                    const SizedBox(height: 8.0),
                    
                    Text(
                      "构建号: 20230515001",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14.0,
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 应用介绍
                    Text(
                      "Travel Joy是您的旅行管家，帮助您记录精彩旅程，探索世界奇迹，结交各地好友。无论是城市探索还是乡村漫步，我们都将为您提供最佳旅行体验。",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14.0,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 版权信息
                    Text(
                      "© 2023 Travel Joy团队 版权所有",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 关闭按钮
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20.0),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: Border.all(
                            color: AppTheme.neonTeal.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.neonTeal.withOpacity(0.9),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 顶部图标
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonTeal, AppTheme.neonBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonTeal.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.info,
                      color: Colors.white,
                      size: 40.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showPrivacySecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppTheme.neonPink.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security, color: AppTheme.neonPink, size: 24.0),
            ),
            const SizedBox(width: 12.0),
            Text(
              '隐私与安全',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(
                '隐私模式',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              subtitle: Text(
                '开启后，您的个人资料对其他用户不可见',
                style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
              ),
              value: _privacyModeEnabled,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  _privacyModeEnabled = value;
                });
              },
              activeColor: AppTheme.neonPink,
            ),
            Divider(),
            SwitchListTile(
              title: Text(
                '位置追踪',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              subtitle: Text(
                '允许应用获取您的位置信息',
                style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
              ),
              value: _locationTrackingEnabled,
              onChanged: (value) {
                Navigator.pop(context);
                setState(() {
                  _locationTrackingEnabled = value;
                });
              },
              activeColor: AppTheme.neonPink,
            ),
            Divider(),
            ListTile(
              title: Text(
                '密码与安全',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.secondaryTextColor,
                size: 16,
              ),
              onTap: () {
                Navigator.pop(context);
                // 导航到密码与安全设置页面
              },
            ),
            Divider(),
            ListTile(
              title: Text(
                '隐私政策',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.secondaryTextColor,
                size: 16,
              ),
              onTap: () {
                Navigator.pop(context);
                // 显示隐私政策
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('关闭', style: TextStyle(color: AppTheme.neonPink)),
          ),
        ],
      ),
    );
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
