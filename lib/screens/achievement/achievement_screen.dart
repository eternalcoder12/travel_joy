import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/models/achievement_model.dart';
import 'dart:math' as math;

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  // 原有的滑动动画控制器升级，改为与消息页面保持一致
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
  bool _isScrollable = false; // 内容是否能够滚动

  // 数据变量
  List<Achievement> _achievements = [];
  List<Achievement> _filteredAchievements = [];
  String _currentFilter = "全部成就";
  int _currentPage = 1;

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

    _loadAchievements();
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

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _hasMoreData = true;
      _isScrollable = false;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 获取样例成就数据
    final mockAchievements = Achievement.getSampleAchievements();

    setState(() {
      _achievements.clear();
      _achievements.addAll(mockAchievements);
      _applyFilter(_currentFilter);
      _isLoading = false;

      // 延迟检查是否内容可滚动
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          setState(() {
            _isScrollable = true;
          });
        }
      });
    });
  }

  Future<void> _loadMoreAchievements() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // 模拟获取更多数据
    // 每次加载10个新成就
    final moreAchievements =
        Achievement.getSampleAchievements().take(10).toList();

    // 模拟加载完所有数据的情况
    if (_currentPage >= 3) {
      setState(() {
        _hasMoreData = false;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      _achievements.addAll(moreAchievements);
      _currentPage++;
      _isLoadingMore = false;
      _applyFilter(_currentFilter);
    });
  }

  // 应用筛选
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _currentPage = 1;
      _hasMoreData = true;
      _isScrollable = false;

      if (filter == "全部成就") {
        _filteredAchievements = List.from(_achievements);
      } else if (filter == "已解锁") {
        _filteredAchievements =
            _achievements
                .where((achievement) => achievement.isUnlocked)
                .toList();
      } else if (filter == "未解锁") {
        _filteredAchievements =
            _achievements
                .where((achievement) => !achievement.isUnlocked)
                .toList();
      }
    });
  }

  // 获取已解锁成就数量
  int get _unlockedCount {
    return _achievements.where((achievement) => achievement.isUnlocked).length;
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
                                  '成就中心',
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
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF242539),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // 全部成就选项
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _applyFilter("全部成就"),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF3A86FF,
                                              ).withOpacity(
                                                _currentFilter == "全部成就"
                                                    ? 0.3
                                                    : 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.all_inclusive,
                                              color: Color(0xFF3A86FF),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '全部 (${_achievements.length})',
                                            style: TextStyle(
                                              color:
                                                  _currentFilter == "全部成就"
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                              fontSize: 14,
                                              fontWeight:
                                                  _currentFilter == "全部成就"
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

                                  // 已解锁成就
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _applyFilter("已解锁"),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0396BA,
                                              ).withOpacity(
                                                _currentFilter == "已解锁"
                                                    ? 0.3
                                                    : 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.emoji_events,
                                              color: Color(0xFF0396BA),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$_unlockedCount个已解锁',
                                            style: TextStyle(
                                              color:
                                                  _currentFilter == "已解锁"
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                              fontSize: 14,
                                              fontWeight:
                                                  _currentFilter == "已解锁"
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

                                  // 未解锁成就
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _applyFilter("未解锁"),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF9D4EDD,
                                              ).withOpacity(
                                                _currentFilter == "未解锁"
                                                    ? 0.3
                                                    : 0.15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.lock_outline,
                                              color: Color(0xFF9D4EDD),
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${_achievements.length - _unlockedCount}个待解锁',
                                            style: TextStyle(
                                              color:
                                                  _currentFilter == "未解锁"
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                              fontSize: 14,
                                              fontWeight:
                                                  _currentFilter == "未解锁"
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

                      // 成就列表
                      Expanded(
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.neonYellow,
                                  ),
                                )
                                : _filteredAchievements.isEmpty
                                ? const Center(
                                  child: Text(
                                    "暂无成就",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                                : NotificationListener<ScrollNotification>(
                                  onNotification: (
                                    ScrollNotification notification,
                                  ) {
                                    // 检测内容是否可滚动
                                    if (notification
                                        is ScrollUpdateNotification) {
                                      // 如果内容可滚动但状态未更新
                                      if (notification.metrics.maxScrollExtent >
                                              0 &&
                                          !_isScrollable) {
                                        setState(() {
                                          _isScrollable = true;
                                        });
                                      }

                                      // 当滚动到底部附近时加载更多
                                      if (_isScrollable &&
                                          notification.metrics.pixels >=
                                              notification
                                                      .metrics
                                                      .maxScrollExtent -
                                                  200 &&
                                          !_isLoadingMore &&
                                          _hasMoreData) {
                                        _loadMoreAchievements();
                                      }
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
                                        _filteredAchievements.length +
                                        (_isScrollable && _hasMoreData ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index <
                                          _filteredAchievements.length) {
                                        return _buildAchievementCard(
                                          _filteredAchievements[index],
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

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonYellow),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final progress = achievement.currentProgress;
    final maxProgress = achievement.maxProgress;
    final progressPercent = progress / maxProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242539),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showAchievementDetails(context, achievement),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部内容：图标、标题和进度指示器
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 左侧图标
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: achievement.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        achievement.icon,
                        color: achievement.color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 中间内容区
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题和状态标签
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  achievement.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      achievement.isUnlocked
                                          ? const Color(
                                            0xFF2F9E44,
                                          ).withOpacity(0.2)
                                          : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  achievement.isUnlocked
                                      ? "已解锁"
                                      : "${(progressPercent * 100).toInt()}%",
                                  style: TextStyle(
                                    color:
                                        achievement.isUnlocked
                                            ? const Color(0xFF2F9E44)
                                            : Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // 描述
                          Text(
                            achievement.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 进度条和进度文本
                          Stack(
                            children: [
                              // 进度条
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: progressPercent,
                                  backgroundColor: const Color(0xFF1A1B2E),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    achievement.color,
                                  ),
                                  minHeight: 8,
                                ),
                              ),

                              // 详情按钮(放在进度条下方，通过Positioned来定位)
                              Positioned(
                                right: 0,
                                bottom: 20,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: TextButton(
                                    onPressed:
                                        () => _showAchievementDetails(
                                          context,
                                          achievement,
                                        ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      backgroundColor: achievement.color
                                          .withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "详情",
                                          style: TextStyle(
                                            color: achievement.color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          size: 14,
                                          color: achievement.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 进度文本
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "$progress/$maxProgress",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
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

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    final progress = achievement.currentProgress;
    final maxProgress = achievement.maxProgress;
    final progressPercent = progress / maxProgress;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.75,
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

                // 成就头部信息
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      // 成就图标
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: achievement.color.withOpacity(0.15),
                        ),
                        child: Icon(
                          achievement.icon,
                          color: achievement.color,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 成就名称和状态
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievement.name,
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
                                color:
                                    achievement.isUnlocked
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                achievement.isUnlocked
                                    ? "已解锁"
                                    : "${(progressPercent * 100).toInt()}% 完成",
                                style: TextStyle(
                                  color:
                                      achievement.isUnlocked
                                          ? Colors.green
                                          : Colors.grey,
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

                // 进度条
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          backgroundColor: const Color(0xFF1E1E1E),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.color,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$progress/$maxProgress",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // 分隔线
                Container(
                  height: 1,
                  width: double.infinity,
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
                          // 成就描述卡片
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: achievement.color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: achievement.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "成就描述",
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
                                  achievement.description,
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

                          // 成就信息卡片
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category_outlined,
                                      color: Colors.white.withOpacity(0.7),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "基本信息",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSimpleInfoRow(
                                  title: "成就类型",
                                  value: _getAchievementType(achievement),
                                ),
                                if (achievement.isUnlocked &&
                                    achievement.unlockedDate != null)
                                  _buildSimpleInfoRow(
                                    title: "解锁时间",
                                    value: _formatDate(
                                      achievement.unlockedDate!,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (_achievements
                              .where((a) => a.id != achievement.id)
                              .isNotEmpty) ...[
                            const SizedBox(height: 16),
                            // 相关成就标题
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 8,
                              ),
                              child: Text(
                                "相关成就",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // 相关成就列表
                            ..._buildSimpleRelatedAchievements(achievement),
                          ],
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
                      // 分享按钮
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            // 这里可以实现分享功能
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("分享功能尚未实现"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: achievement.color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("分享成就"),
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

  // 简化的信息行
  Widget _buildSimpleInfoRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 简化的相关成就
  List<Widget> _buildSimpleRelatedAchievements(Achievement currentAchievement) {
    // 获取两个相关成就
    final relatedAchievements =
        _achievements
            .where((a) => a.id != currentAchievement.id)
            .take(2)
            .toList();

    return relatedAchievements.map((achievement) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 300), () {
              _showAchievementDetails(context, achievement);
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: achievement.color.withOpacity(0.15),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: achievement.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value:
                              achievement.currentProgress /
                              achievement.maxProgress,
                          backgroundColor: const Color(0xFF2A2A2A),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            achievement.color.withOpacity(0.7),
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        achievement.isUnlocked
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    achievement.isUnlocked
                        ? "已解锁"
                        : "${(achievement.currentProgress / achievement.maxProgress * 100).toInt()}%",
                    style: TextStyle(
                      color:
                          achievement.isUnlocked ? Colors.green : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // 格式化日期
  String _formatDate(DateTime date) {
    return "${date.year}年${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日";
  }

  // 获取成就类型
  String _getAchievementType(Achievement achievement) {
    if (achievement.icon == Icons.flight_takeoff) {
      return "旅行成就";
    } else if (achievement.icon == Icons.camera_alt) {
      return "摄影成就";
    } else if (achievement.icon == Icons.restaurant) {
      return "美食成就";
    } else if (achievement.icon == Icons.nature_people) {
      return "探险成就";
    } else if (achievement.icon == Icons.casino) {
      return "挑战成就";
    } else if (achievement.icon == Icons.emoji_events) {
      return "特殊成就";
    }
    return "其他成就";
  }
}
