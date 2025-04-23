import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 简化的_changeTab方法
  void _changeTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 使用AnimatedSwitcher替代IndexedStack，添加页面切换动画
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // 页面从右侧滑入动画
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // 从右侧开始
              end: Offset.zero, // 滑动到原位
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: _buildCurrentTab(_currentIndex),
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

  // 添加_buildCurrentTab方法
  Widget _buildCurrentTab(int index) {
    // 为每个Tab添加唯一的key，确保AnimatedSwitcher能识别变化
    switch (index) {
      case 0:
        return _HomeTab(key: const ValueKey<int>(0), isCurrentPage: true);
      case 1:
        return _ExploreTab(key: const ValueKey<int>(1), isCurrentPage: true);
      case 2:
        return _MessageTab(key: const ValueKey<int>(2), isCurrentPage: true);
      case 3:
        return _ProfileTab(key: const ValueKey<int>(3), isCurrentPage: true);
      default:
        return _HomeTab(key: const ValueKey<int>(0), isCurrentPage: true);
    }
  }
}

// 首页标签
class _HomeTab extends StatefulWidget {
  final bool isCurrentPage;

  const _HomeTab({Key? key, this.isCurrentPage = false}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  // 光波动画控制器
  AnimationController? _shineAnimationController;

  // 飞入动画控制器
  AnimationController? _flyInController;

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
      duration: const Duration(seconds: 3),
    );

    // 初始化飞入动画控制器 - 设置为500毫秒
    _flyInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 启动动画
    _shineAnimationController!.repeat();
    _flyInController!.forward();
  }

  @override
  void dispose() {
    _shineAnimationController?.dispose();
    _flyInController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重新播放飞入动画
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _flyInController?.reset();
      _flyInController?.forward();
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 区块1: 今日信息提醒 (从左侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _todayInfo,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 16.0,
                            color: AppTheme.primaryTextColor,
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
                            color: AppTheme.primaryTextColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryTextColor,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16.0),

                // 区块2: 标题和副标题 (从右侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '开启小众之旅',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '发现隐秘美景，享受独特旅途',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.0,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0),

                // 区块3: 功能卡片列表 (从下方飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 200 * (1 - _flyInController!.value)),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: List.generate(_featureCards.length, (index) {
                      // 提取卡片数据
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
                          math.min(0.7, index * 0.15),
                          math.min(1.0, math.min(0.7, index * 0.15) + 0.3),
                          curve: Curves.easeInOut,
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
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
                      );
                    }),
                  ),
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
          // 光波动画效果 - 从左到右移动并在开始和结束时淡入淡出
          AnimatedBuilder(
            animation: shineAnimation,
            builder: (context, child) {
              // 计算淡入淡出效果
              double opacity = 0.0;
              final position = shineAnimation.value;

              // 只在中间部分显示，开始和结束时隐藏
              if (position > 0.1 && position < 0.9) {
                // 淡入
                if (position < 0.3) {
                  opacity = (position - 0.1) * 5; // 0.1-0.3区间内淡入
                }
                // 保持稳定
                else if (position < 0.7) {
                  opacity = 1.0;
                }
                // 淡出
                else {
                  opacity = (0.9 - position) * 5; // 0.7-0.9区间内淡出
                }
              }

              return Positioned(
                top: -50,
                left: -100 + (position * 500), // 动画移动位置
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 100,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTextColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryTextColor.withOpacity(0.05),
                          blurRadius: 15,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
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
              // 减少阴影复杂度，提高性能
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.2),
                  blurRadius: 4.0, // 减小阴影模糊半径
                  offset: const Offset(0, 2), // 减小阴影偏移
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
              onHover: (isHovered) {
                if (_shineAnimationController != null) {
                  if (isHovered) {
                    _shineAnimationController!.forward();
                  } else {
                    _shineAnimationController!.reverse();
                  }
                }
              },
              splashFactory: InkRipple.splashFactory,
              splashColor: AppTheme.primaryTextColor.withOpacity(0.2),
              highlightColor: AppTheme.primaryTextColor.withOpacity(0.1),
              child: SizedBox(
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
                          color: AppTheme.cardColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
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
                              color: AppTheme.primaryTextColor.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: AppTheme.primaryTextColor,
                              size: 28.0,
                            ),
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
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4.0),

                                // 副标题
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 14.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // 箭头图标
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.primaryTextColor,
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
  final bool isCurrentPage;

  const _ExploreTab({Key? key, this.isCurrentPage = false}) : super(key: key);

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab>
    with TickerProviderStateMixin {
  // 飞入动画控制器
  AnimationController? _flyInController;

  @override
  void initState() {
    super.initState();

    // 初始化飞入动画控制器 - 设置为500毫秒
    _flyInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 启动动画
    _flyInController!.forward();
  }

  @override
  void dispose() {
    _flyInController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ExploreTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重新播放飞入动画
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _flyInController?.reset();
      _flyInController?.forward();
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 区块1: 标题 (从左侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '探索',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // 区块2: 发现内容区域 (从右侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '发现更多景点',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 18.0,
                        ),
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

// 消息页面 - 带入场动画
class _MessageTab extends StatefulWidget {
  final bool isCurrentPage;

  const _MessageTab({Key? key, this.isCurrentPage = false}) : super(key: key);

  @override
  _MessageTabState createState() => _MessageTabState();
}

class _MessageTabState extends State<_MessageTab>
    with TickerProviderStateMixin {
  // 飞入动画控制器
  AnimationController? _flyInController;

  @override
  void initState() {
    super.initState();

    // 初始化飞入动画控制器 - 设置为500毫秒
    _flyInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 启动动画
    _flyInController!.forward();
  }

  @override
  void dispose() {
    _flyInController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_MessageTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重新播放飞入动画
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _flyInController?.reset();
      _flyInController?.forward();
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 区块1: 标题 (从右侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '消息',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // 区块2: 消息内容区域 (从左侧飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(-300 * (1 - _flyInController!.value), 0),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '暂无新消息',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 18.0,
                        ),
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

// 个人页面 - 带入场动画
class _ProfileTab extends StatefulWidget {
  final bool isCurrentPage;

  const _ProfileTab({Key? key, this.isCurrentPage = false}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab>
    with TickerProviderStateMixin {
  // 飞入动画控制器
  AnimationController? _flyInController;

  @override
  void initState() {
    super.initState();

    // 初始化飞入动画控制器 - 设置为500毫秒
    _flyInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 启动动画
    _flyInController!.forward();
  }

  @override
  void dispose() {
    _flyInController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重新播放飞入动画
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _flyInController?.reset();
      _flyInController?.forward();
    }
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 区块1: 标题 (从顶部飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -100 * (1 - _flyInController!.value)),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    '我的',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16.0),

                // 区块2: 个人信息区域 (从右下方飞入)
                AnimatedBuilder(
                  animation: _flyInController!,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        200 * (1 - _flyInController!.value),
                        100 * (1 - _flyInController!.value),
                      ),
                      child: Opacity(
                        opacity: _flyInController!.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '个人信息',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 18.0,
                        ),
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
