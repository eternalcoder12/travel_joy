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
                        padding: const EdgeInsets.all(16),
                        children: [
                          // 账户与隐私设置卡片
                          _buildSettingsCard(
                            title: '账户与隐私',
                            icon: Icons.person,
                            iconColor: AppTheme.neonTeal,
                            children: [
                              _buildDivider(),
                              _buildSettingItem(
                                title: '个人资料',
                                icon: Icons.account_circle,
                                iconColor: AppTheme.neonTeal,
                                onTap: () {
                                  // 导航到个人资料页面
                                },
                                showArrow: true,
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '隐私模式',
                                subtitle: '开启后，您的个人资料对其他用户不可见',
                                icon: Icons.security,
                                iconColor: AppTheme.neonPurple,
                                value: _privacyModeEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _privacyModeEnabled = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '位置追踪',
                                subtitle: '允许应用获取您的位置信息',
                                icon: Icons.location_on,
                                iconColor: AppTheme.neonPink,
                                value: _locationTrackingEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _locationTrackingEnabled = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '密码与安全',
                                icon: Icons.lock,
                                iconColor: AppTheme.neonOrange,
                                onTap: () {
                                  // 导航到密码与安全页面
                                },
                                showArrow: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 通知设置卡片
                          _buildSettingsCard(
                            title: '通知设置',
                            icon: Icons.notifications,
                            iconColor: AppTheme.neonBlue,
                            children: [
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '接收通知',
                                subtitle: '开启或关闭所有通知',
                                icon: Icons.notifications_active,
                                iconColor: AppTheme.neonBlue,
                                value: _notificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '消息提醒',
                                subtitle: '关于新消息的通知',
                                icon: Icons.message,
                                iconColor: AppTheme.neonGreen,
                                value: _messageNotificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _messageNotificationsEnabled = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '活动提醒',
                                subtitle: '关于活动和促销的通知',
                                icon: Icons.local_activity,
                                iconColor: AppTheme.neonYellow,
                                value: _activityNotificationsEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _activityNotificationsEnabled = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 外观与显示卡片
                          _buildSettingsCard(
                            title: '外观与显示',
                            icon: Icons.palette,
                            iconColor: AppTheme.neonPurple,
                            children: [
                              _buildDivider(),
                              _buildDropdownSettingItem(
                                title: '主题',
                                icon: Icons.color_lens,
                                iconColor: AppTheme.neonPurple,
                                value: _selectedTheme,
                                items: _themeOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedTheme = newValue;
                                      _darkModeEnabled = newValue == '深色';
                                    });
                                  }
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '深色模式',
                                subtitle: '切换深色/浅色外观',
                                icon: Icons.dark_mode,
                                iconColor: AppTheme.neonBlue,
                                value: _darkModeEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _darkModeEnabled = value;
                                    _selectedTheme = value ? '深色' : '浅色';
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildDropdownSettingItem(
                                title: '语言',
                                icon: Icons.language,
                                iconColor: AppTheme.neonOrange,
                                value: _selectedLanguage,
                                items: _languageOptions,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedLanguage = newValue;
                                    });
                                  }
                                },
                              ),
                              _buildDivider(),
                              _buildSliderSettingItem(
                                title: '字体大小',
                                icon: Icons.text_fields,
                                iconColor: AppTheme.neonGreen,
                                value: _fontSizeScale,
                                min: 0.8,
                                max: 1.4,
                                divisions: 6,
                                onChanged: (value) {
                                  setState(() {
                                    _fontSizeScale = value;
                                  });
                                },
                                valueLabel: _getFontSizeLabel(),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 数据与存储卡片
                          _buildSettingsCard(
                            title: '数据与存储',
                            icon: Icons.storage,
                            iconColor: AppTheme.neonYellow,
                            children: [
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '自动播放视频',
                                subtitle: '仅在WiFi网络下自动播放',
                                icon: Icons.play_circle_fill,
                                iconColor: AppTheme.neonPink,
                                value: _autoPlayVideos,
                                onChanged: (value) {
                                  setState(() {
                                    _autoPlayVideos = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '高画质图片',
                                subtitle: '显示高分辨率图片',
                                icon: Icons.high_quality,
                                iconColor: AppTheme.neonPink,
                                value: _highQualityImages,
                                onChanged: (value) {
                                  setState(() {
                                    _highQualityImages = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSwitchSettingItem(
                                title: '移动网络流量限制',
                                subtitle: '节省移动数据流量使用',
                                icon: Icons.data_usage,
                                iconColor: AppTheme.neonTeal,
                                value: _dataUsageLimitEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _dataUsageLimitEnabled = value;
                                  });
                                },
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '清除缓存',
                                subtitle: '已使用 127MB 存储空间',
                                icon: Icons.cleaning_services,
                                iconColor: AppTheme.neonBlue,
                                onTap: () {
                                  _showClearCacheDialog();
                                },
                                showArrow: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 关于与帮助卡片
                          _buildSettingsCard(
                            title: '关于与帮助',
                            icon: Icons.help,
                            iconColor: AppTheme.neonOrange,
                            children: [
                              _buildDivider(),
                              _buildSettingItem(
                                title: '帮助中心',
                                icon: Icons.help_center,
                                iconColor: AppTheme.neonGreen,
                                onTap: () {
                                  // 导航到帮助中心
                                },
                                showArrow: true,
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '联系我们',
                                icon: Icons.contact_support,
                                iconColor: AppTheme.neonBlue,
                                onTap: () {
                                  // 导航到联系我们页面
                                },
                                showArrow: true,
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '用户协议',
                                icon: Icons.gavel,
                                iconColor: AppTheme.neonYellow,
                                onTap: () {
                                  // 打开用户协议
                                },
                                showArrow: true,
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '隐私政策',
                                icon: Icons.privacy_tip,
                                iconColor: AppTheme.neonPurple,
                                onTap: () {
                                  // 打开隐私政策
                                },
                                showArrow: true,
                              ),
                              _buildDivider(),
                              _buildSettingItem(
                                title: '关于',
                                subtitle: '版本 1.0.0',
                                icon: Icons.info,
                                iconColor: AppTheme.neonTeal,
                                onTap: () {
                                  // 打开关于页面
                                },
                                showArrow: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // 退出登录按钮
                          InkWell(
                            onTap: () {
                              // 退出登录逻辑
                              _showLogoutDialog();
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.neonPink?.withOpacity(0.1) ??
                                    Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      AppTheme.neonPink?.withOpacity(0.3) ??
                                      Colors.red.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '退出登录',
                                  style: TextStyle(
                                    color: AppTheme.neonPink ?? Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

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

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.cardColor.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Icon(icon, color: iconColor, size: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 卡片内容
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
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
            if (showArrow)
              Icon(
                Icons.chevron_right,
                color: AppTheme.secondaryTextColor.withOpacity(0.7),
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchSettingItem({
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.buttonColor,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSettingItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.secondaryTextColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppTheme.secondaryTextColor,
              ),
              underline: Container(height: 0),
              style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 14),
              dropdownColor: AppTheme.cardColor,
              items:
                  items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSettingItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: iconColor,
              inactiveTrackColor: AppTheme.secondaryTextColor.withOpacity(0.2),
              thumbColor: iconColor,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: iconColor.withOpacity(0.2),
              valueIndicatorColor: AppTheme.cardColor,
              valueIndicatorTextStyle: TextStyle(
                color: AppTheme.primaryTextColor,
              ),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
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

  String _getFontSizeLabel() {
    if (_fontSizeScale <= 0.8) return '小';
    if (_fontSizeScale >= 1.2) return '大';
    return '标准';
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
              children: [
                _buildLanguageOption('简体中文'),
                _buildLanguageOption('English'),
                _buildLanguageOption('日本語'),
                _buildLanguageOption('한국어'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('取消', style: TextStyle(color: AppTheme.neonBlue)),
              ),
            ],
          ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 16),
            ),
            if (_selectedLanguage == language)
              Icon(Icons.check, color: AppTheme.neonBlue, size: 20),
          ],
        ),
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
