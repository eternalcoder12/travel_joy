import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';
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
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  // 设置选项
  final List<Map<String, dynamic>> _settingCategories = [
    {
      'title': '账号设置',
      'icon': Icons.person_outline,
      'color': AppTheme.neonBlue,
      'items': [
        {'title': '个人信息', 'icon': Icons.person},
        {'title': '账号安全', 'icon': Icons.security},
        {'title': '隐私设置', 'icon': Icons.privacy_tip_outlined},
      ],
    },
    {
      'title': '应用设置',
      'icon': Icons.settings_outlined,
      'color': AppTheme.neonPurple,
      'items': [
        {'title': '通知', 'icon': Icons.notifications_none},
        {'title': '外观', 'icon': Icons.palette_outlined},
        {'title': '语言', 'icon': Icons.language},
      ],
    },
    {
      'title': '其他',
      'icon': Icons.more_horiz,
      'color': AppTheme.neonGreen,
      'items': [
        {'title': '清除缓存', 'icon': Icons.cleaning_services_outlined},
        {'title': '关于我们', 'icon': Icons.info_outline},
        {'title': '反馈问题', 'icon': Icons.feedback_outlined},
      ],
    },
  ];

  bool _notificationsEnabled = true;
  String _selectedLanguage = '简体中文';
  bool _darkModeEnabled = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 初始化背景动画
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动背景动画循环
    _backgroundAnimController.repeat(reverse: true);

    // 启动动画
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _contentAnimationController.forward();
    });
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
          // 背景
          _buildAnimatedBackground(),

          // 内容
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: Column(
                  children: [
                    // 顶部导航栏
                    _buildAppBar(),

                    // 滚动内容
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // 设置卡片
                          ..._settingCategories.map(
                            (category) => _buildSettingCategory(category),
                          ),

                          // 底部版本信息
                          _buildVersionInfo(),

                          // 底部间距
                          const SizedBox(height: 20),
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 基础背景
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
                ),
              ),
            ),

            // 动态光晕效果1
            Positioned(
              left:
                  MediaQuery.of(context).size.width *
                  (0.3 + 0.2 * math.sin(_backgroundAnimation.value * math.pi)),
              top:
                  MediaQuery.of(context).size.height *
                  (0.2 + 0.1 * math.cos(_backgroundAnimation.value * math.pi)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonBlue.withOpacity(0.3),
                      AppTheme.neonBlue.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // 动态光晕效果2
            Positioned(
              right:
                  MediaQuery.of(context).size.width *
                  (0.2 +
                      0.2 * math.cos(_backgroundAnimation.value * math.pi + 1)),
              bottom:
                  MediaQuery.of(context).size.height *
                  (0.2 +
                      0.1 * math.sin(_backgroundAnimation.value * math.pi + 1)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.3),
                      AppTheme.neonPurple.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          CircleButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.of(context).pop(),
            iconColor: AppTheme.neonBlue,
            size: 40,
          ),

          // 标题
          Text(
            '设置',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 右侧占位
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSettingCategory(Map<String, dynamic> category) {
    return AnimatedItem(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(category['icon'], color: category['color']),
                  const SizedBox(width: 10),
                  Text(
                    category['title'],
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 分割线
            Divider(
              color: AppTheme.primaryTextColor.withOpacity(0.1),
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),

            // 设置项
            ...category['items'].map<Widget>((item) {
              return _buildSettingItem(item);
            }).toList(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(Map<String, dynamic> item) {
    Widget? trailing;

    // 为特定项目定制尾部控件
    if (item['title'] == '通知') {
      trailing = Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        activeColor: AppTheme.neonPurple,
      );
    } else if (item['title'] == '外观') {
      trailing = Switch(
        value: _darkModeEnabled,
        onChanged: (value) {
          setState(() {
            _darkModeEnabled = value;
          });
        },
        activeColor: AppTheme.neonBlue,
      );
    } else if (item['title'] == '语言') {
      trailing = Text(
        _selectedLanguage,
        style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
      );
    } else {
      trailing = Icon(
        Icons.chevron_right,
        color: AppTheme.secondaryTextColor,
        size: 20,
      );
    }

    return InkWell(
      onTap: () {
        // 根据设置项的不同，执行不同操作
        if (item['title'] == '通知') {
          setState(() {
            _notificationsEnabled = !_notificationsEnabled;
          });
        } else if (item['title'] == '外观') {
          setState(() {
            _darkModeEnabled = !_darkModeEnabled;
          });
        } else if (item['title'] == '语言') {
          _showLanguageDialog();
        } else if (item['title'] == '清除缓存') {
          _showClearCacheDialog();
        }
        // 其他设置项跳转到相应页面
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // 图标
            Icon(item['icon'], color: AppTheme.secondaryTextColor, size: 20),
            const SizedBox(width: 15),

            // 标题
            Expanded(
              child: Text(
                item['title'],
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                ),
              ),
            ),

            // 尾部控件
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Center(
        child: Column(
          children: [
            Text(
              'Travel Joy v1.0.0',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '© 2024 Travel Joy Team. All rights reserved.',
              style: TextStyle(
                color: AppTheme.secondaryTextColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
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
              borderRadius: BorderRadius.circular(20),
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

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
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
