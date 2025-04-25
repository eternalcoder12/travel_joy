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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _screenFadeAnimation;
  late Animation<Offset> _screenSlideAnimation;

  final ScrollController _scrollController = ScrollController();
  final List<Achievement> _achievements = [];
  List<Achievement> _filteredAchievements = [];

  bool _showBackToTopButton = false;
  bool _isLoading = true;

  // 筛选状态
  String _currentFilter = "全部成就";

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

    _loadAchievements();
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

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(seconds: 1));

    // 假数据
    final mockAchievements = [
      Achievement(
        id: "1",
        icon: Icons.flight_takeoff,
        name: "初次启程",
        description: "完成你的第一次旅行",
        isUnlocked: true,
        currentProgress: 1,
        maxProgress: 1,
        color: const Color(0xFF00B4D8), // neonBlue
      ),
      Achievement(
        id: "2",
        icon: Icons.photo_camera,
        name: "摄影达人",
        description: "在旅行中拍摄并上传10张照片",
        isUnlocked: true,
        currentProgress: 10,
        maxProgress: 10,
        color: const Color(0xFF9D4EDD), // neonPurple
      ),
      Achievement(
        id: "3",
        icon: Icons.route,
        name: "环球旅行家",
        description: "访问5个不同的国家",
        isUnlocked: true,
        currentProgress: 5,
        maxProgress: 5,
        color: const Color(0xFFFF48C4), // neonPink
      ),
      Achievement(
        id: "4",
        icon: Icons.hiking,
        name: "探险家",
        description: "完成一次徒步旅行",
        isUnlocked: false,
        currentProgress: 0,
        maxProgress: 1,
        color: const Color(0xFF39D353), // neonGreen
      ),
      Achievement(
        id: "5",
        icon: Icons.star,
        name: "超级旅行者",
        description: "获得10个好评",
        isUnlocked: false,
        currentProgress: 3,
        maxProgress: 10,
        color: const Color(0xFFFFD700), // neonYellow
      ),
      Achievement(
        id: "6",
        icon: Icons.hotel,
        name: "舒适住宿",
        description: "在5星级酒店住宿",
        isUnlocked: false,
        currentProgress: 0,
        maxProgress: 1,
        color: const Color(0xFF2EC4B6), // neonTeal
      ),
      Achievement(
        id: "7",
        icon: Icons.movie,
        name: "旅行记录者",
        description: "创建并分享一个旅行视频",
        isUnlocked: false,
        currentProgress: 0,
        maxProgress: 1,
        color: const Color(0xFFFF9E00), // neonOrange
      ),
      Achievement(
        id: "8",
        icon: Icons.local_dining,
        name: "美食家",
        description: "尝试10种不同国家的美食",
        isUnlocked: false,
        currentProgress: 2,
        maxProgress: 10,
        color: const Color(0xFFE63946), // neonRed
      ),
    ];

    setState(() {
      _achievements.clear();
      _achievements.addAll(mockAchievements);
      _applyFilter(_currentFilter);
      _isLoading = false;
    });
  }

  // 应用筛选
  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;

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

  // 计算完成率
  double get _completionRate {
    if (_achievements.isEmpty) return 0.0;
    final unlockedCount =
        _achievements.where((achievement) => achievement.isUnlocked).length;
    return unlockedCount / _achievements.length;
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
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.neonYellow,
          onRefresh: () async {
            await _loadAchievements();
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
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242539),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // 已解锁成就
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyFilter("已解锁"),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF0396BA,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
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
                                              : Colors.white.withOpacity(0.7),
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
                                              : Colors.white.withOpacity(0.7),
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
                        : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          itemCount: _filteredAchievements.length,
                          itemBuilder: (context, index) {
                            return _buildAchievementCard(
                              _filteredAchievements[index],
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
                // 图标、标题和状态
                Row(
                  children: [
                    // 成就图标
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: achievement.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        achievement.icon,
                        color: achievement.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 成就名称
                    Expanded(
                      child: Text(
                        achievement.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 解锁状态或进度百分比
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            achievement.isUnlocked
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        achievement.isUnlocked
                            ? "已解锁"
                            : "${(progressPercent * 100).toInt()}%",
                        style: TextStyle(
                          color:
                              achievement.isUnlocked
                                  ? Colors.green
                                  : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 成就描述
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                // 进度条和详情按钮
                Row(
                  children: [
                    // 进度条
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercent,
                              backgroundColor: const Color(0xFF1A1B2E),
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
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 详情按钮
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      child: TextButton(
                        onPressed:
                            () => _showAchievementDetails(context, achievement),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: achievement.color.withOpacity(0.5),
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
    } else if (achievement.icon == Icons.photo_camera) {
      return "摄影成就";
    } else if (achievement.icon == Icons.route) {
      return "探索成就";
    } else if (achievement.icon == Icons.star) {
      return "社交成就";
    } else if (achievement.icon == Icons.hotel) {
      return "住宿成就";
    } else if (achievement.icon == Icons.local_dining) {
      return "美食成就";
    } else {
      return "常规成就";
    }
  }
}
