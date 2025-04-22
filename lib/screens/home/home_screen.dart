import 'package:flutter/material.dart';
import '../../app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const Center(child: Text('探索', style: TextStyle(color: Colors.white))),
    const Center(child: Text('消息', style: TextStyle(color: Colors.white))),
    const Center(child: Text('我的', style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppTheme.cardColor,
        selectedItemColor: AppTheme.primaryTextColor,
        unselectedItemColor: AppTheme.secondaryTextColor,
        type: BottomNavigationBarType.fixed, // 确保4个项目时也显示文字
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: false, // 禁用触感反馈
        // 完全禁用所有点击动画效果
        selectedFontSize: 14.0,
        unselectedFontSize: 14.0, // 使选中和未选中字体大小相同，防止动画
        iconSize: 24.0, // 固定图标大小
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '探索'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '欢迎来到Travel Joy',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '探索小众景点，获取独特旅行体验',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            // UI设计趋势按钮
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/ui_trends_2024');
              },
              icon: Icon(Icons.trending_up, color: AppTheme.neonPurple),
              label: Text(
                '查看2024年UI设计趋势',
                style: TextStyle(color: AppTheme.neonPurple),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.neonPurple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 示例内容
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(4, (index) {
                  return _buildFeatureCard(
                    context: context,
                    icon:
                        index == 0
                            ? Icons.location_on
                            : index == 1
                            ? Icons.card_giftcard
                            : index == 2
                            ? Icons.emoji_events
                            : Icons.camera_alt,
                    title:
                        index == 0
                            ? '热门景点'
                            : index == 1
                            ? '兑换礼品'
                            : index == 2
                            ? '旅行成就'
                            : '我的相册',
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 添加水波纹效果的功能卡片
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 功能卡片点击处理
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('您点击了: $title'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        splashColor: AppTheme.accentColor.withOpacity(0.3),
        highlightColor: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.iconColor, size: 40),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(color: AppTheme.primaryTextColor)),
            ],
          ),
        ),
      ),
    );
  }
}
