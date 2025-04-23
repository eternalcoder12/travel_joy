import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../explore/spot_detail_screen.dart';
import '../explore/map_view_screen.dart';

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

  // 搜索文本控制器
  final TextEditingController _searchController = TextEditingController();

  // 当前选中的分类索引
  int _selectedCategoryIndex = 0;

  // 分类列表
  final List<String> _categories = ['全部', '自然风光', '历史遗迹', '文化体验', '美食', '住宿'];

  // 推荐景点数据
  final List<Map<String, dynamic>> _recommendedSpots = [
    {
      'name': '西湖风景区',
      'location': '杭州, 浙江',
      'image':
          'https://images.unsplash.com/photo-1598887142487-d835e88c5e77?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
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
          'https://images.unsplash.com/photo-1584283626530-7c19deb65766?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
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
          'https://images.unsplash.com/photo-1583065435836-f6490d265eb5?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
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
          'https://images.unsplash.com/photo-1593709942239-e423f46750c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
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
          'https://images.unsplash.com/photo-1602920344572-87add3d82be7?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.5,
      'tags': ['古城', '文化', '民俗'],
      'description':
          '丽江古城始建于宋末元初，是中国为数不多的保存完好的少数民族古城，也是世界文化遗产。古城内的四方街是丽江古城的中心广场，由花石铺就而成。小巷纵横交错，清澈的溪流穿城而过，体现了纳西族独特的文化传统和建筑风格。',
      'price': '80',
    },
  ];

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
    _searchController.dispose();
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
        child: Column(
          children: [
            Padding(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          '探索',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // 区块2: 搜索栏和地图按钮 (从右侧飞入)
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: '搜索景点、城市、体验...',
                                hintStyle: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppTheme.primaryTextColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MapViewScreen(
                                      spots: _recommendedSpots,
                                      initialSpotIndex: 0,
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.buttonColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.buttonColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.map, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20.0),

                  // 区块3: 分类选项卡 (从右侧飞入)
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
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final bool isSelected =
                              _selectedCategoryIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoryIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppTheme.buttonColor.withOpacity(
                                            0.8,
                                          )
                                          : AppTheme.cardColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _categories[index],
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppTheme.secondaryTextColor,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 区块3: 推荐景点列表 (从下方飞入)
            Expanded(
              child: AnimatedBuilder(
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
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _recommendedSpots.length,
                  itemBuilder: (context, index) {
                    final spot = _recommendedSpots[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildSpotCard(spot),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 景点卡片构建方法
  Widget _buildSpotCard(Map<String, dynamic> spot) {
    return GestureDetector(
      onTap: () {
        // 导航到景点详情页
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailScreen(spotData: spot),
          ),
        );
      },
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景图片和渐变
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // 图片
                  Image.network(
                    spot['image'],
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        color: AppTheme.cardColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.buttonColor,
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: AppTheme.cardColor,
                        child: Center(
                          child: Icon(
                            Icons.error,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      );
                    },
                  ),

                  // 渐变遮罩
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 景点信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 景点名称
                  Text(
                    spot['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 位置和评分
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        spot['location'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        spot['rating'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 标签
                  Wrap(
                    spacing: 8,
                    children:
                        (spot['tags'] as List<String>).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),

            // 收藏按钮
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
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
