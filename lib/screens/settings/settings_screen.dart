import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
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

    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _contentAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
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
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _settingCategories.length,
                    itemBuilder: (context, index) {
                      return _buildSettingCategory(_settingCategories[index]);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSettingCategory(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标题
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Icon(category['icon'], color: category['color'], size: 22),
              const SizedBox(width: 8),
              Text(
                category['title'],
                style: TextStyle(
                  color: category['color'],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 分割线
        Divider(color: Colors.white.withOpacity(0.08), thickness: 0.8),

        // 设置项
        ...List.generate(category['items'].length, (index) {
          // 使用交错动画效果
          return AnimatedBuilder(
            animation: _contentAnimationController,
            builder: (context, child) {
              // 根据索引计算延迟动画
              final double delayedProgress = math.max(
                0.0,
                math.min(
                  1.0,
                  (_contentAnimationController.value - (0.1 * index)) / 0.6,
                ),
              );

              return FadeTransition(
                opacity: AlwaysStoppedAnimation(delayedProgress),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - delayedProgress)),
                  child: child,
                ),
              );
            },
            child: _buildSettingItem(category['items'][index]),
          );
        }),
      ],
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
        activeColor: Colors.white,
        activeTrackColor: AppTheme.buttonColor,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      );
    } else if (item['title'] == '外观') {
      trailing = Switch(
        value: _darkModeEnabled,
        onChanged: (value) {
          setState(() {
            _darkModeEnabled = value;
          });
        },
        activeColor: Colors.white,
        activeTrackColor: AppTheme.buttonColor,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // 图标
            Icon(item['icon'], color: AppTheme.secondaryTextColor, size: 22),
            const SizedBox(width: 16),

            // 标题
            Expanded(
              child: Text(
                item['title'],
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 15,
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
