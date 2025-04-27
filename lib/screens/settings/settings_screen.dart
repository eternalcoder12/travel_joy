import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../widgets/circle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // 设置键名常量
  static const String KEY_NOTIFICATIONS_ENABLED = 'notifications_enabled';
  static const String KEY_MESSAGE_NOTIFICATIONS = 'message_notifications';
  static const String KEY_ACTIVITY_NOTIFICATIONS = 'activity_notifications';
  static const String KEY_DARK_MODE = 'dark_mode';
  static const String KEY_AUTO_PLAY_VIDEOS = 'auto_play_videos';
  static const String KEY_LOCATION_TRACKING = 'location_tracking';
  static const String KEY_PRIVACY_MODE = 'privacy_mode';
  static const String KEY_HIGH_QUALITY_IMAGES = 'high_quality_images';
  static const String KEY_SELECTED_LANGUAGE = 'selected_language';
  static const String KEY_FONT_SIZE_SCALE = 'font_size_scale';
  static const String KEY_DATA_USAGE_LIMIT = 'data_usage_limit';
  static const String KEY_SELECTED_THEME = 'selected_theme';

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

    // 加载保存的设置
    _loadSettings();

    // 启动动画
    _animationController.forward();
    _contentAnimationController.forward();
    _backgroundAnimController.repeat(reverse: true);
  }

  // 加载保存的设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // 读取各项设置，如果没有保存过则使用默认值
      _notificationsEnabled = prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;
      _messageNotificationsEnabled =
          prefs.getBool(KEY_MESSAGE_NOTIFICATIONS) ?? true;
      _activityNotificationsEnabled =
          prefs.getBool(KEY_ACTIVITY_NOTIFICATIONS) ?? true;
      _darkModeEnabled = prefs.getBool(KEY_DARK_MODE) ?? true;
      _autoPlayVideos = prefs.getBool(KEY_AUTO_PLAY_VIDEOS) ?? false;
      _locationTrackingEnabled = prefs.getBool(KEY_LOCATION_TRACKING) ?? true;
      _privacyModeEnabled = prefs.getBool(KEY_PRIVACY_MODE) ?? false;
      _highQualityImages = prefs.getBool(KEY_HIGH_QUALITY_IMAGES) ?? true;
      _selectedLanguage = prefs.getString(KEY_SELECTED_LANGUAGE) ?? '简体中文';
      _fontSizeScale = prefs.getDouble(KEY_FONT_SIZE_SCALE) ?? 1.0;
      _dataUsageLimitEnabled = prefs.getBool(KEY_DATA_USAGE_LIMIT) ?? false;
      _selectedTheme = prefs.getString(KEY_SELECTED_THEME) ?? '深色';
    });

    // 应用当前保存的设置
    _applySettings();
  }

  // 保存设置
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // 保存各项设置到SharedPreferences
    await prefs.setBool(KEY_NOTIFICATIONS_ENABLED, _notificationsEnabled);
    await prefs.setBool(
      KEY_MESSAGE_NOTIFICATIONS,
      _messageNotificationsEnabled,
    );
    await prefs.setBool(
      KEY_ACTIVITY_NOTIFICATIONS,
      _activityNotificationsEnabled,
    );
    await prefs.setBool(KEY_DARK_MODE, _darkModeEnabled);
    await prefs.setBool(KEY_AUTO_PLAY_VIDEOS, _autoPlayVideos);
    await prefs.setBool(KEY_LOCATION_TRACKING, _locationTrackingEnabled);
    await prefs.setBool(KEY_PRIVACY_MODE, _privacyModeEnabled);
    await prefs.setBool(KEY_HIGH_QUALITY_IMAGES, _highQualityImages);
    await prefs.setString(KEY_SELECTED_LANGUAGE, _selectedLanguage);
    await prefs.setDouble(KEY_FONT_SIZE_SCALE, _fontSizeScale);
    await prefs.setBool(KEY_DATA_USAGE_LIMIT, _dataUsageLimitEnabled);
    await prefs.setString(KEY_SELECTED_THEME, _selectedTheme);
  }

  // 应用设置到实际功能
  void _applySettings() {
    // 应用主题模式
    final brightness = _darkModeEnabled ? Brightness.dark : Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: brightness,
        statusBarIconBrightness:
            _darkModeEnabled ? Brightness.light : Brightness.dark,
      ),
    );

    // 应用通知设置
    // 实际中可能需要通过平台通道来控制设备的通知权限

    // 应用语言设置
    // 通过应用内的本地化系统设置语言

    // 应用位置追踪设置
    // 实际实现中可能需要调用位置服务API

    // 应用隐私模式设置
    // 根据应用的需求实现
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
                          vertical: 16,
                        ),
                        children: [
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => Navigator.of(context).pop(),
            size: 38,
            iconSize: 16,
          ),

          // 标题
          Text(
            '设置',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          // 保持对称，空的占位，确保标题居中
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Material(
      color: Colors.transparent,
      child: Container(
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
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    _darkModeEnabled = !_darkModeEnabled;
                  });
                  await _saveSettings();
                  _applySettings();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonPurple.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.dark_mode,
                            color: AppTheme.neonPurple,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '深色模式',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // 使用标准Switch组件
                      Switch(
                        value: _darkModeEnabled,
                        onChanged: (value) async {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                          await _saveSettings();
                          _applySettings();
                        },
                        activeColor: AppTheme.neonPurple,
                        activeTrackColor: AppTheme.neonPurple.withOpacity(0.5),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildDivider(),
            _buildMenuItem(
              icon: Icons.settings,
              iconColor: AppTheme.neonTeal,
              title: '快速设置(优化版)',
              onTap: () {
                _showSettingsDialogWithStatefulBuilder();
              },
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
    final hasTrailing = trailing != null;

    final rowContent = Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: iconColor.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
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
    );

    // 如果有trailing组件（如Switch），则不将整行包装在InkWell中
    if (hasTrailing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: rowContent,
      );
    }

    // 否则使用InkWell实现点击效果
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: iconColor.withOpacity(0.1),
      highlightColor: iconColor.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: rowContent,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showLogoutDialog();
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: AppTheme.neonPink.withOpacity(0.2),
        highlightColor: AppTheme.neonPink.withOpacity(0.1),
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
      ),
    );
  }

  // 对话框相关
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
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
                        "通知设置",
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 24.0,
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

                      // 通知设置列表
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppTheme.neonBlue.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 全部通知开关
                            _buildNeonSwitchItem(
                              icon: Icons.notifications_active,
                              iconColor: AppTheme.neonBlue,
                              title: '接收通知',
                              subtitle: '开启或关闭所有通知',
                              value: _notificationsEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                                await _saveSettings();
                                // 请求通知权限或更新通知设置
                                // 实际应用中可能需要使用平台通道请求权限
                              },
                            ),

                            Divider(
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.15,
                              ),
                              thickness: 1,
                              height: 24,
                            ),

                            // 消息通知
                            _buildNeonSwitchItem(
                              icon: Icons.message,
                              iconColor: AppTheme.neonGreen,
                              title: '消息通知',
                              subtitle: '接收新消息提醒',
                              value: _messageNotificationsEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _messageNotificationsEnabled = value;
                                });
                                await _saveSettings();
                                // 更新消息通知设置
                              },
                            ),

                            const SizedBox(height: 16),

                            // 活动通知
                            _buildNeonSwitchItem(
                              icon: Icons.event_note,
                              iconColor: AppTheme.neonOrange,
                              title: '活动通知',
                              subtitle: '接收活动和行程相关提醒',
                              value: _activityNotificationsEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _activityNotificationsEnabled = value;
                                });
                                await _saveSettings();
                                // 更新活动通知设置
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // 完成按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(30),
                          splashColor: AppTheme.neonBlue.withOpacity(0.3),
                          highlightColor: AppTheme.neonBlue.withOpacity(0.1),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonBlue,
                                  AppTheme.neonPurple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
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
                        Icons.notifications_active,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // 创建霓虹风格的开关项
  Widget _buildNeonSwitchItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onChanged(!value); // 点击整行时切换开关
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // 图标容器
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 22)),
              ),
              const SizedBox(width: 16),

              // 文本区域
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
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // 使用Flutter标准Switch组件
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: iconColor,
                activeTrackColor: iconColor.withOpacity(0.5),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
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
                        color: AppTheme.neonOrange.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.neonOrange.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        "选择语言",
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: AppTheme.neonOrange.withOpacity(0.3),
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
                              AppTheme.neonOrange.withOpacity(0.5),
                              AppTheme.neonYellow.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonOrange.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // 语言选择列表
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppTheme.neonOrange.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children:
                              _languageOptions.map((language) {
                                final isSelected =
                                    language == _selectedLanguage;
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedLanguage = language;
                                      });
                                      Navigator.pop(context);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 16,
                                      ),
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppTheme.neonOrange
                                                    .withOpacity(0.15)
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppTheme.neonOrange
                                                      .withOpacity(0.5)
                                                  : Colors.transparent,
                                          width: 1,
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: AppTheme.neonOrange
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ]
                                                : [],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? AppTheme.neonOrange
                                                          .withOpacity(0.2)
                                                      : AppTheme.cardColor
                                                          .withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons.language,
                                              color:
                                                  isSelected
                                                      ? AppTheme.neonOrange
                                                      : AppTheme
                                                          .secondaryTextColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            language,
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? AppTheme.neonOrange
                                                      : AppTheme
                                                          .primaryTextColor,
                                              fontSize: 16,
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // 完成按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(30),
                          splashColor: AppTheme.neonOrange.withOpacity(0.3),
                          highlightColor: AppTheme.neonOrange.withOpacity(0.1),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonOrange,
                                  AppTheme.neonYellow,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonOrange.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
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
                          colors: [AppTheme.neonOrange, AppTheme.neonYellow],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonOrange.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPrivacySecurityDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
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
                        color: AppTheme.neonPink.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.neonPink.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Text(
                        "隐私与安全",
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: AppTheme.neonPink.withOpacity(0.3),
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
                              AppTheme.neonPink.withOpacity(0.5),
                              AppTheme.neonPurple.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonPink.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // 隐私设置列表
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: AppTheme.neonPink.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // 隐私模式
                            _buildNeonSwitchItem(
                              icon: Icons.visibility_off,
                              iconColor: AppTheme.neonPink,
                              title: '隐私模式',
                              subtitle: '开启后，您的个人资料对其他用户不可见',
                              value: _privacyModeEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _privacyModeEnabled = value;
                                });
                                await _saveSettings();
                                // 更新隐私模式设置
                              },
                            ),

                            Divider(
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.15,
                              ),
                              thickness: 1,
                              height: 24,
                            ),

                            // 位置追踪
                            _buildNeonSwitchItem(
                              icon: Icons.location_on,
                              iconColor: AppTheme.neonBlue,
                              title: '位置追踪',
                              subtitle: '允许应用获取您的位置信息',
                              value: _locationTrackingEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _locationTrackingEnabled = value;
                                });
                                await _saveSettings();
                                // 更新位置追踪设置
                                // 如果禁用，可能需要停止位置服务
                                // 如果启用，可能需要请求位置权限
                              },
                            ),

                            Divider(
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.15,
                              ),
                              thickness: 1,
                              height: 24,
                            ),

                            // 密码与安全
                            _buildNeonOptionItem(
                              icon: Icons.lock,
                              iconColor: AppTheme.neonPurple,
                              title: '密码与安全',
                              subtitle: '更改密码和安全设置',
                              onTap: () {
                                Navigator.pop(context);
                                // 导航到密码与安全设置页面
                              },
                            ),

                            const SizedBox(height: 16),

                            // 隐私政策
                            _buildNeonOptionItem(
                              icon: Icons.policy,
                              iconColor: AppTheme.neonTeal,
                              title: '隐私政策',
                              subtitle: '查看我们的隐私政策',
                              onTap: () {
                                Navigator.pop(context);
                                // 显示隐私政策
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24.0),

                      // 完成按钮
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(30),
                          splashColor: AppTheme.neonPink.withOpacity(0.3),
                          highlightColor: AppTheme.neonPink.withOpacity(0.1),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.neonPink,
                                  AppTheme.neonPurple,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonPink.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '完成',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
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
                          colors: [AppTheme.neonPink, AppTheme.neonPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPink.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(30),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
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
          child: Icon(icon, color: color, size: 24),
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
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(22.5),
                        splashColor: AppTheme.neonBlue.withOpacity(0.2),
                        highlightColor: AppTheme.neonBlue.withOpacity(0.1),
                        child: Container(
                          width: 45,
                          height: 45,
                          margin: EdgeInsets.all(8),
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
                    child: Icon(Icons.info, color: Colors.white, size: 40.0),
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
  Widget _buildHelpItem(
    String question,
    String answer,
    IconData icon,
    Color color,
  ) {
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
              Material(
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () {
                    // 执行退出登录操作
                    Navigator.pop(context);
                    // 实际的退出登录逻辑
                    // 清除用户会话、重定向到登录页面等
                  },
                  child: Text('确定', style: TextStyle(color: AppTheme.neonBlue)),
                ),
              ),
            ],
          ),
    );
  }

  // 创建霓虹风格的选项项
  Widget _buildNeonOptionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: iconColor.withOpacity(0.1),
      highlightColor: iconColor.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
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
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
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

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cleaning_services,
                    color: AppTheme.neonGreen,
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  '清除缓存',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              '确定要清除所有缓存数据吗？这将删除临时文件，但不会影响您的个人数据。',
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            actions: [
              Material(
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    '取消',
                    style: TextStyle(color: AppTheme.secondaryTextColor),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    // 显示加载指示器
                    _showLoadingDialog(context);

                    // 执行实际的缓存清理
                    try {
                      await _clearCache();
                      // 关闭加载指示器
                      Navigator.pop(context);
                      // 显示成功提示
                      _showCacheSuccessSnackbar();
                    } catch (e) {
                      // 关闭加载指示器
                      Navigator.pop(context);
                      // 显示错误提示
                      _showErrorSnackbar('清除缓存失败: ${e.toString()}');
                    }
                  },
                  child: Text(
                    '确定',
                    style: TextStyle(color: AppTheme.neonGreen),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.neonGreen,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '正在清除缓存...',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                            '如何编辑个人资料？',
                            '进入\'我的信息\'页面，点击右上角的编辑按钮即可修改您的个人信息。',
                            Icons.person,
                            AppTheme.neonTeal,
                          ),

                          Divider(
                            color: AppTheme.secondaryTextColor.withOpacity(
                              0.15,
                            ),
                            thickness: 1,
                            height: 30,
                          ),

                          _buildHelpItem(
                            '如何查看我的旅行足迹？',
                            '在\'我的\'页面点击\'旅行足迹\'，您可以查看所有已记录的旅行历史。',
                            Icons.map,
                            AppTheme.neonPurple,
                          ),

                          Divider(
                            color: AppTheme.secondaryTextColor.withOpacity(
                              0.15,
                            ),
                            thickness: 1,
                            height: 30,
                          ),

                          _buildHelpItem(
                            '如何兑换积分？',
                            '在\'积分兑换\'页面，您可以查看所有可兑换的物品并使用积分进行兑换。',
                            Icons.card_giftcard,
                            AppTheme.neonBlue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 按钮
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 45,
                        height: 45,
                        margin: EdgeInsets.all(8),
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
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.15,
                              ),
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
                        _buildSocialButton(
                          Icons.chat_bubble,
                          AppTheme.neonGreen,
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(Icons.share, AppTheme.neonPurple),
                      ],
                    ),

                    const SizedBox(height: 30.0),

                    // 关闭按钮
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(22.5),
                        splashColor: AppTheme.neonBlue.withOpacity(0.2),
                        highlightColor: AppTheme.neonBlue.withOpacity(0.1),
                        child: Container(
                          width: 45,
                          height: 45,
                          margin: EdgeInsets.all(8),
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

  // 实际清除缓存的函数
  Future<void> _clearCache() async {
    try {
      int clearedFiles = 0;

      // 清理临时文件
      final cacheDir = await getTemporaryDirectory();
      if (cacheDir.existsSync()) {
        final entities = cacheDir.listSync();
        for (var entity in entities) {
          if (entity is File) {
            try {
              await entity.delete();
              clearedFiles++;
            } catch (e) {
              print('删除文件失败: ${e.toString()}');
            }
          } else if (entity is Directory) {
            try {
              await entity.delete(recursive: true);
              clearedFiles++;
            } catch (e) {
              print('删除目录失败: ${e.toString()}');
            }
          }
        }
      }

      // 清理图片缓存
      await DefaultCacheManager().emptyCache();

      // 获取清理前后的缓存大小
      print('共清理了 $clearedFiles 个文件/目录');
    } catch (e) {
      print('清除缓存时出错: ${e.toString()}');
      rethrow;
    }
  }

  void _showCacheSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('缓存已成功清除'),
          ],
        ),
        backgroundColor: AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // 添加一个使用StatefulBuilder的示例对话框方法
  void _showSettingsDialogWithStatefulBuilder() {
    bool tempNotificationsEnabled = _notificationsEnabled;
    bool tempDarkModeEnabled = _darkModeEnabled;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext dialogContext) {
        // 使用StatefulBuilder来管理对话框内部状态
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '快速设置',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: AppTheme.neonBlue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              // 通知开关 - 使用局部setState更新UI
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      tempNotificationsEnabled =
                                          !tempNotificationsEnabled;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.neonBlue
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.neonBlue
                                                    .withOpacity(0.2),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.notifications_active,
                                              color: AppTheme.neonBlue,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '接收通知',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '开启或关闭所有通知',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme
                                                          .secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: tempNotificationsEnabled,
                                          onChanged: (value) {
                                            // 使用StatefulBuilder的setState
                                            setState(() {
                                              tempNotificationsEnabled = value;
                                            });
                                          },
                                          activeColor: AppTheme.neonBlue,
                                          activeTrackColor: AppTheme.neonBlue
                                              .withOpacity(0.5),
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: Colors.grey
                                              .withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              Divider(
                                color: AppTheme.secondaryTextColor.withOpacity(
                                  0.15,
                                ),
                                thickness: 1,
                                height: 24,
                              ),

                              // 深色模式开关 - 使用局部setState更新UI
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      tempDarkModeEnabled =
                                          !tempDarkModeEnabled;
                                    });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.neonPurple
                                                .withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.neonPurple
                                                    .withOpacity(0.2),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.dark_mode,
                                              color: AppTheme.neonPurple,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '深色模式',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme.primaryTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                '切换应用的显示模式',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme
                                                          .secondaryTextColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: tempDarkModeEnabled,
                                          onChanged: (value) {
                                            // 使用StatefulBuilder的setState
                                            setState(() {
                                              tempDarkModeEnabled = value;
                                            });
                                          },
                                          activeColor: AppTheme.neonPurple,
                                          activeTrackColor: AppTheme.neonPurple
                                              .withOpacity(0.5),
                                          inactiveThumbColor: Colors.white,
                                          inactiveTrackColor: Colors.grey
                                              .withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 取消按钮
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                '取消',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // 保存按钮
                            ElevatedButton(
                              onPressed: () async {
                                // 将临时变量的值保存到实际设置
                                this.setState(() {
                                  _notificationsEnabled =
                                      tempNotificationsEnabled;
                                  _darkModeEnabled = tempDarkModeEnabled;
                                });

                                // 保存设置并应用更改
                                await _saveSettings();
                                _applySettings();

                                // 关闭对话框
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.neonBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('保存'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 顶部浮动图标
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
                          Icons.settings,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
