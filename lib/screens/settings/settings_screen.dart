import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/circle_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 设置选项
  final List<Map<String, dynamic>> _settingCategories = [
    {
      'title': '账号设置',
      'icon': Icons.person_outline,
      'color': Color(0xFF3B9EFF),
      'items': [
        {'title': '个人信息', 'icon': Icons.person},
        {'title': '账号安全', 'icon': Icons.security},
        {'title': '隐私设置', 'icon': Icons.privacy_tip_outlined},
      ],
    },
    {
      'title': '应用设置',
      'icon': Icons.settings_outlined,
      'color': Color(0xFFB45EFF),
      'items': [
        {'title': '通知', 'icon': Icons.notifications_none},
        {'title': '外观', 'icon': Icons.palette_outlined},
        {'title': '语言', 'icon': Icons.language},
      ],
    },
    {
      'title': '其他',
      'icon': Icons.more_horiz,
      'color': Color(0xFF57D9A3),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildAppBar(),

            // 滚动内容
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  // 设置卡片
                  ..._settingCategories.map(
                    (category) => _buildSettingSection(category),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: const Color(0xFF3B9EFF),
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),

          Expanded(
            child: Center(
              child: Text(
                '设置',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 保持对称
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSettingSection(Map<String, dynamic> category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标题
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Icon(category['icon'], color: category['color'], size: 24),
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
        Divider(color: Colors.white.withOpacity(0.08), thickness: 1),

        // 设置项
        ...category['items'].map<Widget>((item) {
          return _buildSettingItem(item);
        }).toList(),

        const SizedBox(height: 16),
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
        activeTrackColor: const Color(0xFF4080FF),
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
        activeTrackColor: const Color(0xFF4080FF),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.withOpacity(0.5),
      );
    } else if (item['title'] == '语言') {
      trailing = Text(
        _selectedLanguage,
        style: TextStyle(color: Colors.grey, fontSize: 14),
      );
    } else {
      trailing = Icon(Icons.chevron_right, color: Colors.grey, size: 20);
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 图标
            Icon(item['icon'], color: Colors.white.withOpacity(0.7), size: 20),
            const SizedBox(width: 16),

            // 标题
            Expanded(
              child: Text(
                item['title'],
                style: TextStyle(color: Colors.white, fontSize: 15),
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
            backgroundColor: const Color(0xFF2A2A45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '选择语言',
              style: TextStyle(
                color: Colors.white,
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
                child: Text(
                  '取消',
                  style: TextStyle(color: const Color(0xFF3B9EFF)),
                ),
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
            Text(language, style: TextStyle(color: Colors.white, fontSize: 16)),
            if (_selectedLanguage == language)
              Icon(Icons.check, color: const Color(0xFF3B9EFF), size: 20),
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
            backgroundColor: const Color(0xFF2A2A45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '清除缓存',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '确定要清除所有缓存数据吗？这将删除临时文件，但不会影响您的个人数据。',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('取消', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () {
                  // 执行清理缓存操作
                  Navigator.pop(context);
                  _showCacheSuccessSnackbar();
                },
                child: Text(
                  '确定',
                  style: TextStyle(color: const Color(0xFF3B9EFF)),
                ),
              ),
            ],
          ),
    );
  }

  void _showCacheSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('缓存已成功清除'),
        backgroundColor: const Color(0xFF57D9A3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
