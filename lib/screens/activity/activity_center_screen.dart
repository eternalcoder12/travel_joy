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
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];

  bool _showBackToTopButton = false;
  bool _isLoading = true;
  String _searchQuery = "";

  // 筛选状态
  String _currentFilter = "全部";

  // 活动类型标签
  final List<String> _activityTags = [
    "全部",
    "热门",
    "最新",
    "免费",
    "户外",
    "文化",
    "美食",
    "艺术",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
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
    _searchController.dispose();
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

    setState(() {
      _activities.clear();
      _activities.addAll(Activity.getSampleActivities());
      _applyFilter(_currentFilter);
      _isLoading = false;
    });
  }

  // 应用筛选和搜索
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;

      // 先根据搜索关键词筛选
      List<Activity> searchResults =
          _searchQuery.isEmpty
              ? List.from(_activities)
              : _activities.where((activity) {
                return activity.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    activity.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    activity.location.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    activity.tags.any(
                      (tag) => tag.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    );
              }).toList();

      // 再根据标签筛选
      if (filter == "全部") {
        _filteredActivities = searchResults;
      } else if (filter == "热门") {
        _filteredActivities =
            searchResults.where((activity) => activity.isHot).toList();
      } else if (filter == "最新") {
        _filteredActivities =
            searchResults.where((activity) => activity.isNew).toList();
      } else if (filter == "免费") {
        _filteredActivities =
            searchResults.where((activity) => activity.price == 0).toList();
      } else {
        // 其他标签按照活动标签列表筛选
        _filteredActivities =
            searchResults
                .where(
                  (activity) => activity.tags.any(
                    (tag) => tag.toLowerCase() == filter.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  // 搜索活动
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilter(_currentFilter);
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.neonYellow,
          onRefresh: () async {
            await _loadActivities();
          },
          child: Column(
            children: [
              // 顶部标题栏
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
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

                    // 右侧的我的活动按钮
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: AppTheme.primaryTextColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        // 导航到我的活动页面
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('我的活动功能尚未实现'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              // 搜索栏
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '搜索活动',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
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

              // 活动标签筛选
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _activityTags.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final tag = _activityTags[index];
                    final isSelected = _currentFilter == tag;

                    return GestureDetector(
                      onTap: () => _applyFilter(tag),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppTheme.buttonColor
                                  : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
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
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 80,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "没有找到相关活动",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: _buildActivityCard(
                                  _filteredActivities[index],
                                ),
                              ),
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

  // 构建活动卡片
  Widget _buildActivityCard(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showActivityDetails(activity),
            splashColor: activity.color.withOpacity(0.1),
            highlightColor: activity.color.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 活动图片和标签
                Stack(
                  children: [
                    // 图片
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: activity.color.withOpacity(0.3),
                          image: DecorationImage(
                            image: AssetImage(activity.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // 活动状态标签
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activity.isFinished
                                  ? Icons.event_busy
                                  : activity.isOngoing
                                  ? Icons.event_available
                                  : Icons.event_note,
                              color: activity.statusColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              activity.statusText,
                              style: TextStyle(
                                color: activity.statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 热门或新活动标签
                    if (activity.isHot || activity.isNew)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                activity.isHot
                                    ? const Color(0xFFE63946).withOpacity(
                                      0.9,
                                    ) // 热门标签红色
                                    : const Color(
                                      0xFF00B4D8,
                                    ).withOpacity(0.9), // 新活动标签蓝色
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            activity.isHot ? '热门' : '新活动',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // 价格标签
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              activity.price == 0
                                  ? const Color(0xFF4CAF50).withOpacity(
                                    0.9,
                                  ) // 免费绿色
                                  : AppTheme.buttonColor.withOpacity(
                                    0.9,
                                  ), // 收费蓝色
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity.price == 0
                              ? '免费'
                              : '¥${activity.price.toInt()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 活动内容
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 活动标题和图标
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: activity.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              activity.icon,
                              color: activity.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 活动描述
                      Text(
                        activity.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // 活动信息行
                      Row(
                        children: [
                          // 位置
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activity.location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          const Spacer(),

                          // 参与人数
                          Row(
                            children: [
                              Icon(
                                Icons.people,
                                color: Colors.white.withOpacity(0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${activity.participantsCount}/${activity.maxParticipants}人",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),

                              // 满员标志
                              if (activity.isFull)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "已满",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 活动时间和详情按钮
                      Row(
                        children: [
                          // 时间
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _formatDate(
                                      activity.startDate,
                                      activity.endDate,
                                    ),
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
                          ),

                          // 详情按钮
                          TextButton(
                            onPressed: () => _showActivityDetails(activity),
                            style: TextButton.styleFrom(
                              foregroundColor: activity.color,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: activity.color.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "详情",
                                  style: TextStyle(
                                    color: activity.color,
                                    fontSize: 12,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: activity.color,
                                  size: 16,
                                ),
                              ],
                            ),
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
      ),
    );
  }

  // 显示活动详情
  void _showActivityDetails(Activity activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看活动: ${activity.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
    // 这里可以实现导航到活动详情页面
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => ActivityDetailScreen(activity: activity),
    //   ),
    // );
  }

  // 格式化日期
  String _formatDate(DateTime startDate, DateTime endDate) {
    final isSameDay =
        startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;

    final startDateStr = "${startDate.month}月${startDate.day}日";

    if (isSameDay) {
      return "$startDateStr · ${startDate.hour}:${startDate.minute.toString().padLeft(2, '0')}-${endDate.hour}:${endDate.minute.toString().padLeft(2, '0')}";
    } else {
      final endDateStr = "${endDate.month}月${endDate.day}日";
      return "$startDateStr - $endDateStr";
    }
  }
}
