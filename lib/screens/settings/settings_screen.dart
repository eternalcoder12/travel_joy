import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../widgets/circle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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
  bool _locationTrackingEnabled = false; // 默认禁用位置追踪
  bool _privacyModeEnabled = false;
  bool _highQualityImages = true;
  String _selectedLanguage = '简体中文'; // 固定为简体中文
  double _fontSizeScale = 1.0;
  bool _dataUsageLimitEnabled = false;
  String _selectedTheme = '深色'; // 固定为深色主题

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

    // 读取各项设置，如果没有保存过则使用默认值
    bool notificationsEnabled =
        prefs.getBool(KEY_NOTIFICATIONS_ENABLED) ?? true;

    // 检查权限状态与存储的设置是否一致
    bool hasNotificationPermission = await _checkNotificationPermission();

    setState(() {
      // 存储的设置必须与实际权限状态一致
      _notificationsEnabled = notificationsEnabled && hasNotificationPermission;
      
      // 位置权限相关功能禁用
      _locationTrackingEnabled = false;

      // 其他设置不需要权限检查
      _messageNotificationsEnabled =
          prefs.getBool(KEY_MESSAGE_NOTIFICATIONS) ?? true;
      _activityNotificationsEnabled =
          prefs.getBool(KEY_ACTIVITY_NOTIFICATIONS) ?? true;
      _darkModeEnabled = prefs.getBool(KEY_DARK_MODE) ?? true;
      _autoPlayVideos = prefs.getBool(KEY_AUTO_PLAY_VIDEOS) ?? false;
      _privacyModeEnabled = prefs.getBool(KEY_PRIVACY_MODE) ?? false;
      _highQualityImages = prefs.getBool(KEY_HIGH_QUALITY_IMAGES) ?? true;
      
      // 固定语言和主题设置
      _selectedLanguage = '简体中文';
      _selectedTheme = '深色';
      
      _fontSizeScale = prefs.getDouble(KEY_FONT_SIZE_SCALE) ?? 1.0;
      _dataUsageLimitEnabled = prefs.getBool(KEY_DATA_USAGE_LIMIT) ?? false;
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
    await prefs.setBool(KEY_PRIVACY_MODE, _privacyModeEnabled);
    await prefs.setBool(KEY_HIGH_QUALITY_IMAGES, _highQualityImages);
    await prefs.setDouble(KEY_FONT_SIZE_SCALE, _fontSizeScale);
    await prefs.setBool(KEY_DATA_USAGE_LIMIT, _dataUsageLimitEnabled);
    
    // 不再保存位置追踪设置
    // 不再保存语言和主题设置
  }

  // 修改应用设置到实际功能
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
                          _buildSettingsSection(),

                          const SizedBox(height: 20),
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

  // 更新后的设置区域构建方法
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 连续列表容器
        Container(
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
              // 通知设置
              _buildSimpleSettingItem(
                icon: Icons.notifications_active,
                iconColor: AppTheme.neonBlue,
                title: '接收通知',
                subtitle: '开启或关闭所有通知',
                value: _notificationsEnabled,
                onTap: () async {
                  if (_notificationsEnabled) {
                    // 关闭权限前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '关闭通知',
                      content: '关闭通知后，您将不会收到任何新消息或活动的提醒。确定要关闭吗？',
                      confirmText: '关闭',
                    );
                    if (confirm) {
                      await _toggleNotifications();
                    }
                  } else {
                    // 请求开启权限前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '开启通知',
                      content: '开启通知后，您将收到新消息和活动的提醒。需要授予应用通知权限。',
                      confirmText: '开启',
                    );
                    if (confirm) {
                      await _toggleNotifications();
                    }
                  }
                },
              ),

              _buildDivider(),

              // 深色模式
              _buildSimpleSettingItem(
                icon: Icons.dark_mode,
                iconColor: AppTheme.neonPurple,
                title: '深色模式',
                subtitle: '切换应用的显示模式',
                value: _darkModeEnabled,
                onTap: () async {
                  if (_darkModeEnabled) {
                    // 关闭深色模式前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '切换到浅色模式',
                      content: '切换到浅色模式后，应用界面将使用浅色背景。确定要切换吗？',
                      confirmText: '切换',
                    );
                    if (confirm) {
                      setState(() {
                        _darkModeEnabled = false;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  } else {
                    // 开启深色模式前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '切换到深色模式',
                      content: '切换到深色模式后，应用界面将使用深色背景，这有助于减少夜间使用时的眼睛疲劳。确定要切换吗？',
                      confirmText: '切换',
                    );
                    if (confirm) {
                      setState(() {
                        _darkModeEnabled = true;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  }
                },
              ),

              _buildDivider(),

              // 自动播放视频
              _buildSimpleSettingItem(
                icon: Icons.play_circle_outline,
                iconColor: AppTheme.neonGreen,
                title: '自动播放视频',
                subtitle: '滚动时自动播放视频',
                value: _autoPlayVideos,
                onTap: () async {
                  if (_autoPlayVideos) {
                    // 关闭自动播放视频前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '关闭自动播放视频',
                      content: '关闭自动播放视频后，您需要手动点击播放视频。确定要关闭吗？',
                      confirmText: '关闭',
                    );
                    if (confirm) {
                      setState(() {
                        _autoPlayVideos = false;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  } else {
                    // 开启自动播放视频前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '开启自动播放视频',
                      content: '开启自动播放视频后，滚动浏览时视频将自动播放，这可能会增加数据流量消耗。确定要开启吗？',
                      confirmText: '开启',
                    );
                    if (confirm) {
                      setState(() {
                        _autoPlayVideos = true;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  }
                },
              ),

              _buildDivider(),

              // 位置追踪
              _buildSimpleSettingItem(
                icon: Icons.location_on,
                iconColor: Colors.grey, // 使用灰色表示禁用
                title: '位置追踪',
                subtitle: '功能已禁用',
                value: false, // 始终显示为关闭
                onTap: () async {
                  // 显示功能禁用提示
                  _showErrorSnackbar('位置追踪功能已禁用');
                },
              ),

              _buildDivider(),

              // 隐私模式
              _buildSimpleSettingItem(
                icon: Icons.security,
                iconColor: AppTheme.neonPink,
                title: '隐私模式',
                subtitle: '提高用户隐私保护级别',
                value: _privacyModeEnabled,
                onTap: () async {
                  if (_privacyModeEnabled) {
                    // 关闭隐私模式前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '关闭隐私模式',
                      content: '关闭隐私模式后，您的个人资料将对其他用户可见。确定要关闭吗？',
                      confirmText: '关闭',
                    );
                    if (confirm) {
                      setState(() {
                        _privacyModeEnabled = false;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  } else {
                    // 开启隐私模式前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '开启隐私模式',
                      content: '开启隐私模式后，您的个人资料将对其他用户不可见，但可能会限制部分社交功能的使用。确定要开启吗？',
                      confirmText: '开启',
                    );
                    if (confirm) {
                      setState(() {
                        _privacyModeEnabled = true;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  }
                },
              ),

              _buildDivider(),

              // 高质量图片
              _buildSimpleSettingItem(
                icon: Icons.high_quality,
                iconColor: AppTheme.neonTeal,
                title: '高质量图片',
                subtitle: '显示更清晰的图片',
                value: _highQualityImages,
                onTap: () async {
                  if (_highQualityImages) {
                    // 关闭高质量图片设置前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '关闭高质量图片',
                      content: '关闭高质量图片后，应用将加载压缩后的图片，以节省流量。图片清晰度可能降低。确定要关闭吗？',
                      confirmText: '关闭',
                    );
                    if (confirm) {
                      setState(() {
                        _highQualityImages = false;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  } else {
                    // 开启高质量图片设置前询问用户确认
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '开启高质量图片',
                      content: '开启高质量图片后，应用将加载高分辨率图片，这将提供更清晰的视觉体验，但可能会增加数据流量消耗。确定要开启吗？',
                      confirmText: '开启',
                    );
                    if (confirm) {
                      setState(() {
                        _highQualityImages = true;
                      });
                      await _saveSettings();
                      _applySettings();
                    }
                  }
                },
              ),

              _buildDivider(),

              // 语言设置 - 改用下拉框
              _buildSimpleMenuItem(
                icon: Icons.language,
                iconColor: Colors.grey, // 使用灰色表示禁用
                title: '语言',
                dropdownOptions: _languageOptions,
                selectedValue: _selectedLanguage,
                onChanged: null, // 设为null表示禁用
                onTap: () {
                  // 显示功能禁用提示
                  _showErrorSnackbar('语言切换功能暂未开放');
                },
              ),

              _buildDivider(),

              // 主题设置 - 改用下拉框
              _buildSimpleMenuItem(
                icon: Icons.palette,
                iconColor: Colors.grey, // 使用灰色表示禁用
                title: '主题',
                dropdownOptions: _themeOptions,
                selectedValue: _selectedTheme,
                onChanged: null, // 设为null表示禁用
                onTap: () {
                  // 显示功能禁用提示
                  _showErrorSnackbar('主题切换功能暂未开放');
                },
              ),

              _buildDivider(),

              // 字体大小选择
              _buildSimpleMenuItem(
                icon: Icons.text_fields,
                iconColor: AppTheme.neonOrange,
                title: '字体大小',
                subtitle: _getFontSizeText(),
                trailingIcon: Icons.arrow_forward_ios,
                onTap: _showFontSizeSelector,
              ),

              _buildDivider(),

              // 清除缓存
              _buildSimpleMenuItem(
                icon: Icons.cleaning_services,
                iconColor: AppTheme.neonGreen,
                title: '清除缓存',
                trailingIcon: Icons.arrow_forward_ios,
                onTap: () {
                  _showClearCacheDialog();
                },
              ),

              _buildDivider(),

              // 帮助中心
              _buildSimpleMenuItem(
                icon: Icons.help_outline,
                iconColor: AppTheme.neonTeal,
                title: '帮助中心',
                trailingIcon: Icons.arrow_forward_ios,
                onTap: () {
                  _showHelpCenterDialog();
                },
              ),

              _buildDivider(),

              // 联系我们
              _buildSimpleMenuItem(
                icon: Icons.contact_support,
                iconColor: AppTheme.neonYellow,
                title: '联系我们',
                trailingIcon: Icons.arrow_forward_ios,
                onTap: () {
                  _showContactUsDialog();
                },
              ),

              _buildDivider(),

              // 关于
              _buildSimpleMenuItem(
                icon: Icons.info_outline,
                iconColor: AppTheme.neonBlue,
                title: '关于',
                subtitle: '版本 1.0.0',
                trailingIcon: Icons.arrow_forward_ios,
                onTap: () {
                  _showAboutDialog();
                },
              ),

              _buildDivider(),

              // 退出登录按钮
              InkWell(
                onTap: () {
                  _showLogoutDialog();
                },
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.neonPink.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.logout,
                            color: AppTheme.neonPink,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '退出登录',
                        style: TextStyle(
                          color: AppTheme.neonPink,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 简单设置项（开关类型）
  Widget _buildSimpleSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 图标
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),

            const SizedBox(width: 12),

            // 文本
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

            // 状态指示器
            Container(
              width: 56,
              height: 30,
              decoration: BoxDecoration(
                color:
                    value
                        ? iconColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  value ? '开启' : '关闭',
                  style: TextStyle(
                    color: value ? iconColor : AppTheme.secondaryTextColor,
                    fontSize: 14,
                    fontWeight: value ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 修改_buildSimpleMenuItem方法，为语言和主题选项添加下拉框支持
  Widget _buildSimpleMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    IconData? trailingIcon,
    required VoidCallback onTap,
    List<String>? dropdownOptions,
    String? selectedValue,
    Function(String?)? onChanged,
  }) {
    final bool isDisabled = onChanged == null && dropdownOptions != null;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailingIcon != null)
              Icon(
                trailingIcon,
                color: AppTheme.secondaryTextColor,
                size: 18,
              ),
            if (dropdownOptions != null)
              InkWell(
                onTap: isDisabled ? null : () {
                  if (title == '语言') {
                    _showSelectionDialog(
                      title: title,
                      options: dropdownOptions,
                      selectedValue: selectedValue,
                      onSelected: onChanged,
                      iconColor: iconColor,
                      icon: Icons.language,
                    );
                  } else {
                    _showSelectionDialog(
                      title: title,
                      options: dropdownOptions,
                      selectedValue: selectedValue,
                      onSelected: onChanged,
                      iconColor: iconColor,
                      icon: Icons.palette,
                    );
                  }
                },
                child: Row(
                  children: [
                    Text(
                      selectedValue ?? '',
                      style: TextStyle(
                        color: isDisabled ? Colors.grey : 
                            title == '语言'
                                ? AppTheme.neonOrange
                                : AppTheme.neonPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.check,
                      color: isDisabled ? Colors.grey :
                          title == '语言'
                              ? AppTheme.neonOrange
                              : AppTheme.neonPurple,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDisabled ? Colors.grey.withOpacity(0.5) : AppTheme.secondaryTextColor,
                      size: 18,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  // 使用精美弹窗来显示选择项
  void _showSelectionDialog({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?)? onSelected,
    required Color iconColor,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.cardColor.withOpacity(0.95),
                      AppTheme.backgroundColor.withOpacity(0.97),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: iconColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // 滑动指示条
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),

                    // 标题区域
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(
                        children: [
                          // 图标
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  iconColor,
                                  title == '语言'
                                      ? AppTheme.neonYellow
                                      : AppTheme.neonBlue,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: iconColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: Colors.white, size: 22),
                          ),
                          SizedBox(width: 16),

                          // 标题文字
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "选择$title",
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  "当前选择: ${selectedValue ?? '无'}",
                                  style: TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 关闭按钮
                          Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.close,
                                  color: AppTheme.secondaryTextColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 分隔线
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            iconColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    // 选项列表
                    Expanded(
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options[index];
                          final bool isSelected = option == selectedValue;

                          // 为每个选项确定图标
                          IconData optionIcon;
                          if (title == '语言') {
                            if (option == '简体中文') {
                              optionIcon = Icons.language;
                            } else if (option == 'English') {
                              optionIcon = Icons.emoji_flags;
                            } else if (option == '日本語') {
                              optionIcon = Icons.map;
                            } else {
                              optionIcon = Icons.translate;
                            }
                          } else {
                            if (option == '深色') {
                              optionIcon = Icons.dark_mode;
                            } else if (option == '浅色') {
                              optionIcon = Icons.light_mode;
                            } else {
                              optionIcon = Icons.settings_system_daydream;
                            }
                          }

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (onSelected != null) {
                                    onSelected(option);
                                  }
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient:
                                        isSelected
                                            ? LinearGradient(
                                              colors: [
                                                iconColor.withOpacity(0.2),
                                                (title == '语言'
                                                        ? AppTheme.neonYellow
                                                        : AppTheme.neonBlue)
                                                    .withOpacity(0.1),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            )
                                            : null,
                                    color:
                                        isSelected
                                            ? null
                                            : Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? iconColor.withOpacity(0.3)
                                              : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: iconColor.withOpacity(
                                                  0.15,
                                                ),
                                                blurRadius: 8,
                                                spreadRadius: 0,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                            : null,
                                  ),
                                  child: Row(
                                    children: [
                                      // 选项图标
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              isSelected
                                                  ? iconColor.withOpacity(0.2)
                                                  : Colors.grey.withOpacity(
                                                    0.1,
                                                  ),
                                          boxShadow:
                                              isSelected
                                                  ? [
                                                    BoxShadow(
                                                      color: iconColor
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      spreadRadius: 0,
                                                    ),
                                                  ]
                                                  : null,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            optionIcon,
                                            color:
                                                isSelected
                                                    ? iconColor
                                                    : Colors.grey,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),

                                      // 选项文本
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? AppTheme.primaryTextColor
                                                    : Colors.grey[300],
                                            fontSize: isSelected ? 17 : 16,
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                          ),
                                        ),
                                      ),

                                      // 选中标记
                                      if (isSelected)
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: iconColor.withOpacity(0.2),
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: iconColor,
                                            size: 20,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 底部确认按钮
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            height: 54,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  iconColor,
                                  title == '语言'
                                      ? AppTheme.neonYellow
                                      : AppTheme.neonBlue,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: iconColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '确认选择',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                                if (_notificationsEnabled && !value) {
                                  // 从开启切换到关闭
                                  bool confirm = await _showPermissionConfirmDialog(
                                    title: '关闭通知',
                                    content: '关闭通知后，您将不会收到任何新消息或活动的提醒。确定要关闭吗？',
                                    confirmText: '关闭',
                                  );
                                  if (confirm) {
                                    await _toggleNotifications();
                                  }
                                } else if (!_notificationsEnabled && value) {
                                  // 从关闭切换到开启
                                  bool confirm = await _showPermissionConfirmDialog(
                                    title: '开启通知',
                                    content: '开启通知后，您将收到新消息和活动的提醒。需要授予应用通知权限。',
                                    confirmText: '开启',
                                  );
                                  if (confirm) {
                                    await _toggleNotifications();
                                  }
                                }
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
        onTap: () async {
          // 点击整行时不直接切换开关，而是弹出确认对话框
          if (value) {
            // 如果当前为开启状态，询问是否关闭
            bool confirm = await _showPermissionConfirmDialog(
              title: '关闭${title}',
              content: '确定要关闭${title}吗？',
              confirmText: '关闭',
            );
            if (confirm) {
              onChanged(false);
            }
          } else {
            // 如果当前为关闭状态，询问是否开启
            bool confirm = await _showPermissionConfirmDialog(
              title: '开启${title}',
              content: '确定要开启${title}吗？',
              confirmText: '开启',
            );
            if (confirm) {
              onChanged(true);
            }
          }
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
                onChanged: (newValue) async {
                  // Switch组件的onChanged回调中也添加确认对话框
                  if (value && !newValue) {
                    // 如果是从开启切换到关闭
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '关闭${title}',
                      content: '确定要关闭${title}吗？',
                      confirmText: '关闭',
                    );
                    if (confirm) {
                      onChanged(newValue);
                    }
                  } else if (!value && newValue) {
                    // 如果是从关闭切换到开启
                    bool confirm = await _showPermissionConfirmDialog(
                      title: '开启${title}',
                      content: '确定要开启${title}吗？',
                      confirmText: '开启',
                    );
                    if (confirm) {
                      onChanged(newValue);
                    }
                  }
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
                                                ? AppTheme.neonPurple
                                                    .withOpacity(0.3)
                                                : Colors.black.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  isSelected
                                                      ? AppTheme.neonOrange
                                                          .withOpacity(0.2)
                                                      : Colors.grey.withOpacity(
                                                        0.2,
                                                      ),
                                            ),
                                            child: Icon(
                                              Icons.language,
                                              color:
                                                  isSelected
                                                      ? AppTheme.neonOrange
                                                      : Colors.grey,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              language,
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.grey[300],
                                                fontSize: 16,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppTheme.neonOrange,
                                              size: 24,
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
                                if (!_privacyModeEnabled && value) {
                                  // 从关闭到开启状态
                                  bool confirm = await _showPermissionConfirmDialog(
                                    title: '开启隐私模式',
                                    content: '开启隐私模式后，您的个人资料将对其他用户不可见，但可能会限制部分社交功能的使用。确定要开启吗？',
                                    confirmText: '开启',
                                  );
                                  if (confirm) {
                                    setState(() {
                                      _privacyModeEnabled = true;
                                    });
                                    await _saveSettings();
                                  }
                                } else if (_privacyModeEnabled && !value) {
                                  // 从开启到关闭状态
                                  bool confirm = await _showPermissionConfirmDialog(
                                    title: '关闭隐私模式',
                                    content: '关闭隐私模式后，您的个人资料将对其他用户可见。确定要关闭吗？',
                                    confirmText: '关闭',
                                  );
                                  if (confirm) {
                                    setState(() {
                                      _privacyModeEnabled = false;
                                    });
                                    await _saveSettings();
                                  }
                                }
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
                              iconColor: Colors.grey, // 使用灰色表示禁用
                              title: '位置追踪',
                              subtitle: '功能已禁用',
                              value: false, // 始终显示为关闭
                              onChanged: (value) async {
                                // 显示功能禁用提示
                                _showErrorSnackbar('位置追踪功能已禁用');
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

  // 字体大小选择器
  void _showFontSizeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '选择字体大小',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  Slider(
                    value: _fontSizeScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    activeColor: AppTheme.neonOrange,
                    inactiveColor: AppTheme.neonOrange.withOpacity(0.2),
                    label: _getFontSizeText(),
                    onChanged: (value) {
                      setState(() {
                        _fontSizeScale = value;
                      });
                    },
                    onChangeEnd: (value) async {
                      this.setState(() {
                        _fontSizeScale = value;
                      });
                      await _saveSettings();
                      _applySettings();
                      // 使用更可靠的方式提供反馈，避免使用Toast
                      setState(() {
                        // 通过状态更新即可，无需额外提示
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    '预览文本大小',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14 * _fontSizeScale,
                    ),
                  ),
                  SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      '完成',
                      style: TextStyle(
                        color: AppTheme.neonOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  // 获取字体大小描述文本
  String _getFontSizeText() {
    if (_fontSizeScale <= 0.8) return '最小';
    if (_fontSizeScale <= 0.9) return '较小';
    if (_fontSizeScale <= 1.0) return '标准';
    if (_fontSizeScale <= 1.1) return '中等';
    if (_fontSizeScale <= 1.2) return '较大';
    if (_fontSizeScale <= 1.3) return '大';
    return '最大';
  }

  // 检查并请求通知权限
  Future<bool> _checkNotificationPermission() async {
    try {
      // iOS和Android平台不同的处理方式
      if (Platform.isIOS) {
        // 直接请求iOS通知权限
        print('iOS: 直接请求通知权限...');
        PermissionStatus status = await Permission.notification.request();
        print('iOS通知权限请求结果: $status');
        return status.isGranted;
      } else {
        // Android平台直接请求权限
        print('Android: 直接请求通知权限...');
        PermissionStatus status = await Permission.notification.request();
        print('Android通知权限请求结果: $status');
        return status.isGranted;
      }
    } catch (e) {
      print('检查通知权限时出错: $e');
      return false;
    }
  }

  // 切换通知设置
  Future<void> _toggleNotifications() async {
    try {
      if (_notificationsEnabled) {
        // 从开启到关闭，直接修改状态
        setState(() {
          _notificationsEnabled = false;
        });
        await _saveSettings();
        _applySettings();
      } else {
        // 从关闭到开启，直接请求系统级权限
        bool confirm = await _showPermissionConfirmDialog(
          title: '开启通知',
          content: '开启通知后，您将收到新消息和活动的提醒。需要授予应用通知权限。',
          confirmText: '开启',
        );
        
        if (confirm) {
          final hasPermission = await _checkNotificationPermission();
          setState(() {
            _notificationsEnabled = hasPermission;
          });
          
          if (!hasPermission) {
            // 如果权限未授予，显示提示
            _showErrorSnackbar('通知权限未授予，无法开启通知功能');
          } else {
            await _saveSettings();
            _applySettings();
          }
        }
      }
    } catch (e) {
      print('切换通知设置时出错: $e');
      _showErrorSnackbar('设置通知失败，请稍后重试');
    }
  }

  // 切换暗黑模式设置
  Future<void> _toggleDarkMode() async {
    setState(() {
      _darkModeEnabled = !_darkModeEnabled;
    });
    await _saveSettings();
    // 应用设置变更
    _applySettings();
  }

  // 切换自动播放视频设置
  Future<void> _toggleAutoPlayVideos() async {
    setState(() {
      _autoPlayVideos = !_autoPlayVideos;
    });
    await _saveSettings();
    // 应用设置变更
    _applySettings();
  }

  // 切换位置追踪设置
  Future<void> _toggleLocationTracking() async {
    // 位置功能已禁用
    _showErrorSnackbar('位置追踪功能已禁用');
    return;
  }

  // 切换隐私模式设置
  Future<void> _togglePrivacyMode() async {
    setState(() {
      _privacyModeEnabled = !_privacyModeEnabled;
    });
    await _saveSettings();
    // 应用设置变更
    _applySettings();
  }

  // 切换高质量图片设置
  Future<void> _toggleHighQualityImages() async {
    setState(() {
      _highQualityImages = !_highQualityImages;
    });
    await _saveSettings();
    // 应用设置变更
    _applySettings();
  }

  // 显示权限确认对话框
  Future<bool> _showPermissionConfirmDialog({
    required String title,
    required String content,
    required String confirmText,
    String cancelText = '取消',
  }) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.neonBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 0),
          titlePadding: EdgeInsets.fromLTRB(24, 20, 24, 8),
          actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            title,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          actions: [
            // 包装在Row中以便控制布局
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size(60, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12), // 按钮之间的间距
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // 设置更小的内边距
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size(60, 32),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // 引导用户前往系统设置的对话框
  Future<bool> _showOpenSettingsDialog(String title, String content) async {
    return await _showPermissionConfirmDialog(
      title: title,
      content: content,
      confirmText: '前往设置',
      cancelText: '暂不开启'
    );
  }
}

