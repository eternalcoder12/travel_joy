import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/models/activity_model.dart';

class ActivityCenterScreen extends StatefulWidget {
  const ActivityCenterScreen({Key? key}) : super(key: key);

  @override
  State<ActivityCenterScreen> createState() => _ActivityCenterScreenState();
}

class _ActivityCenterScreenState extends State<ActivityCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _screenFadeAnimation;
  late Animation<Offset> _screenSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  final List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];

  bool _showBackToTopButton = false;
  bool _isLoading = true;

  // 筛选状态
  String _currentFilter = "全部活动";

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _screenFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _screenSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
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

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 获取样例活动数据
    final sampleActivities = Activity.getSampleActivities();

    setState(() {
      _activities.clear();
      _activities.addAll(sampleActivities);
      _applyFilter(_currentFilter);
      _isLoading = false;
    });
  }

  // 应用筛选
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;

      if (filter == "全部活动") {
        _filteredActivities = List.from(_activities);
      } else if (filter == "即将开始") {
        _filteredActivities =
            _activities.where((activity) => activity.isUpcoming).toList();
      } else if (filter == "进行中") {
        _filteredActivities =
            _activities.where((activity) => activity.isOngoing).toList();
      } else if (filter == "已结束") {
        _filteredActivities =
            _activities.where((activity) => activity.isPast).toList();
      } else if (filter == "已报名") {
        _filteredActivities =
            _activities.where((activity) => activity.isRegistered).toList();
      }
    });
  }

  // 获取即将开始的活动数量
  int get _upcomingCount {
    return _activities.where((activity) => activity.isUpcoming).length;
  }

  // 获取进行中的活动数量
  int get _ongoingCount {
    return _activities.where((activity) => activity.isOngoing).length;
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.neonYellow,
          onRefresh: () async {
            await _loadActivities();
          },
          child: Column(
            children: [
              // 顶部导航栏和统计信息
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
                              color: AppTheme.cardColor.withOpacity(0.4),
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

                        // 保持对称的空白区域
                        SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 统计信息卡片
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242539),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // 即将开始的活动
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyFilter("即将开始"),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF00B4D8,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.event_upcoming,
                                      color: Color(0xFF00B4D8),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_upcomingCount个即将开始',
                                    style: TextStyle(
                                      color:
                                          _currentFilter == "即将开始"
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight:
                                          _currentFilter == "即将开始"
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 分隔线
                          Container(
                            height: 20,
                            width: 1,
                            color: Colors.white.withOpacity(0.1),
                          ),

                          // 进行中的活动
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyFilter("进行中"),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF9D4EDD,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.event_available,
                                      color: Color(0xFF9D4EDD),
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_ongoingCount个进行中',
                                    style: TextStyle(
                                      color:
                                          _currentFilter == "进行中"
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight:
                                          _currentFilter == "进行中"
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 筛选标签
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: "全部活动",
                        isSelected: _currentFilter == "全部活动",
                        onTap: () => _applyFilter("全部活动"),
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        label: "已报名",
                        isSelected: _currentFilter == "已报名",
                        onTap: () => _applyFilter("已报名"),
                        iconData: Icons.how_to_reg,
                      ),
                      const SizedBox(width: 12),
                      _buildFilterChip(
                        label: "已结束",
                        isSelected: _currentFilter == "已结束",
                        onTap: () => _applyFilter("已结束"),
                        iconData: Icons.event_busy,
                      ),
                    ],
                  ),
                ),
              ),

              // 活动列表
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.neonYellow,
                          ),
                        )
                        : _filteredActivities.isEmpty
                        ? const Center(
                          child: Text(
                            "暂无活动",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(
                              _filteredActivities[index],
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? iconData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonYellow : const Color(0xFF242539),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 16,
                color: isSelected ? Colors.black : Colors.white70,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242539),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActivityDetails(context, activity),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行: 图标、标题和状态
                Row(
                  children: [
                    // 活动图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: activity.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        activity.icon,
                        color: activity.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 活动名称
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            activity.organizer,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 活动状态
                    _buildActivityStatusBadge(activity),
                  ],
                ),

                const SizedBox(height: 12),

                // 活动描述 (最多显示2行)
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 12),

                // 标签栏
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...activity.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 12),

                // 底部信息栏: 地点、时间和按钮
                Row(
                  children: [
                    // 地点和时间
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  activity.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 14,
                                color: Colors.white.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatActivityTime(activity),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 详情或报名按钮
                    _buildActivityActionButton(activity),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建活动状态标签
  Widget _buildActivityStatusBadge(Activity activity) {
    // 根据活动状态决定颜色和文本
    late Color badgeColor;
    late String statusText;

    if (activity.isHot) {
      badgeColor = Colors.red;
      statusText = "热门";
    } else if (activity.isRegistered) {
      badgeColor = Colors.green;
      statusText = "已报名";
    } else if (activity.isFull) {
      badgeColor = Colors.grey;
      statusText = "已满";
    } else if (activity.isOngoing) {
      badgeColor = AppTheme.neonPurple;
      statusText = "进行中";
    } else if (activity.isPast) {
      badgeColor = Colors.grey;
      statusText = "已结束";
    } else {
      badgeColor = AppTheme.neonBlue;
      statusText = "即将开始";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 构建活动操作按钮
  Widget _buildActivityActionButton(Activity activity) {
    // 根据活动和用户状态显示不同的按钮
    if (activity.isPast) {
      // 已结束的活动
      return TextButton(
        onPressed: () => _showActivityDetails(context, activity),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
        ),
        child: const Text(
          "查看详情",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    } else if (activity.isRegistered) {
      // 已报名的活动
      return TextButton(
        onPressed: () => _showActivityDetails(context, activity),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.green.withOpacity(0.5), width: 1),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("已报名", style: TextStyle(color: Colors.green, fontSize: 12)),
            Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
          ],
        ),
      );
    } else if (activity.canRegister) {
      // 可以报名的活动
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已报名：${activity.title}'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: activity.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("立即报名", style: TextStyle(fontSize: 12)),
      );
    } else {
      // 其他情况 (如已满员)
      return TextButton(
        onPressed: () => _showActivityDetails(context, activity),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: activity.color.withOpacity(0.5), width: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("详情", style: TextStyle(color: activity.color, fontSize: 12)),
            Icon(Icons.chevron_right, size: 14, color: activity.color),
          ],
        ),
      );
    }
  }

  // 格式化活动时间
  String _formatActivityTime(Activity activity) {
    // 格式化日期
    String formatDate(DateTime date) {
      return "${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    if (activity.isPast) {
      return "已结束";
    } else if (activity.isOngoing) {
      return "进行中至${formatDate(activity.endDate)}";
    } else {
      return formatDate(activity.startDate);
    }
  }

  void _showActivityDetails(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Color(0xFF121212), // 更深的背景色
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

                // 活动头部信息
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      // 活动图标
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

                      // 活动名称和状态
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
                            Row(
                              children: [
                                _buildActivityStatusBadge(activity),
                                const SizedBox(width: 8),
                                if (activity.rating != null) ...[
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${activity.rating}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 分隔线
                Container(
                  height: 1,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.white.withOpacity(0.05),
                ),

                // 主内容
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 活动信息卡片
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 活动信息标题
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "活动信息",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 活动信息内容
                                _buildInfoRow(
                                  icon: Icons.schedule,
                                  title: "活动时间",
                                  content: _formatFullActivityTime(activity),
                                ),
                                _buildInfoRow(
                                  icon: Icons.location_on,
                                  title: "活动地点",
                                  content: activity.location,
                                ),
                                _buildInfoRow(
                                  icon: Icons.groups,
                                  title: "参与人数",
                                  content:
                                      "${activity.participantsCount}/${activity.maxParticipants}人",
                                ),
                                _buildInfoRow(
                                  icon: Icons.corporate_fare,
                                  title: "组织方",
                                  content: activity.organizer,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 活动描述卡片
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: activity.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: activity.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "活动详情",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  activity.description,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 活动标签
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "活动标签",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
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
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: activity.color,
                                              fontSize: 12,
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

                // 底部按钮
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 关闭按钮
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF1E1E1E),
                            foregroundColor: Colors.white.withOpacity(0.7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("关闭"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 报名或分享按钮
                      Expanded(
                        flex: 2,
                        child:
                            activity.isRegistered
                                ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("将打开活动详情页面"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("查看详情"),
                                )
                                : activity.canRegister
                                ? ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('已报名：${activity.title}'),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: activity.color,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("立即报名"),
                                )
                                : ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("分享功能尚未实现"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        activity.isPast
                                            ? Colors.grey
                                            : activity.color,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("分享活动"),
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

  // 信息行组件
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 完整格式化活动时间
  String _formatFullActivityTime(Activity activity) {
    // 格式化日期
    String formatDateTime(DateTime date) {
      return "${date.year}年${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }

    return "${formatDateTime(activity.startDate)} - ${formatDateTime(activity.endDate)}";
  }
}
