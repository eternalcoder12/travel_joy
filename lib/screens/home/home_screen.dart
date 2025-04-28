import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../explore/spot_detail_screen.dart';
import '../explore/map_view_screen.dart';
import '../message/message_screen.dart';
import '../../utils/navigation_utils.dart';
import 'package:travel_joy/widgets/travel_timeline.dart';
import 'package:travel_joy/widgets/travel_timeline_preview.dart' as preview;
import 'package:travel_joy/screens/travel/travel_timeline_screen.dart';
import 'package:travel_joy/screens/travel/travel_history_screen.dart';
import 'package:travel_joy/screens/achievement/achievement_screen.dart';
import 'package:travel_joy/screens/activity/activity_screen.dart';
import 'package:travel_joy/screens/collection/collection_screen.dart';
import 'package:travel_joy/screens/profile/user_stats_screen.dart';
import 'package:travel_joy/screens/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  // 页面切换动画控制器
  late AnimationController _pageTransitionController;
  late Animation<double> _pageTransitionAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化页面切换动画控制器，与消息页面保持一致
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600), // 调整为与消息页面一致
      vsync: this,
    );

    _pageTransitionAnimation = CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic, // 使用与消息页面一致的曲线
    );
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  // 优化的_changeTab方法，与消息页面标签切换方式保持一致
  void _changeTab(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // 切换后执行动画，与消息页面保持一致
    _pageTransitionController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 使用AnimatedSwitcher替代IndexedStack，动画效果与消息页面保持一致
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600), // 调整为与消息页面一致
        transitionBuilder: (Widget child, Animation<double> animation) {
          // 使用与消息页面一致的动画效果：淡入+轻微滑动
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
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
        // 使用优化后的MessageScreen
        return MessageScreen(key: const ValueKey<int>(2));
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
  late AnimationController _shineAnimationController;

  // 背景动画控制器 - 与消息页面保持一致
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 内容动画控制器 - 与消息页面保持一致
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;

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

    // 初始化光波动画控制器 (保留)
    _shineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 初始化背景动画控制器 - 与消息页面保持一致
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化内容动画控制器 - 与消息页面保持一致
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画
    _shineAnimationController.repeat();
    _contentAnimController.forward();
  }

  @override
  void dispose() {
    _shineAnimationController.dispose();
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_HomeTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重置并播放动画，与消息页面保持一致
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _contentAnimController.reset();
      _contentAnimController.forward();
      // 确保背景动画在页面可见时运行
      if (!_backgroundAnimController.isAnimating) {
        _backgroundAnimController.repeat(reverse: true);
      }
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      // 当页面不再是当前页面时，暂停耗费资源的背景动画
      _backgroundAnimController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 添加动态渐变背景，实现背景微动效果 - 参考消息页面
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
        ),
      ),
      child: Stack(
        children: [
          // 动态光晕效果 - 参考消息页面
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 动态光晕效果1
                  Positioned(
                    left:
                        MediaQuery.of(context).size.width *
                        (0.3 +
                            0.3 *
                                math.sin(_backgroundAnimation.value * math.pi)),
                    top:
                        MediaQuery.of(context).size.height *
                        (0.3 +
                            0.2 *
                                math.cos(_backgroundAnimation.value * math.pi)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.neonBlue.withOpacity(0.4),
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
                            0.2 *
                                math.cos(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
                    bottom:
                        MediaQuery.of(context).size.height *
                        (0.2 +
                            0.2 *
                                math.sin(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
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
          ),

          // 主内容 - 使用动画包装
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: _buildHomeContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建主页内容 - 拆分方法提高可读性
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题部分
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _contentAnimController,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _contentAnimController,
                    curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
                  ),
                ),
                child: _buildHeaderSection(),
              ),
            ),

            const SizedBox(height: 24.0),

            // 功能区
            _buildFeaturesSection(),

            const SizedBox(height: 24.0),

            // 推荐区
            _buildRecommendationsSection(),
          ],
        ),
      ),
    );
  }

  // 构建头部区域
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 今日信息提醒
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _todayInfo,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

        const SizedBox(height: 16.0),

        // 标题和副标题
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '开启小众之旅',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
      ],
    );
  }

  // 构建功能区域 - 为每个卡片添加交错动画效果
  Widget _buildFeaturesSection() {
    return Column(
      children: List.generate(_featureCards.length, (index) {
        // 提取卡片数据
        final cardData = _featureCards[index];
        final String title = cardData['title'] as String? ?? "功能";
        final String subtitle = cardData['subtitle'] as String? ?? "了解更多信息";
        final IconData icon = cardData['icon'] as IconData? ?? Icons.star;
        final String tag = cardData['tag'] as String? ?? "";
        final Color tagColor = cardData['tagColor'] as Color? ?? Colors.grey;
        final List<Color> gradientColors =
            (cardData['gradientColors'] as List<Color>?) ?? _defaultGradient;

        // 添加交错动画效果，与消息页面保持一致
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _contentAnimController,
            curve: Interval(
              0.3 + (index * 0.1), // 每个卡片延迟0.1的时间出现
              math.min(1.0, 0.3 + (index * 0.1) + 0.4),
              curve: Curves.easeOutCubic,
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.3, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _contentAnimController,
                curve: Interval(
                  0.3 + (index * 0.1),
                  math.min(1.0, 0.3 + (index * 0.1) + 0.4),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildFeatureCard(
                context: context,
                title: title,
                subtitle: subtitle,
                icon: icon,
                tag: tag,
                tagColor: tagColor,
                gradientColors: gradientColors,
                shineAnimation: CurvedAnimation(
                  parent: _shineAnimationController,
                  curve: Interval(
                    math.min(0.7, index * 0.15),
                    math.min(1.0, math.min(0.7, index * 0.15) + 0.3),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // 构建推荐区域
  Widget _buildRecommendationsSection() {
    // 这里可以根据实际需求添加推荐内容
    return Container(); // 暂时返回空容器
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
                    _shineAnimationController.forward();
                  } else {
                    _shineAnimationController.reverse();
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
  // 背景动画控制器 - 与消息页面保持一致
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 内容动画控制器 - 与消息页面保持一致
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;

  // 搜索文本控制器
  final TextEditingController _searchController = TextEditingController();

  // 推荐景点数据
  final List<Map<String, dynamic>> _recommendedSpots = [
    {
      'name': '西湖风景区',
      'location': '杭州, 浙江',
      'image':
          'https://images.unsplash.com/photo-1602170284347-c36ccc9634d2?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.8,
      'tags': ['风景', '湖泊', '历史'],
      'description':
          '西湖是中国大陆首批国家重点风景名胜区和中国十大风景名胜之一，三面环山，面积约6.39平方千米。湖中被孤山、白堤、苏堤、杨公堤分隔，形成了外西湖、西里湖、北里湖、小南湖及岳湖等五片水面。"西湖十景"是西湖景致的代表。',
      'price': '85',
    },
    {
      'name': '故宫博物院',
      'location': '北京',
      'image':
          'https://images.unsplash.com/photo-1505857231560-e4cc21cbd727?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.9,
      'tags': ['历史', '文化', '建筑'],
      'description':
          '北京故宫是中国明清两代的皇家宫殿，旧称为紫禁城，是中国古代宫廷建筑之精华。北京故宫以三大殿为中心，占地面积72万平方米，建筑面积约15万平方米，有大小宫殿七十多座，房屋九千余间。是世界上现存规模最大、保存最为完整的木质结构古建筑之一。',
      'price': '120',
    },
    {
      'name': '黄山风景区',
      'location': '黄山, 安徽',
      'image':
          'https://images.unsplash.com/photo-1528435018997-ff5e612a1ada?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.7,
      'tags': ['山水', '风景', '徒步'],
      'description':
          '黄山位于安徽省南部，是中国十大名山之一，以奇松、怪石、云海、温泉、冬雪"五绝"著称于世。黄山的自然景观丰富多彩，山上常年云雾缭绕，气象万千，被誉为"人间仙境"，是摄影爱好者的天堂。',
      'price': '190',
    },
    {
      'name': '张家界国家森林公园',
      'location': '张家界, 湖南',
      'image':
          'https://images.unsplash.com/photo-1550005173-9117e56ef602?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.6,
      'tags': ['自然', '峰林', '冒险'],
      'description':
          '张家界国家森林公园以其数千座陡峭的石英砂岩峰林而闻名，这些峰林高耸入云，气势磅礴。电影《阿凡达》中的"哈利路亚山"灵感便来源于此。公园内还有众多奇特的岩石和洞穴，是探险和摄影的绝佳去处。',
      'price': '160',
    },
    {
      'name': '丽江古城',
      'location': '丽江, 云南',
      'image':
          'https://images.unsplash.com/photo-1578950114438-e057a67911df?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.5,
      'tags': ['古城', '文化', '民俗'],
      'description':
          '丽江古城始建于宋末元初，是中国为数不多的保存完好的少数民族古城，也是世界文化遗产。古城内的四方街是丽江古城的中心广场，由花石铺就而成。小巷纵横交错，清澈的溪流穿城而过，体现了纳西族独特的文化传统和建筑风格。',
      'price': '80',
    },
  ];

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  // 是否显示返回顶部按钮
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    // 初始化背景动画控制器 - 与消息页面保持一致
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化内容动画控制器 - 与消息页面保持一致
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画
    _contentAnimController.forward();

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
  }

  // 滚动监听
  void _onScroll() {
    if (_scrollController.offset > 200 && !_showBackToTop) {
      setState(() {
        _showBackToTop = true;
      });
    } else if (_scrollController.offset <= 200 && _showBackToTop) {
      setState(() {
        _showBackToTop = false;
      });
    }
  }

  // 返回顶部
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ExploreTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重置并播放动画，与消息页面保持一致
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _contentAnimController.reset();
      _contentAnimController.forward();
      // 确保背景动画在页面可见时运行
      if (!_backgroundAnimController.isAnimating) {
        _backgroundAnimController.repeat(reverse: true);
      }
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      // 当页面不再是当前页面时，暂停耗费资源的背景动画
      _backgroundAnimController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 添加动态渐变背景，实现背景微动效果 - 参考消息页面
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
        ),
      ),
      child: Stack(
        children: [
          // 动态光晕效果 - 参考消息页面
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 动态光晕效果1
                  Positioned(
                    left:
                        MediaQuery.of(context).size.width *
                        (0.3 +
                            0.3 *
                                math.sin(_backgroundAnimation.value * math.pi)),
                    top:
                        MediaQuery.of(context).size.height *
                        (0.3 +
                            0.2 *
                                math.cos(_backgroundAnimation.value * math.pi)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.neonBlue.withOpacity(0.4),
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
                            0.2 *
                                math.cos(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
                    bottom:
                        MediaQuery.of(context).size.height *
                        (0.2 +
                            0.2 *
                                math.sin(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
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
          ),

          // 主内容
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: _buildExploreContent(),
              ),
            ),
          ),

          // 返回顶部按钮
          if (_showBackToTop)
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppTheme.buttonColor,
                onPressed: _scrollToTop,
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  // 构建探索页面内容
  Widget _buildExploreContent() {
    return Column(
      children: [
        // 固定部分：标题和搜索栏
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '探索',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '发现周边美景和热门目的地',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 16.0),
              // 搜索框
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索目的地、景点、活动...',
                    hintStyle: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14.0,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryTextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 滚动部分：推荐景点
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
            itemCount: _recommendedSpots.length,
            itemBuilder: (context, index) {
              final spot = _recommendedSpots[index];
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _contentAnimController,
                    curve: Interval(
                      0.2 + (index * 0.1),
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                ),
                child: _buildSpotCard(spot, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpotCard(Map<String, dynamic> spot, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('点击了景点: ${spot['name']}');
            // 导航到景点详情页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpotDetailScreen(spotData: spot),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    spot['image'] as String,
                    height: 180.0,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180.0,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.grey,
                            size: 50.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12.0),
                // 名称和评分
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        spot['name'] as String,
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18.0),
                        const SizedBox(width: 4.0),
                        Text(
                          '${spot['rating']}',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // 位置
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.secondaryTextColor,
                      size: 16.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      spot['location'] as String,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // 标签
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      (spot['tags'] as List<String>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTextColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12.0,
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12.0),
                // 价格和按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '¥${spot['price']}',
                            style: TextStyle(
                              color: AppTheme.buttonColor,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' /人',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.buttonColor,
                            AppTheme.buttonColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Text(
                        '查看详情',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
  // 背景动画控制器 - 与消息页面保持一致
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 内容动画控制器 - 与消息页面保持一致
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;

  // 添加甜甜圈图表动画控制器
  late AnimationController _donutChartAnimController;
  late Animation<double> _donutChartAnimation;

  // 在_ProfileTabState中添加旅行事件数据
  final List<TravelEvent> _travelEvents = [
    TravelEvent(
      location: '东京',
      date: '2023年10月15日',
      description: '参观了浅草寺和东京塔，体验了当地美食。',
      imageUrl: 'assets/images/tokyo.jpg',
      dotColor: AppTheme.neonBlue,
    ),
    TravelEvent(
      location: '巴黎',
      date: '2023年7月22日',
      description: '游览了埃菲尔铁塔和卢浮宫，品尝了正宗的法式甜点。',
      imageUrl: 'assets/images/paris.jpg',
      dotColor: AppTheme.neonPurple,
    ),
    TravelEvent(
      location: '曼谷',
      date: '2023年4月5日',
      description: '参观了大皇宫和卧佛寺，享受了泰式按摩。',
      imageUrl: 'assets/images/bangkok.jpg',
      dotColor: AppTheme.neonOrange,
    ),
    TravelEvent(
      location: '纽约',
      date: '2022年12月18日',
      description: '参观了自由女神像和时代广场，体验了百老汇演出。',
      imageUrl: 'assets/images/newyork.jpg',
      dotColor: AppTheme.neonGreen,
    ),
  ];

  // 个人资料统计项构建方法
  Widget _buildProfileStat({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // 初始化背景动画控制器 - 与消息页面保持完全一致
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化内容动画控制器 - 与消息页面保持完全一致
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );

    // 初始化甜甜圈图表动画控制器
    _donutChartAnimController = AnimationController(
      duration: const Duration(seconds: 20), // 较慢的旋转
      vsync: this,
    )..repeat(); // 持续旋转

    _donutChartAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi, // 完整的一圈
    ).animate(_donutChartAnimController);

    // 启动动画
    _contentAnimController.forward();
  }

  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _donutChartAnimController.dispose(); // 释放图表动画控制器资源
    super.dispose();
  }

  @override
  void didUpdateWidget(_ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 确保页面切换动画与消息页面保持完全一致
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _contentAnimController.reset();
      _contentAnimController.forward();
      // 确保背景动画在页面可见时运行
      if (!_backgroundAnimController.isAnimating) {
        _backgroundAnimController.repeat(reverse: true);
      }
      // 确保图表动画在页面可见时运行
      if (!_donutChartAnimController.isAnimating) {
        _donutChartAnimController.repeat();
      }
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      // 当页面不再是当前页面时，暂停耗费资源的动画
      _backgroundAnimController.stop();
      _donutChartAnimController.stop();
    }
  }

  // 创建一个卡片动画组件，包含交错动画效果
  Widget _buildAnimatedCard(Widget child, int index) {
    // 计算交错动画的延迟
    final delay = 0.2 + (index * 0.1);
    final endDelay = math.min(1.0, delay + 0.4);

    return AnimatedBuilder(
      animation: _contentAnimController,
      builder: (context, child) {
        // 只有当动画控制器值大于延迟时才开始该卡片的动画
        final animValue = math.max(
          0.0,
          math.min(
            1.0,
            (_contentAnimController.value - delay) / (endDelay - delay),
          ),
        );

        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(30 * (1 - animValue), 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // 显示帮助与反馈弹窗
  void _showHelpAndFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // 点击空白处关闭
      barrierColor: Colors.black.withOpacity(0.6), // 更深的背景遮罩
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
                      "帮助与反馈",
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

                    // 按钮
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            width: 45,
                            height: 45,
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
                      Icons.support_agent,
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

  // 构建联系方式项目
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

  // 显示关于我们弹窗
  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // 点击空白处关闭
      barrierColor: Colors.black.withOpacity(0.6), // 更深的背景遮罩
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
                      color: AppTheme.neonPurple.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    Text(
                      "关于我们",
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonPurple.withOpacity(0.3),
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
                            AppTheme.neonPurple.withOpacity(0.5),
                            AppTheme.neonBlue.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPurple.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // 版本信息
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: AppTheme.neonPurple.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPurple.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Travel Joy v1.0.0",
                        style: TextStyle(
                          color: AppTheme.neonPurple,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // 说明文本
                    Text(
                      "Travel Joy 是一款专为旅行爱好者设计的社交应用，致力于帮助用户发现精彩目的地、分享旅行体验、结识志同道合的朋友。",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16.0,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 30.0),

                    // 信息卡片
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: AppTheme.neonPurple.withOpacity(0.2),
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
                        children: [
                          // 网站信息
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonPurple.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.neonPurple.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.public,
                                  color: AppTheme.neonPurple,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "官方网站",
                                      style: TextStyle(
                                        color: AppTheme.secondaryTextColor,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6.0),
                                    Text(
                                      "www.traveljoy.com",
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
                          ),

                          const SizedBox(height: 20.0),

                          // 版权信息
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: AppTheme.secondaryTextColor.withOpacity(
                                  0.1,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.copyright,
                                  color: AppTheme.secondaryTextColor,
                                  size: 16.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "2023 Travel Joy Team. All rights reserved.",
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 14.0,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30.0),

                    // 按钮
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                              border: Border.all(
                                color: AppTheme.neonPurple.withOpacity(0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppTheme.neonPurple.withOpacity(0.9),
                              size: 24,
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
                        colors: [AppTheme.neonPurple, AppTheme.neonBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonPurple.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.travel_explore,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 添加动态渐变背景，实现背景微动效果 - 参考消息页面
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: Stack(
        children: [
          // 动态光晕效果 - 完全匹配消息页面
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 动态光晕效果
                  Positioned(
                    left:
                        MediaQuery.of(context).size.width *
                        (0.3 +
                            0.3 *
                                math.sin(_backgroundAnimation.value * math.pi)),
                    top:
                        MediaQuery.of(context).size.height *
                        (0.3 +
                            0.2 *
                                math.cos(_backgroundAnimation.value * math.pi)),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.neonBlue.withOpacity(0.4),
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
                            0.2 *
                                math.cos(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
                    bottom:
                        MediaQuery.of(context).size.height *
                        (0.2 +
                            0.2 *
                                math.sin(
                                  _backgroundAnimation.value * math.pi + 1,
                                )),
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
          ),

          // 主内容 - 动画与消息页面保持完全一致
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: _buildProfileContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建个人资料内容 - 按要求优化布局
  Widget _buildProfileContent() {
    // 功能列表数据
    final List<Map<String, dynamic>> functionItems = [
      {
        'icon': Icons.person_outline_rounded,
        'title': '我的信息',
        'color': AppTheme.neonTeal,
        'action': () {
          // 跳转到用户信息页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserStatsScreen()),
          );
        },
      },
      {
        'icon': Icons.map_outlined,
        'title': '旅行足迹',
        'color': AppTheme.neonPurple,
        'action': () {
          // 直接跳转到旅行足迹页面
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TravelHistoryScreen(
                    events: [
                      TravelEvent(
                        location: '东京',
                        date: '2023年10月15日',
                        description: '参观了浅草寺和东京塔，体验了当地美食。',
                        imageUrl: 'assets/images/tokyo.jpg',
                        dotColor: AppTheme.neonBlue,
                      ),
                      TravelEvent(
                        location: '巴黎',
                        date: '2023年7月22日',
                        description: '游览了埃菲尔铁塔和卢浮宫，品尝了正宗的法式甜点。',
                        imageUrl: 'assets/images/paris.jpg',
                        dotColor: AppTheme.neonPurple,
                      ),
                      TravelEvent(
                        location: '曼谷',
                        date: '2023年4月5日',
                        description: '参观了大皇宫和卧佛寺，享受了泰式按摩。',
                        imageUrl: 'assets/images/bangkok.jpg',
                        dotColor: AppTheme.neonOrange,
                      ),
                      TravelEvent(
                        location: '纽约',
                        date: '2022年12月18日',
                        description: '参观了自由女神像和时代广场，体验了百老汇演出。',
                        imageUrl: 'assets/images/newyork.jpg',
                        dotColor: AppTheme.neonGreen,
                      ),
                    ],
                  ),
            ),
          );
        },
      },
      {
        'icon': Icons.bookmark_rounded,
        'title': '我的收藏',
        'color': AppTheme.neonBlue,
        'action': () {
          NavigationUtils.slideAndFadeNavigateTo(
            context: context,
            page: const CollectionScreen(),
          );
        },
      },
      {
        'icon': Icons.emoji_events_rounded,
        'title': '我的成就',
        'color': AppTheme.neonYellow,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementScreen()),
          );
        },
      },
      {
        'icon': Icons.card_giftcard_rounded,
        'title': '积分兑换',
        'color': AppTheme.neonPurple,
        'action': () => Navigator.pushNamed(context, '/points_exchange'),
      },
      {
        'icon': Icons.celebration_rounded,
        'title': '活动中心',
        'color': AppTheme.neonPink,
        'action': () {
          NavigationUtils.slideAndFadeNavigateTo(
            context: context,
            page: const ActivityScreen(),
          );
        },
      },
      {
        'icon': Icons.settings_rounded,
        'title': '设置',
        'color': AppTheme.neonTeal,
        'action':
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
      },
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. 用户信息区
        _buildAnimatedCard(
          Container(
            margin: const EdgeInsets.only(bottom: 24.0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2C2E43).withOpacity(0.95),
                  Color(0xFF3A2D49).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 头像 - 带等级标志
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // 外环渐变边框
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.neonBlue.withOpacity(0.8),
                                AppTheme.neonPurple.withOpacity(0.8),
                              ],
                            ),
                          ),
                        ),
                        // 内圈边框
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.backgroundColor,
                          ),
                        ),
                        // 头像
                        Container(
                          width: 58,
                          height: 58,
                          child: ClipOval(
                            child: Image.asset(
                              "assets/images/avatars/default_avatar.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // 等级标志
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.neonBlue,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.6),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              "Lv.6",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // 用户信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "艾米丽",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              // 编辑按钮 - 移除背景色
                              IconButton(
                                onPressed: () {
                                  print('编辑个人资料');
                                },
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppTheme.neonYellow,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "高级旅行家",
                                      style: TextStyle(
                                        color: AppTheme.neonYellow,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonTeal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: AppTheme.neonTeal,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "已认证",
                                      style: TextStyle(
                                        color: AppTheme.neonTeal,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "热爱探索，喜欢记录美好时刻",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 经验值进度条
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "经验值：2850/3000",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "距离下一级：150",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        // 底层进度条
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        // 实际进度
                        FractionallySizedBox(
                          widthFactor: 0.95, // 95%进度
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF4ACEE5), Color(0xFFB65EBA)],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 统计数据
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildProfileStat(
                      icon: Icons.flight_takeoff_rounded,
                      color: Color(0xFF4ACEE5),
                      value: "12",
                      label: "总旅行",
                    ),
                    _buildProfileStat(
                      icon: Icons.location_on_rounded,
                      color: Color(0xFF9C6DFF),
                      value: "8",
                      label: "国家",
                    ),
                    _buildProfileStat(
                      icon: Icons.map_rounded,
                      color: Color(0xFFFC9E5C),
                      value: "23",
                      label: "城市",
                    ),
                    _buildProfileStat(
                      icon: Icons.emoji_events_rounded,
                      color: Color(0xFFFFC736),
                      value: "15",
                      label: "成就",
                    ),
                  ],
                ),
              ],
            ),
          ),
          0,
        ),

        // 3. 功能列表
        _buildAnimatedCard(
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: functionItems.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  indent: 56.0,
                  color: AppTheme.secondaryTextColor.withOpacity(0.1),
                );
              },
              itemBuilder: (context, index) {
                final item = functionItems[index];
                return ListTile(
                  leading: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 20.0),
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.secondaryTextColor,
                    size: 16.0,
                  ),
                  onTap: item['action'],
                  // 悬浮效果
                  hoverColor: AppTheme.primaryTextColor.withOpacity(0.05),
                  splashColor: AppTheme.primaryTextColor.withOpacity(0.1),
                );
              },
            ),
          ),
          2,
        ),

        // 底部间距
        const SizedBox(height: 16.0),
      ],
    );
  }

  // 构建统计项
  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      splashColor: color.withOpacity(0.1),
      highlightColor: color.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 24.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }

  // 构建地图标记点
  Widget _buildMapMarker(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // 构建旅行类型项
  Widget _buildTypeItem(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 12.0,
            ),
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// 甜甜圈图表数据模型
class DonutSegment {
  final String label;
  final double value;
  final Color color;

  DonutSegment({required this.label, required this.value, required this.color});
}

// 条形图数据模型
class BarChartData {
  final String label;
  final double value;
  final Color color;

  BarChartData({required this.label, required this.value, required this.color});
}

// 甜甜圈图表绘制器 - 添加动画支持
class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double width;
  final double rotationAngle; // 添加旋转角度参数

  DonutChartPainter({
    required this.segments,
    this.width = 25.0,
    this.rotationAngle = 0.0, // 默认不旋转
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - width / 2;

    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + segment.value,
    );

    // 从顶部开始，添加旋转角度
    double startAngle = -math.pi / 2 + rotationAngle;

    for (var segment in segments) {
      final sweepAngle = 2 * math.pi * (segment.value / total);

      final paint =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..color = segment.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.width != width ||
        oldDelegate.rotationAngle != rotationAngle; // 检查旋转角度是否变化
  }
}

// 条形图绘制器
class BarChartPainter extends CustomPainter {
  final List<BarChartData> data;
  final double maxValue;

  BarChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / (data.length * 1.5);
    final spacing = barWidth / 2;
    final chartHeight = size.height - 40; // 为标签留出空间

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final barHeight = (item.value / maxValue) * chartHeight;

      // 绘制条形
      final barPaint =
          Paint()
            ..color = item.color
            ..style = PaintingStyle.fill;

      final barRect = Rect.fromLTWH(
        i * (barWidth + spacing) + spacing,
        size.height - barHeight - 20, // 从底部减去20给标签留空间
        barWidth,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, Radius.circular(barWidth / 2)),
        barPaint,
      );

      // 绘制标签
      final textPainter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10.0),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          i * (barWidth + spacing) +
              spacing +
              (barWidth - textPainter.width) / 2,
          size.height - 15,
        ),
      );

      // 绘制数值
      final valuePainter = TextPainter(
        text: TextSpan(
          text: "${item.value.toInt()}",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valuePainter.layout();
      valuePainter.paint(
        canvas,
        Offset(
          i * (barWidth + spacing) +
              spacing +
              (barWidth - valuePainter.width) / 2,
          size.height - barHeight - 35, // 在柱子上方显示数值
        ),
      );
    }
  }

  @override
  bool shouldRepaint(BarChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.maxValue != maxValue;
  }
}
