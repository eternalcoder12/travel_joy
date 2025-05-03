import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'dart:math' as math;
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';
import 'package:travel_joy/widgets/network_image.dart' as network;

// 活动数据模型
class Activity {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final String organizer;
  final int participantsCount;
  final bool isRegistered;
  final String status; // 未开始、进行中、已结束
  final int maxParticipants;
  final List<String> tags;
  final double price; // 统一为1元
  final int points; // 可获得的积分
  final int experience; // 可获得的经验值

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.organizer,
    required this.participantsCount,
    required this.isRegistered,
    required this.status,
    required this.maxParticipants,
    required this.tags,
    required this.price,
    required this.points,
    required this.experience,
  });

  // 获取状态颜色
  Color getStatusColor() {
    switch (status) {
      case '未开始':
        return AppTheme.neonYellow;
      case '进行中':
        return AppTheme.neonGreen;
      case '已结束':
        return Colors.grey;
      default:
        return AppTheme.neonBlue;
    }
  }

  // 格式化日期
  String getFormattedDate() {
    final startFormat =
        '${startDate.month}月${startDate.day}日 ${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}';
    final endFormat =
        '${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}';
    return '$startFormat-$endFormat';
  }

  // 样例活动数据
  static List<Activity> getSampleActivities() {
    return [
      Activity(
        id: '1',
        title: '春季樱花摄影之旅',
        description:
            '快速体验摄影打卡活动，获取旅行积分和经验值。活动结束后可获得50积分和30经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5, hours: 4)),
        location: '东京新宿御苑',
        imageUrl: 'assets/images/activities/sakura.jpg',
        icon: Icons.camera_alt,
        color: AppTheme.neonPink,
        organizer: '旅行乐摄影社',
        participantsCount: 35,
        isRegistered: true,
        status: '未开始',
        maxParticipants: 50,
        tags: ['摄影', '赏花', '春季特辑'],
        price: 1, // 统一为1元
        points: 50, // 可获得积分
        experience: 30, // 可获得经验值
      ),
      Activity(
        id: '2',
        title: '古镇美食探索之旅',
        description:
            '体验美食打卡活动，快速获取旅行积分和经验值。活动结束后可获得60积分和40经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 2, hours: 6)),
        location: '乌镇景区',
        imageUrl: 'assets/images/activities/food_tour.jpg',
        icon: Icons.restaurant,
        color: AppTheme.neonYellow,
        organizer: '寻味旅行团',
        participantsCount: 28,
        isRegistered: false,
        status: '未开始',
        maxParticipants: 30,
        tags: ['美食', '文化体验', '品鉴'],
        price: 1,
        points: 60,
        experience: 40,
      ),
      Activity(
        id: '3',
        title: '深海潜水体验课程',
        description:
            '参与水上活动打卡，快速获取旅行积分和经验值。活动结束后可获得100积分和80经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        location: '巴厘岛库塔海滩',
        imageUrl: 'assets/images/activities/diving.jpg',
        icon: Icons.pool,
        color: AppTheme.neonBlue,
        organizer: '蓝海潜水俱乐部',
        participantsCount: 12,
        isRegistered: true,
        status: '进行中',
        maxParticipants: 15,
        tags: ['潜水', '水上活动', '技能学习'],
        price: 1,
        points: 100,
        experience: 80,
      ),
      Activity(
        id: '4',
        title: '城市文化徒步之旅',
        description:
            '探索城市文化打卡，获取旅行积分和经验值。活动结束后可获得40积分和25经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(hours: 48)),
        endDate: DateTime.now().add(const Duration(hours: 52)),
        location: '巴黎蒙马特区',
        imageUrl: 'assets/images/activities/city_walk.jpg',
        icon: Icons.directions_walk,
        color: AppTheme.neonGreen,
        organizer: '文化漫步组织',
        participantsCount: 20,
        isRegistered: false,
        status: '未开始',
        maxParticipants: 25,
        tags: ['徒步', '历史', '城市探索'],
        price: 1,
        points: 40,
        experience: 25,
      ),
      Activity(
        id: '5',
        title: '高山露营星空夜',
        description:
            '体验户外露营打卡，快速获取旅行积分和经验值。活动结束后可获得80积分和50经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 16)),
        location: '阿尔卑斯山脉',
        imageUrl: 'assets/images/activities/camping.jpg',
        icon: Icons.nightlight_round,
        color: AppTheme.neonPurple,
        organizer: '星空探索者',
        participantsCount: 15,
        isRegistered: false,
        status: '未开始',
        maxParticipants: 40,
        tags: ['露营', '观星', '自然体验'],
        price: 1,
        points: 80,
        experience: 50,
      ),
      Activity(
        id: '6',
        title: '传统工艺工作坊',
        description:
            '参与文化工艺打卡，快速获取旅行积分和经验值。活动结束后可获得45积分和30经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        location: '京都艺术区',
        imageUrl: 'assets/images/activities/craft.jpg',
        icon: Icons.build,
        color: AppTheme.neonOrange,
        organizer: '匠心工艺坊',
        participantsCount: 45,
        isRegistered: true,
        status: '已结束',
        maxParticipants: 50,
        tags: ['手工艺', '文化体验', '创作'],
        price: 1,
        points: 45,
        experience: 30,
      ),
      Activity(
        id: '7',
        title: '热气球日出体验',
        description:
            '参与空中体验打卡，获取大量旅行积分和经验值。活动结束后可获得120积分和90经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30, hours: 3)),
        location: '卡帕多奇亚',
        imageUrl: 'assets/images/activities/balloon.jpg',
        icon: Icons.flight,
        color: AppTheme.neonPink,
        organizer: '天际冒险公司',
        participantsCount: 8,
        isRegistered: false,
        status: '未开始',
        maxParticipants: 20,
        tags: ['热气球', '日出', '空中体验'],
        price: 1,
        points: 120,
        experience: 90,
      ),
      Activity(
        id: '8',
        title: '夏日沙滩瑜伽课',
        description:
            '参与健康瑜伽打卡，获取旅行积分和经验值。活动结束后可获得30积分和20经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(hours: 36)),
        endDate: DateTime.now().add(const Duration(hours: 38)),
        location: '巴厘岛库塔海滩',
        imageUrl: 'assets/images/activities/yoga.jpg',
        icon: Icons.self_improvement,
        color: AppTheme.neonTeal,
        organizer: '海滩瑜伽联盟',
        participantsCount: 22,
        isRegistered: true,
        status: '未开始',
        maxParticipants: 30,
        tags: ['瑜伽', '健康', '海滩活动'],
        price: 1,
        points: 30,
        experience: 20,
      ),
      Activity(
        id: '9',
        title: '冬季温泉疗养之旅',
        description:
            '参与温泉疗养打卡，获取旅行积分和经验值。活动结束后可获得65积分和45经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().add(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 45, hours: 5)),
        location: '北海道登别温泉',
        imageUrl: 'assets/images/activities/onsen.jpg',
        icon: Icons.hot_tub,
        color: AppTheme.neonPurple,
        organizer: '和风温泉会',
        participantsCount: 30,
        isRegistered: false,
        status: '未开始',
        maxParticipants: 40,
        tags: ['温泉', '疗养', '冬季特辑'],
        price: 1,
        points: 65,
        experience: 45,
      ),
      Activity(
        id: '10',
        title: '单车环湖一日游',
        description:
            '参与骑行打卡，获取旅行积分和经验值。活动结束后可获得55积分和35经验值。活动费用1元仅用于维护服务器运行，不作为商业收益。',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().subtract(const Duration(days: 10)),
        location: '杭州西湖',
        imageUrl: 'assets/images/activities/cycling.jpg',
        icon: Icons.directions_bike,
        color: AppTheme.neonGreen,
        organizer: '绿色出行俱乐部',
        participantsCount: 25,
        isRegistered: false,
        status: '已结束',
        maxParticipants: 30,
        tags: ['骑行', '自然风光', '户外活动'],
        price: 1,
        points: 55,
        experience: 35,
      ),
    ];
  }
}

// 自定义背景绘制器
class _ActivityCardBackgroundPainter extends CustomPainter {
  final Color color;

  _ActivityCardBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制小点点装饰
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    // 绘制随机分布的小圆点
    final random = math.Random(42); // 固定随机种子确保一致性
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1; // 1-3 像素大小的圆点
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // 绘制弧线装饰
    final linePaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // 左上角弧线
    final path1 =
        Path()
          ..moveTo(size.width * 0.1, size.height * 0.2)
          ..quadraticBezierTo(
            size.width * 0.2,
            size.height * 0.1,
            size.width * 0.3,
            size.height * 0.15,
          );
    canvas.drawPath(path1, linePaint);

    // 右下角弧线
    final path2 =
        Path()
          ..moveTo(size.width * 0.7, size.height * 0.8)
          ..quadraticBezierTo(
            size.width * 0.8,
            size.height * 0.9,
            size.width * 0.9,
            size.height * 0.7,
          );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(_ActivityCardBackgroundPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _showBackToTopButton = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  // 活动列表数据
  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  String _currentFilter = "全部活动";

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

    // 背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 背景动画
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动背景动画循环
    _backgroundAnimController.repeat(reverse: true);

    // 启动入场动画
    _animationController.forward();

    // 加载活动数据
    _loadActivities();

    // 增强滚动监听，更新返回顶部按钮的显示状态
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showBackToTopButton) {
        setState(() {
          _showBackToTopButton = showButton;
        });
      }
    });
  }

  void _loadActivities() {
    setState(() {
      _activities = Activity.getSampleActivities();
      _applyFilter(_currentFilter);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                backgroundColor: AppTheme.buttonColor.withOpacity(0.8),
                mini: true,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                onPressed: _scrollToTop,
              )
              : null,
      body: Stack(
        children: [
          // 背景动画
          _buildAnimatedBackground(),

          // 霓虹灯效果
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.neonPurple.withOpacity(
                          0.2 * _backgroundAnimation.value,
                        ),
                        AppTheme.neonBlue.withOpacity(
                          0.1 * _backgroundAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.neonGreen.withOpacity(
                          0.15 * _backgroundAnimation.value,
                        ),
                        AppTheme.neonTeal.withOpacity(
                          0.1 * _backgroundAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // 主内容
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

                    // 活动列表
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.neonPurple,
                                ),
                              )
                              : _filteredActivities.isEmpty
                              ? _buildEmptyState()
                              : NotificationListener<ScrollNotification>(
                                onNotification: (
                                  ScrollNotification notification,
                                ) {
                                  // 当滚动到底部附近时加载更多
                                  if (notification
                                          is ScrollUpdateNotification &&
                                      notification.metrics.pixels >=
                                          notification.metrics.maxScrollExtent -
                                              200 &&
                                      !_isLoadingMore &&
                                      _hasMoreData) {
                                    _loadMoreActivities();
                                  }
                                  return true;
                                },
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      _filteredActivities.length +
                                      (_hasMoreData ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < _filteredActivities.length) {
                                      return AnimatedItemSlideInFromLeft(
                                        animationController:
                                            _animationController,
                                        animationStart: 0.2 + (index * 0.1),
                                        animationEnd: 0.6 + (index * 0.1),
                                        child: _buildActivityCard(
                                          _filteredActivities[index],
                                        ),
                                      );
                                    } else {
                                      // 显示加载更多指示器
                                      return _buildLoadingIndicator();
                                    }
                                  },
                                ),
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
                      AppTheme.neonBlue.withOpacity(0.2),
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
            '活动中心',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),

          // 保持UI平衡的占位元素
          SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                child: network.NetworkImage(
                  imageUrl: activity.imageUrl,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  placeholder: const Center(child: CircularProgressIndicator()),
                  errorWidget: const Icon(Icons.error, size: 50),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activity.getStatusColor().withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        activity.status == '进行中'
                            ? Icons.play_circle_outline
                            : activity.status == '未开始'
                            ? Icons.schedule
                            : Icons.check_circle_outline,
                        color: activity.getStatusColor(),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.status,
                        style: TextStyle(
                          color: activity.getStatusColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${activity.startDate.month}/${activity.startDate.day}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white.withOpacity(0.9),
                        size: 12,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        activity.location.length > 8
                            ? '${activity.location.substring(0, 8)}...'
                            : activity.location,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (activity.isRegistered)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.neonGreen.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '已报名',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        activity.tags
                            .map(
                              (tag) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: activity.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: activity.color.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: activity.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${activity.participantsCount}/${activity.maxParticipants}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.stars, color: AppTheme.neonPurple, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          '+${activity.points}',
                          style: TextStyle(
                            color: AppTheme.neonPurple,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: AppTheme.neonBlue,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '+${activity.experience}',
                          style: TextStyle(
                            color: AppTheme.neonBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activity.color.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.business_center,
                          color: activity.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '组织者',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              activity.organizer,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildIconButton(Icons.share, AppTheme.neonBlue, () {}),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.favorite_border,
                      AppTheme.neonPink,
                      () {},
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      activity.isRegistered
                          ? Icons.check_circle_outline
                          : activity.status == '已结束'
                          ? Icons.event_busy
                          : Icons.add_circle_outline,
                      activity.getStatusColor(),
                      () => _showActivityDetails(context, activity),
                      isMain: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isMain = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMain ? 40 : 36,
        height: isMain ? 40 : 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              isMain ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          border: Border.all(
            color:
                isMain ? color.withOpacity(0.5) : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow:
              isMain
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Icon(
          icon,
          color: isMain ? color : Colors.white.withOpacity(0.7),
          size: isMain ? 20 : 18,
        ),
      ),
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _loadMoreActivities() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final moreActivities = Activity.getSampleActivities().take(5).toList();

    if (_currentPage >= 3) {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      _activities.addAll(moreActivities);
      _currentPage++;
      _isLoadingMore = false;
      _applyFilter(_currentFilter);
    });
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: activity.color.withOpacity(0.15),
                        ),
                        child: Icon(
                          activity.icon,
                          color: activity.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: activity.getStatusColor().withOpacity(
                                  0.2,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                activity.status,
                                style: TextStyle(
                                  color: activity.getStatusColor(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '报名进度: ${activity.participantsCount}/${activity.maxParticipants}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(activity.participantsCount / activity.maxParticipants * 100).toInt()}%',
                            style: TextStyle(
                              color: activity.getStatusColor(),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 8,
                            width:
                                MediaQuery.of(context).size.width *
                                0.9 *
                                (activity.participantsCount /
                                    activity.maxParticipants),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  activity.color.withOpacity(0.7),
                                  activity.color,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: activity.color.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '活动介绍',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  activity.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '活动信息',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildDetailInfoRow(
                                  Icons.access_time_rounded,
                                  '活动时间',
                                  activity.getFormattedDate(),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  height: 32,
                                  thickness: 0.2,
                                ),
                                _buildDetailInfoRow(
                                  Icons.location_on_rounded,
                                  '活动地点',
                                  activity.location,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  height: 32,
                                  thickness: 0.2,
                                ),
                                _buildDetailInfoRow(
                                  Icons.business_center_rounded,
                                  '组织者',
                                  activity.organizer,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  height: 32,
                                  thickness: 0.2,
                                ),
                                _buildDetailInfoRow(
                                  Icons.people_rounded,
                                  '参与人数',
                                  '${activity.participantsCount}/${activity.maxParticipants}人',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '活动收益',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildRewardInfoRow(
                                  Icons.stars_rounded,
                                  '获得积分',
                                  '+${activity.points}积分',
                                  AppTheme.neonYellow,
                                ),
                                const SizedBox(height: 12),
                                _buildRewardInfoRow(
                                  Icons.trending_up_rounded,
                                  '获得经验值',
                                  '+${activity.experience}经验值',
                                  AppTheme.neonBlue,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '活动标签',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      activity.tags.map((tag) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: activity.color.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: activity.color.withOpacity(
                                                0.2,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: activity.color,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                activity.color.withOpacity(0.7),
                                activity.color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: activity.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: MaterialButton(
                            onPressed:
                                activity.isRegistered ||
                                        activity.status == '已结束'
                                    ? null
                                    : () {
                                      Navigator.pop(context);
                                    },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              activity.isRegistered
                                  ? '已报名'
                                  : activity.status == '已结束'
                                  ? '已结束'
                                  : '立即报名',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _filteredActivities.clear();

      if (filter == "全部活动") {
        _filteredActivities = List.from(_activities);
      } else if (filter == "进行中") {
        _filteredActivities =
            _activities.where((activity) => activity.status == "进行中").toList();
      } else if (filter == "已报名") {
        _filteredActivities =
            _activities.where((activity) => activity.isRegistered).toList();
      } else if (filter == "未开始") {
        _filteredActivities =
            _activities.where((activity) => activity.status == "未开始").toList();
      } else if (filter == "已结束") {
        _filteredActivities =
            _activities.where((activity) => activity.status == "已结束").toList();
      }

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_busy,
            size: 60,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无${_currentFilter == "全部活动" ? "" : _currentFilter}活动',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '更多精彩活动即将推出，敬请期待！',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonPurple),
        ),
      ),
    );
  }
}
