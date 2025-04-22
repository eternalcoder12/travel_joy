import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../../app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;
  AnimationController? _pageAnimationController;
  Animation<double>? _pageAnimation;

  // 主屏幕列表 - 所有页面都包含入场动画
  final List<Widget> _screens = [
    const _HomeTab(),
    const _ExploreTab(),
    const _MessageTab(),
    const _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();

    // 初始化页面切换动画
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pageAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pageAnimationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _pageAnimationController?.dispose();
    super.dispose();
  }

  // 切换标签页，播放动画
  void _changeTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    // 重置并播放页面切换动画
    _pageAnimationController!.reset();
    _pageAnimationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: AnimatedBuilder(
        animation: _pageAnimationController!,
        builder: (context, child) {
          return Stack(
            children: [
              // 前一个页面淡出
              if (_pageAnimation!.value < 1)
                Opacity(
                  opacity: 1 - _pageAnimation!.value,
                  child: Transform.translate(
                    offset: Offset(
                      -MediaQuery.of(context).size.width *
                          _pageAnimation!.value,
                      0,
                    ),
                    child: _screens[_previousIndex],
                  ),
                ),

              // 当前页面淡入
              Opacity(
                opacity: _pageAnimation!.value,
                child: Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width *
                        (1 - _pageAnimation!.value),
                    0,
                  ),
                  child: _screens[_currentIndex],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _changeTab,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.primaryTextColor,
            unselectedItemColor: AppTheme.secondaryTextColor,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 14.0,
            unselectedFontSize: 14.0,
            iconSize: 24.0,
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

// 基础页面动画混入
mixin PageAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  AnimationController? entryAnimationController;

  @override
  void initState() {
    super.initState();

    // 初始化入场动画控制器
    entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 启动入场动画
    entryAnimationController!.forward();
  }

  @override
  void dispose() {
    entryAnimationController?.dispose();
    super.dispose();
  }

  // 创建从底部滑入的动画
  Animation<Offset> createSlideAnimation(int index, int totalItems) {
    return Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(
        parent: entryAnimationController!,
        curve: Interval(
          index * 0.1, // 每个元素延迟0.1的时间
          0.5 + index * 0.1,
          curve: Curves.easeOutQuint,
        ),
      ),
    );
  }
}

// 首页标签
class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab>
    with TickerProviderStateMixin, PageAnimationMixin {
  // 光波动画控制器
  AnimationController? _shineAnimationController;

  // 今日信息
  final String _todayInfo = "晴天 25°C，适合户外探索";

  // 默认渐变颜色 - 用于任何卡片没有指定颜色时
  final List<Color> _defaultGradient = [
    const Color(0xFF3A1C71),
    const Color(0xFFD76D77),
    const Color(0xFFFFAF7B),
  ];

  // 功能卡片数据 - 使用非空颜色列表和副标题
  final List<Map<String, dynamic>> _featureCards = [
    {
      'title': '热门景点',
      'subtitle': '探索当地隐秘景点',
      'icon': Icons.location_on,
      'tag': '热门',
      'tagColor': Colors.orange,
      'gradientColors': <Color>[
        Color(0xFF614385).withOpacity(0.9),
        Color(0xFF516395).withOpacity(0.9),
      ],
    },
    {
      'title': '行程规划',
      'subtitle': '定制个性化旅行计划',
      'icon': Icons.calendar_today,
      'tag': '推荐',
      'tagColor': Colors.green,
      'gradientColors': <Color>[
        Color(0xFF02AABB).withOpacity(0.9),
        Color(0xFF00CDAC).withOpacity(0.9),
      ],
    },
    {
      'title': '美食推荐',
      'subtitle': '品尝地道美食佳肴',
      'icon': Icons.restaurant,
      'tag': '美食',
      'tagColor': Colors.red,
      'gradientColors': <Color>[
        Color(0xFFFF5F6D).withOpacity(0.9),
        Color(0xFFFFC371).withOpacity(0.9),
      ],
    },
    {
      'title': '旅行笔记',
      'subtitle': '记录精彩旅途点滴',
      'icon': Icons.book,
      'tag': '记录',
      'tagColor': Colors.blue,
      'gradientColors': <Color>[
        Color(0xFF396AFC).withOpacity(0.9),
        Color(0xFF2948FF).withOpacity(0.9),
      ],
    },
    {
      'title': '导航助手',
      'subtitle': '便捷路线规划工具',
      'icon': Icons.map,
      'tag': '实用',
      'tagColor': Colors.purple,
      'gradientColors': <Color>[
        Color(0xFF6A11CB).withOpacity(0.9),
        Color(0xFF2575FC).withOpacity(0.9),
      ],
    },
    {
      'title': '行李清单',
      'subtitle': '旅行装备智能提醒',
      'icon': Icons.checklist,
      'tag': '工具',
      'tagColor': Colors.teal,
      'gradientColors': <Color>[
        Color(0xFF11998E).withOpacity(0.9),
        Color(0xFF38EF7D).withOpacity(0.9),
      ],
    },
  ];

  @override
  void initState() {
    super.initState();

    // 初始化光波动画控制器
    _shineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 启动并循环播放光波动画
    _shineAnimationController!.repeat();
  }

  @override
  void dispose() {
    _shineAnimationController?.dispose();
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
              horizontal: 20.0,
              vertical: 28.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 今日信息提醒 - 滑入动画
                SlideTransition(
                  position: createSlideAnimation(0, _featureCards.length + 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _todayInfo,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.0, // 增大字体
                            color: Colors.white,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          print('点击了今日信息图标');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32.0), // 今日信息与标题间距增加
                // 标题 - 滑入动画
                SlideTransition(
                  position: createSlideAnimation(1, _featureCards.length + 1),
                  child: Text(
                    '开启小众之旅',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 32.0, // 增大标题字体
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12.0), // 标题与副标题间距增加
                // 副标题 - 滑入动画
                SlideTransition(
                  position: createSlideAnimation(2, _featureCards.length + 1),
                  child: Text(
                    '发现隐秘美景，享受独特旅途',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16.0, // 增大副标题字体
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 36.0), // 副标题与卡片间距增加
                // 功能卡片 - 依次滑入并从上到下依次显示光波效果
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _featureCards.length,
                  itemBuilder: (context, index) {
                    // 提取卡片数据并添加空值检查
                    final cardData = _featureCards[index];
                    final String title = cardData['title'] as String? ?? "功能";
                    final String subtitle =
                        cardData['subtitle'] as String? ?? "了解更多信息";
                    final IconData icon =
                        cardData['icon'] as IconData? ?? Icons.star;
                    final String tag = cardData['tag'] as String? ?? "";
                    final Color tagColor =
                        cardData['tagColor'] as Color? ?? Colors.grey;
                    final List<Color> gradientColors =
                        (cardData['gradientColors'] as List<Color>?) ??
                        _defaultGradient;

                    // 为不同的卡片创建不同时间的光波动画
                    final shineAnimation = CurvedAnimation(
                      parent: _shineAnimationController!,
                      curve: Interval(
                        index * 0.15, // 每个卡片的光波错开0.15的时间
                        (index * 0.15) + 0.3, // 每个光波持续0.3的时间
                        curve: Curves.easeInOut,
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SlideTransition(
                        position: createSlideAnimation(
                          index + 3,
                          _featureCards.length + 3,
                        ),
                        child: _buildFeatureCard(
                          context: context,
                          title: title,
                          subtitle: subtitle,
                          icon: icon,
                          tag: tag,
                          tagColor: tagColor,
                          gradientColors: gradientColors,
                          shineAnimation: shineAnimation,
                        ),
                      ),
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

  // 横向布局功能卡片 - 带有从上到下依次进行的光波动画
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String tag,
    required Color tagColor,
    required List<Color> gradientColors,
    required Animation<double> shineAnimation,
  }) {
    // 确保渐变颜色非空，否则使用默认颜色
    final colors =
        gradientColors.isNotEmpty ? gradientColors : _defaultGradient;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.0),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 光波动画效果 - 从左到右移动
          AnimatedBuilder(
            animation: shineAnimation,
            builder: (context, child) {
              return Positioned(
                top: -50,
                left: -50 + (shineAnimation.value * 400), // 动画移动位置
                child: Container(
                  width: 100,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.05),
                        blurRadius: 15,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // 主卡片内容
          Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: colors,
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: this.mounted ? 8.0 : 0.0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
              splashFactory: InkRipple.splashFactory,
              splashColor: Colors.white.withOpacity(0.2),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Container(
                height: 100, // 固定高度
                child: Stack(
                  children: [
                    // 标签
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // 主要内容 - 水平布局
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        10.0,
                        20.0,
                        10.0,
                      ),
                      child: Row(
                        children: [
                          // 图标容器 - 圆形背景
                          Container(
                            width: 56.0,
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: Colors.white, size: 28.0),
                          ),

                          const SizedBox(width: 16.0),

                          // 文字内容 - 左对齐
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 标题
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4.0),

                                // 副标题
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 14.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // 箭头图标
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16.0,
                          ),
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
}

// 探索页面 - 带入场动画
class _ExploreTab extends StatefulWidget {
  const _ExploreTab({Key? key}) : super(key: key);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab>
    with TickerProviderStateMixin, PageAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SlideTransition(
            position: createSlideAnimation(0, 1),
            child: const Text(
              '探索',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 消息页面 - 带入场动画
class _MessageTab extends StatefulWidget {
  const _MessageTab({Key? key}) : super(key: key);

  @override
  _MessageTabState createState() => _MessageTabState();
}

class _MessageTabState extends State<_MessageTab>
    with TickerProviderStateMixin, PageAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SlideTransition(
            position: createSlideAnimation(0, 1),
            child: const Text(
              '消息',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 个人页面 - 带入场动画
class _ProfileTab extends StatefulWidget {
  const _ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab>
    with TickerProviderStateMixin, PageAnimationMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SlideTransition(
            position: createSlideAnimation(0, 1),
            child: const Text(
              '我的',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
