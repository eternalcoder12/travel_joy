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
  double _hoverScale = 0.97;

  // 今日信息
  final String _todayInfo = "晴天 25°C，适合户外探索";

  // 默认渐变颜色 - 用于任何卡片没有指定颜色时
  final List<Color> _defaultGradient = [
    const Color(0xFF3A1C71),
    const Color(0xFFD76D77),
    const Color(0xFFFFAF7B),
  ];

  // 功能卡片数据 - 使用非空颜色列表
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
      duration: const Duration(milliseconds: 2000),
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
          _hoverScale = 0.97 + (_hoverAnimationController!.value * 0.03);
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
              horizontal: 20.0,
              vertical: 28.0,
            ),
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

                const SizedBox(height: 32.0), // 今日信息与标题间距增加
                // 标题 - 更显眼
                Text(
                  '开启小众之旅',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 32.0, // 增大标题字体
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12.0), // 标题与副标题间距增加
                // 副标题
                Text(
                  '发现隐秘美景，享受独特旅途',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16.0, // 增大副标题字体
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 36.0), // 副标题与卡片间距增加
                // 功能卡片网格（2x3）- 改为垂直列表样式，每个卡片更丰富
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _featureCards.length,
                  itemBuilder: (context, index) {
                    // 提取卡片数据，确保渐变颜色非空
                    final cardData = _featureCards[index];
                    final List<Color> gradientColors =
                        (cardData['gradientColors'] as List<Color>?) ??
                        _defaultGradient;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildFeatureCard(
                        context: context,
                        title: cardData['title'] as String,
                        subtitle: cardData['subtitle'] as String,
                        icon: cardData['icon'] as IconData,
                        tag: cardData['tag'] as String,
                        tagColor: cardData['tagColor'] as Color,
                        gradientColors: gradientColors,
                        animation: _slideAnimations?[index],
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

  // 横向布局功能卡片 - 更平衡的设计
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String tag,
    required Color tagColor,
    required List<Color> gradientColors,
    required Animation<Offset>? animation,
  }) {
    // 确保渐变颜色非空，否则使用默认颜色
    final colors =
        gradientColors.isNotEmpty ? gradientColors : _defaultGradient;

    return SlideTransition(
      position: animation ?? const AlwaysStoppedAnimation<Offset>(Offset.zero),
      child: Transform.scale(
        scale: _hoverScale,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
          clipBehavior: Clip.antiAlias,
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
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Container(
              height: 100, // 固定高度
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
                    blurRadius: 8.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // 主要内容 - 水平布局
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
      ),
    );
  }
}
