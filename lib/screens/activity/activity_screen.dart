import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'dart:math' as math;
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';

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

  // 获取状态颜色
  Color getStatusColor() {
    switch (status) {
      case '未开始':
        return Colors.amber;
      case '进行中':
        return Colors.green;
      case '已结束':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // 格式化日期显示
  String getFormattedDate() {
    String startMonth = '${startDate.month}月${startDate.day}日';
    String endMonth = '${endDate.month}月${endDate.day}日';

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      // 同一天的活动
      return '$startMonth ${startDate.hour}:00-${endDate.hour}:00';
    } else {
      // 跨天的活动
      return '$startMonth - $endMonth';
    }
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

          // 搜索按钮
          CircleButton(
            icon: Icons.search_rounded,
            onPressed: () {
              // 搜索活动
            },
            size: 38,
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
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
          // 活动图片区域 - 重新设计
          Stack(
            children: [
              // 活动图片
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: activity.getStatusColor().withOpacity(0.3),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 加载中心图标
                      Icon(
                        activity.icon,
                        color: Colors.white.withOpacity(0.6),
                        size: 40,
                      ),
                      // 状态标签
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF191A2D),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: activity.getStatusColor(),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: activity.getStatusColor(),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.status,
                                style: TextStyle(
                                  color: activity.getStatusColor(),
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
              ),
            ],
          ),

          // 活动标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (activity.price == 0)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '免费活动',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.neonYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${activity.price}/人 (仅用于服务器维护)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neonYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 奖励信息
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: AppTheme.neonYellow, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '获得${activity.points}积分',
                        style: TextStyle(
                          color: AppTheme.neonYellow,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.neonBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${activity.experience}经验值',
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 活动详情
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.access_time_rounded,
                  '活动时间',
                  activity.getFormattedDate(),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on_rounded,
                  '活动地点',
                  activity.location,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.people_rounded,
                  '参与人数',
                  '${activity.participantsCount}/${activity.maxParticipants}人',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.business_center_rounded,
                  '组织者',
                  activity.organizer,
                ),
              ],
            ),
          ),

          // 活动详情按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 分享按钮
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 8),
                // 收藏按钮
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(width: 12),
                // 参与活动按钮
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: activity.status == '已结束' ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            activity.status == '已结束'
                                ? Colors.grey.withOpacity(0.3)
                                : AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: activity.status == '已结束' ? 0 : 2,
                      ),
                      child: Text(
                        activity.status == '已结束' ? '活动已结束' : '取消报名',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // 加载更多活动
  Future<void> _loadMoreActivities() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // 模拟获取更多数据
    final moreActivities = Activity.getSampleActivities().take(5).toList();

    // 模拟加载完所有数据的情况
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

  // 应用筛选
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;

      // 先清除列表
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

      // 重置滚动控制器
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  // 构建空状态
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

  // 构建加载指示器
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
