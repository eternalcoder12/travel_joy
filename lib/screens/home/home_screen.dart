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
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
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
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  // 动画控制器
  AnimationController? _cardsAnimationController;
  AnimationController? _hoverAnimationController;

  // 卡片滑入动画
  List<Animation<Offset>>? _slideAnimations;

  // 悬浮效果动画值
  double _hoverScale = 0.95;

  // 今日信息
  final String _todayInfo = "晴天 25°C，适合户外探索";

  // 功能卡片数据 - 减少到6个主要功能
  final List<Map<String, dynamic>> _featureCards = [
    {
      'title': '热门景点',
      'icon': Icons.location_on,
      'tag': '热门',
      'tagColor': Colors.orange,
    },
    {
      'title': '行程规划',
      'icon': Icons.calendar_today,
      'tag': '推荐',
      'tagColor': Colors.green,
    },
    {
      'title': '美食推荐',
      'icon': Icons.restaurant,
      'tag': '美食',
      'tagColor': Colors.red,
    },
    {'title': '旅行笔记', 'icon': Icons.book, 'tag': '记录', 'tagColor': Colors.blue},
    {
      'title': '导航助手',
      'icon': Icons.map,
      'tag': '实用',
      'tagColor': Colors.purple,
    },
    {
      'title': '行李清单',
      'icon': Icons.checklist,
      'tag': '工具',
      'tagColor': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();

    // 初始化动画
    _initAnimations();
  }

  // 安全初始化所有动画
  void _initAnimations() {
    // 卡片滑入动画控制器
    _cardsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 卡片悬浮动画控制器
    _hoverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 为每张卡片创建滑入动画，按顺序延迟显示
    _slideAnimations = List.generate(
      _featureCards.length,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _cardsAnimationController!,
              curve: Interval(
                index * 0.1, // 每张卡片延迟0.1的时间
                0.7 + index * 0.05,
                curve: Curves.easeOutQuint,
              ),
            ),
          ),
    );

    // 添加卡片悬浮动画监听
    _hoverAnimationController!.addListener(() {
      if (mounted) {
        setState(() {
          _hoverScale = 0.95 + (_hoverAnimationController!.value * 0.05);
        });
      }
    });

    // 启动动画
    _cardsAnimationController!.forward();

    // 循环播放悬浮动画 - 更平缓的动画
    _hoverAnimationController!.repeat(reverse: true);
  }

  @override
  void dispose() {
    // 安全释放动画控制器
    _cardsAnimationController?.dispose();
    _hoverAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 渐变背景从AppTheme.backgroundColor到深蓝色
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 28.0,
            ), // 增加边距，更加大气
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 今日信息提醒 - 更宽松的布局
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _todayInfo,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.0, // 增大字体
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('点击了今日信息图标');
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppTheme.iconColor,
                            size: 28.0, // 增大图标
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32.0), // 今日信息与标题间距增加
                // 标题 - 更显眼
                Text(
                  '开启小众之旅',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 32.0, // 增大标题字体
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12.0), // 标题与副标题间距增加
                // 副标题
                Text(
                  '发现隐秘美景，享受独特旅途',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.0, // 增大副标题字体
                  ),
                ),

                const SizedBox(height: 40.0), // 副标题与卡片间距增加
                // 功能卡片网格（2x3）- 每行改为2个，让卡片更大
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 改为2列
                    crossAxisSpacing: 20.0, // 增加水平间距
                    mainAxisSpacing: 20.0, // 增加垂直间距
                    childAspectRatio: 1.0, // 正方形卡片，更大气
                  ),
                  itemCount: _featureCards.length,
                  itemBuilder: (context, index) {
                    return _buildFeatureCard(
                      context: context,
                      title: _featureCards[index]['title'],
                      icon: _featureCards[index]['icon'],
                      tag: _featureCards[index]['tag'],
                      tagColor: _featureCards[index]['tagColor'],
                      animation: _slideAnimations?[index],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 方形功能卡片 - 简化设计，更加大气
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String tag,
    required Color tagColor,
    required Animation<Offset>? animation,
  }) {
    return SlideTransition(
      position: animation ?? const AlwaysStoppedAnimation<Offset>(Offset.zero),
      child: Transform.scale(
        scale: _hoverScale,
        child: Card(
          elevation: 10.0, // 增加阴影
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 增大圆角
          ),
          color: AppTheme.cardColor,
          child: InkWell(
            onTap: () {
              print('点击了: $title');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('您选择了: $title'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16.0),
            splashColor: AppTheme.accentColor.withOpacity(0.3),
            highlightColor: AppTheme.accentColor.withOpacity(0.1),
            child: Stack(
              children: [
                // 主要内容 - 居中放置图标和文字
                Padding(
                  padding: const EdgeInsets.all(20.0), // 增加内边距
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 图标
                      Icon(
                        icon,
                        color: AppTheme.iconColor,
                        size: 48.0, // 增大图标
                      ),

                      const SizedBox(height: 16.0), // 图标与文字间距增加
                      // 标题
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // 右上角标签 - 使用圆角而非方形，更轻盈
                Positioned(
                  top: 12.0,
                  right: 12.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tagColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
