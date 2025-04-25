import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'dart:math' as math;

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
  final double price; // 0表示免费

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
  });

  // 样例活动数据
  static List<Activity> getSampleActivities() {
    return [
      Activity(
        id: '1',
        title: '春季樱花摄影之旅',
        description:
            '加入我们的春季樱花摄影活动，探索城市最美樱花景点，专业摄影师指导拍摄技巧，并有机会赢取最佳照片奖品。适合所有级别的摄影爱好者参加，设备自备。',
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
        price: 120,
      ),
      Activity(
        id: '2',
        title: '古镇美食探索之旅',
        description:
            '体验传统古镇风味，探索隐藏在小巷中的美食珍宝。本次活动包括5个特色餐厅品尝，当地厨师讲解烹饪技巧，以及美食摄影技巧指导。适合美食爱好者和文化探索者参加。',
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
        price: 258,
      ),
      Activity(
        id: '3',
        title: '深海潜水体验课程',
        description:
            '专为初学者设计的潜水入门课程，由专业教练指导学习基本潜水技能和安全知识。活动包括理论学习和实际潜水体验，完成后可获得初级潜水证书。设备由主办方提供。',
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
        price: 680,
      ),
      Activity(
        id: '4',
        title: '城市文化徒步之旅',
        description:
            '探索城市隐藏的历史和文化宝藏，在专业导游的带领下徒步游览著名景点和隐秘角落。活动中将了解当地历史、建筑特色和文化习俗，适合文化爱好者和历史探索者。',
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
        price: 85,
      ),
      Activity(
        id: '5',
        title: '高山露营星空夜',
        description:
            '远离城市灯光污染，在高山上体验露营和观星的完美结合。活动包括专业天文讲解、望远镜观测和星空摄影指导。提供露营设备和热饮，参与者需自备保暖衣物。',
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
        price: 320,
      ),
      Activity(
        id: '6',
        title: '传统工艺工作坊',
        description:
            '学习当地传统手工艺，亲手制作纪念品。在专业工匠指导下，体验陶艺、编织或木雕等工艺，了解技艺背后的文化意义。所有材料由主办方提供，完成的作品可带回家。',
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
        price: 150,
      ),
      Activity(
        id: '7',
        title: '热气球日出体验',
        description:
            '乘坐热气球在日出时分俯瞰壮丽景色的独特体验。在专业飞行员操作下安全飞行，提供香槟早餐和摄影服务，飞行后发放纪念证书。受天气影响可能改期。',
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
        price: 990,
      ),
      Activity(
        id: '8',
        title: '夏日沙滩瑜伽课',
        description:
            '在美丽的海滩上参加专业瑜伽课程，伴随着海浪声放松身心。适合所有水平的参与者，初学者也能轻松跟随。活动包括瑜伽垫、冷饮和健康小食。',
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
        price: 75,
      ),
      Activity(
        id: '9',
        title: '冬季温泉疗养之旅',
        description:
            '在雪山环抱中体验传统温泉疗养，缓解疲劳和压力。包括多个不同温度和矿物质成分的温泉池，以及专业按摩服务。提供浴巾和基本护理用品。',
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
        price: 420,
      ),
      Activity(
        id: '10',
        title: '单车环湖一日游',
        description:
            '骑行环绕美丽湖泊，欣赏沿途自然风光和人文景观。途中有多个休息点和观景台，配备专业导游介绍当地生态和历史。提供自行车和安全装备，参与者需具备基本骑行能力。',
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
        price: 65,
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
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with TickerProviderStateMixin {
  // 页面动画控制器 - 与消息页面保持一致
  late AnimationController _animationController;
  late Animation<double> _contentAnimation;

  // 背景动画控制器 - 与消息页面保持一致
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

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

    // 初始化页面动画控制器 - 与消息页面保持一致
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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

    _scrollController.addListener(() {
      setState(() {
        _showBackToTopButton = _scrollController.offset >= 200;
      });
    });

    _loadActivities();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundAnimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // 加载活动数据
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 获取样例活动数据
    final mockActivities = Activity.getSampleActivities();

    setState(() {
      _activities.clear();
      _activities.addAll(mockActivities);
      _applyFilter(_currentFilter);
      _isLoading = false;
    });
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
    });
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
      body: Container(
        decoration: BoxDecoration(
          // 添加动态渐变背景，实现背景微动效果 - 参考成就页面
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
          ),
        ),
        child: Stack(
          children: [
            // 动态光晕效果 - 参考成就页面
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
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      top:
                          MediaQuery.of(context).size.height *
                          (0.3 +
                              0.2 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.neonPurple.withOpacity(0.4),
                              AppTheme.neonPurple.withOpacity(0.1),
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
                              AppTheme.neonBlue.withOpacity(0.3),
                              AppTheme.neonBlue.withOpacity(0.1),
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
                  child: Column(
                    children: [
                      // 顶部导航栏和过滤器
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Column(
                          children: [
                            // 返回按钮和标题
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 返回按钮
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor.withOpacity(
                                        0.4,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: AppTheme.primaryTextColor,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  padding: EdgeInsets.zero,
                                ),

                                // 中间标题
                                Text(
                                  '活动中心',
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                // 搜索按钮
                                IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.cardColor.withOpacity(
                                        0.4,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.search,
                                      color: AppTheme.primaryTextColor,
                                      size: 20,
                                    ),
                                  ),
                                  onPressed: () {
                                    // 搜索功能
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("搜索功能尚未实现"),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // 增大过滤选项栏 - 使其更符合截图样式
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF242539),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // 全部活动选项
                                  Expanded(
                                    child: _buildFilterOption(
                                      label: '全部活动',
                                      count: _activities.length,
                                      icon: Icons.all_inclusive,
                                      color: const Color(0xFF3A86FF),
                                    ),
                                  ),

                                  // 未开始
                                  Expanded(
                                    child: _buildFilterOption(
                                      label: '未开始',
                                      count:
                                          _activities
                                              .where((a) => a.status == '未开始')
                                              .length,
                                      icon: Icons.access_time,
                                      color: Colors.amber,
                                    ),
                                  ),

                                  // 进行中
                                  Expanded(
                                    child: _buildFilterOption(
                                      label: '进行中',
                                      count:
                                          _activities
                                              .where((a) => a.status == '进行中')
                                              .length,
                                      icon: Icons.play_circle_filled,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

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
                                            notification
                                                    .metrics
                                                    .maxScrollExtent -
                                                200 &&
                                        !_isLoadingMore &&
                                        _hasMoreData) {
                                      _loadMoreActivities();
                                    }
                                    return true;
                                  },
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      16,
                                      16,
                                      16,
                                    ),
                                    itemCount:
                                        _filteredActivities.length +
                                        (_hasMoreData ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < _filteredActivities.length) {
                                        return _buildActivityCard(
                                          _filteredActivities[index],
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
      ),
    );
  }

  // 构建新的过滤选项
  Widget _buildFilterOption({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _currentFilter == label;

    return GestureDetector(
      onTap: () => _applyFilter(label),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(isSelected ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            count > 0 ? '$label ($count)' : label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  // 构建活动卡片
  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF242539),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActivityDetails(context, activity),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 活动图片
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    // 占位图
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: activity.color.withOpacity(0.3),
                      child: Center(
                        child: Icon(
                          activity.icon,
                          size: 40,
                          color: activity.color.withOpacity(0.7),
                        ),
                      ),
                    ),
                    // 状态标签
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 注册状态
                    if (activity.isRegistered)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "已报名",
                                style: TextStyle(
                                  color: Colors.white,
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

              // 活动内容
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 活动标题
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // 活动时间和地点
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.getFormattedDate(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.location,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 活动标签
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          activity.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: activity.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: activity.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // 底部状态栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 价格
                        Text(
                          activity.price > 0
                              ? "¥${activity.price.toInt()}"
                              : "免费",
                          style: TextStyle(
                            color:
                                activity.price > 0
                                    ? AppTheme.neonYellow
                                    : AppTheme.neonGreen,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // 参与人数
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${activity.participantsCount}人参加",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 显示活动详情
  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // 顶部拖动条
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // 活动图片
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          activity.icon,
                          size: 60,
                          color: activity.color.withOpacity(0.7),
                        ),
                      ),
                      // 状态标签
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
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
                                style: const TextStyle(
                                  color: Colors.white,
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

                // 活动内容
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 活动标题
                          Text(
                            activity.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 价格标签
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  activity.price > 0
                                      ? AppTheme.neonYellow.withOpacity(0.1)
                                      : AppTheme.neonGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              activity.price > 0
                                  ? "¥${activity.price.toInt()}/人"
                                  : "免费活动",
                              style: TextStyle(
                                color:
                                    activity.price > 0
                                        ? AppTheme.neonYellow
                                        : AppTheme.neonGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 活动基本信息卡片
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242539),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  icon: Icons.access_time,
                                  title: "活动时间",
                                  content: activity.getFormattedDate(),
                                ),
                                const Divider(
                                  color: Color(0xFF353750),
                                  height: 24,
                                ),
                                _buildInfoRow(
                                  icon: Icons.location_on,
                                  title: "活动地点",
                                  content: activity.location,
                                ),
                                const Divider(
                                  color: Color(0xFF353750),
                                  height: 24,
                                ),
                                _buildInfoRow(
                                  icon: Icons.people,
                                  title: "参与人数",
                                  content:
                                      "${activity.participantsCount}/${activity.maxParticipants}人",
                                ),
                                const Divider(
                                  color: Color(0xFF353750),
                                  height: 24,
                                ),
                                _buildInfoRow(
                                  icon: Icons.business,
                                  title: "组织者",
                                  content: activity.organizer,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 活动描述
                          const Text(
                            "活动详情",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242539),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              activity.description,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 活动标签
                          const Text(
                            "活动标签",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                activity.tags.map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: activity.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: activity.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        color: activity.color,
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                // 底部按钮
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 分享按钮
                      IconButton(
                        onPressed: () {
                          // 分享功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("分享功能尚未实现"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share, color: Colors.white70),
                      ),
                      // 收藏按钮
                      IconButton(
                        onPressed: () {
                          // 收藏功能
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("收藏功能尚未实现"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 主按钮
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              activity.status == "已结束"
                                  ? null
                                  : () {
                                    Navigator.of(context).pop();
                                    // 报名/取消报名功能
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          activity.isRegistered
                                              ? "取消报名功能尚未实现"
                                              : "报名功能尚未实现",
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                activity.isRegistered
                                    ? Colors.red.shade700
                                    : AppTheme.neonPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            activity.isRegistered
                                ? "取消报名"
                                : (activity.status == "已结束" ? "活动已结束" : "立即报名"),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

  // 构建信息行
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.neonPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.neonPurple, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
