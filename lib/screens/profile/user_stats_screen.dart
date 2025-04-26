import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';
import '../travel/travel_history_screen.dart';
import '../../widgets/travel_timeline.dart';
import 'dart:math' as math;

class UserStatsScreen extends StatefulWidget {
  const UserStatsScreen({Key? key}) : super(key: key);

  @override
  _UserStatsScreenState createState() => _UserStatsScreenState();
}

class _UserStatsScreenState extends State<UserStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _contentAnimationController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  // 用户旅行统计数据
  final int citiesVisited = 4;
  final int countriesVisited = 0;
  final int footprintsCount = 4;
  final int totalTrips = 12;
  final int totalPoints = 1242;
  final int achievements = 8;
  final int favorites = 42;

  // 旅行偏好数据
  final Map<String, double> travelPreferences = {
    '自然风光': 45,
    '城市探索': 30,
    '历史文化': 15,
    '美食体验': 10,
  };

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
                        padding: EdgeInsets.zero,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // 旅行足迹板块
                          _buildTravelFootprintsCard(),

                          // 旅行统计数据
                          _buildTravelStatsCard(),

                          // 旅行偏好分析
                          _buildTravelPreferencesCard(),

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
                      AppTheme.neonPurple.withOpacity(0.2),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => Navigator.pop(context),
            size: 38,
            iconSize: 16,
          ),

          // 标题
          const Text(
            '我的信息',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),

          // 右侧占位，保持标题居中
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildTravelFootprintsCard() {
    return AnimatedItemSlideInFromLeft(
      animationController: _contentAnimationController,
      animationStart: 0.0,
      animationEnd: 0.5,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.neonPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.place_rounded,
                    color: AppTheme.neonPurple,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '旅行足迹',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),

                // 微型进度指示器
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timeline, color: AppTheme.neonTeal, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '4/10',
                        style: TextStyle(
                          color: AppTheme.neonTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 统计数据行 - 更丰富的视觉设计
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEnhancedStat(
                  iconData: Icons.location_city,
                  color: AppTheme.neonTeal,
                  value: citiesVisited.toString(),
                  label: '城市',
                  width: 95,
                ),
                _buildEnhancedStat(
                  iconData: Icons.public,
                  color: AppTheme.neonPurple,
                  value: countriesVisited.toString(),
                  label: '国家',
                  width: 95,
                ),
                _buildEnhancedStat(
                  iconData: Icons.pin_drop_rounded,
                  color: AppTheme.neonPink,
                  value: footprintsCount.toString(),
                  label: '足迹',
                  width: 95,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 查看全部按钮 - 更丰富的视觉设计
            InkWell(
              onTap: () {
                // 跳转到足迹地图页面
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonBlue.withOpacity(0.3),
                      AppTheme.neonPurple.withOpacity(0.3),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.neonBlue.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 按钮文字
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '查看全部旅行足迹',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ],
                    ),

                    // 右侧装饰图标
                    Positioned(
                      right: 10,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.white.withOpacity(0.7),
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 增强版统计项
  Widget _buildEnhancedStat({
    required IconData iconData,
    required Color color,
    required String value,
    required String label,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelPreferencesCard() {
    return AnimatedItemSlideInFromRight(
      animationController: _contentAnimationController,
      animationStart: 0.1,
      animationEnd: 0.6,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppTheme.neonBlue, size: 18),
                const SizedBox(width: 8),
                Text(
                  '旅行偏好分析',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 偏好图表
            Row(
              children: [
                // 圆环图
                Container(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: DonutChartPainter(travelPreferences),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '自然风光',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '45%',
                            style: TextStyle(
                              color: AppTheme.neonTeal,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // 图例
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(AppTheme.neonTeal, '自然风光', '45%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppTheme.neonPurple, '城市探索', '30%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppTheme.neonYellow, '历史文化', '15%'),
                      const SizedBox(height: 8),
                      _buildLegendItem(AppTheme.neonPink, '美食体验', '10%'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 水平分隔线
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),

            // 底部统计
            Text(
              '根据您的12次旅行数据分析得出，您更偏好自然风光类旅行目的地',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 14)),
        const Spacer(),
        Text(
          percentage,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelStatsCard() {
    return AnimatedItemSlideInFromLeft(
      animationController: _contentAnimationController,
      animationStart: 0.2,
      animationEnd: 0.7,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.insights, color: AppTheme.neonGreen, size: 18),
                const SizedBox(width: 8),
                Text(
                  '旅行统计',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 统计数据
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.flight_takeoff_rounded,
                  AppTheme.neonTeal,
                  totalTrips.toString(),
                  '总旅行',
                ),
                _buildStatItem(
                  Icons.stars_rounded,
                  AppTheme.neonPurple,
                  totalPoints.toString(),
                  '积分',
                ),
                _buildStatItem(
                  Icons.emoji_events_rounded,
                  AppTheme.neonYellow,
                  achievements.toString(),
                  '成就',
                ),
                _buildStatItem(
                  Icons.bookmark_rounded,
                  AppTheme.neonGreen,
                  favorites.toString(),
                  '收藏',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}

// 自定义环形图
class DonutChartPainter extends CustomPainter {
  final Map<String, double> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    final innerRadius = radius * 0.6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -math.pi / 2; // 从顶部开始绘制

    // 准备颜色
    final colors = [
      AppTheme.neonTeal,
      AppTheme.neonPurple,
      AppTheme.neonYellow,
      AppTheme.neonPink,
    ];

    int colorIndex = 0;
    data.forEach((key, value) {
      final sweepAngle = 2 * math.pi * (value / 100);

      // 绘制圆弧
      final paint =
          Paint()
            ..color = colors[colorIndex % colors.length]
            ..style = PaintingStyle.stroke
            ..strokeWidth = (radius - innerRadius);

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

      startAngle += sweepAngle;
      colorIndex++;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
