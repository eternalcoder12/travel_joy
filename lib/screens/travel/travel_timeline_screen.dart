import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/travel_timeline.dart';
import 'dart:math' as math;

class TravelTimelineScreen extends StatefulWidget {
  final List<TimelineTravelEvent> events;

  const TravelTimelineScreen({Key? key, required this.events})
    : super(key: key);

  @override
  _TravelTimelineScreenState createState() => _TravelTimelineScreenState();
}

class _TravelTimelineScreenState extends State<TravelTimelineScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  // 新增动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 新增背景动画控制器
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 动画控制器
  late AnimationController _fadeController;

  // 动画
  late Animation<double> _fadeAnimation;

  // 筛选选项
  String _selectedYear = "全部";
  String _selectedCountry = "全部";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // 初始化动画控制器，与消息页面保持一致
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动动画
    _animationController.forward();

    // 初始化动画控制器
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    // 启动动画
    _fadeController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _backgroundAnimController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 显示或隐藏返回顶部按钮，当滚动位置超过200
    if (_scrollController.offset > 200 && !_showBackToTop) {
      setState(() {
        _showBackToTop = true;
      });
    } else if (_scrollController.offset <= 200 && _showBackToTop) {
      setState(() {
        _showBackToTop = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 不再筛选事件，直接使用所有事件
    final allEvents = widget.events;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          '旅行足迹',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryTextColor,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // 移除筛选按钮
        ],
      ),
      body: Stack(
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
                                math.sin(_backgroundAnimation.value * math.pi)),
                    top:
                        MediaQuery.of(context).size.height *
                        (0.3 +
                            0.2 *
                                math.cos(_backgroundAnimation.value * math.pi)),
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

          // 页面主体内容，应用淡入+滑动动画效果
          FadeTransition(
            opacity: _animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(_animation),
              child: SafeArea(
                child: Column(
                  children: [
                    // 顶部简洁信息 - 优化设计和间距
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          width: 1.0,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.cardColor.withOpacity(0.9),
                            AppTheme.cardColor.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // 城市统计
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonBlue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_city,
                                    color: AppTheme.neonBlue,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.events.length}个城市',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryTextColor
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 分隔线
                          Container(
                            height: 20,
                            width: 1,
                            color: AppTheme.secondaryTextColor.withOpacity(0.1),
                          ),

                          // 国家统计
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonPurple.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.public,
                                    color: AppTheme.neonPurple,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_countCountries(widget.events)}个国家',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryTextColor
                                        .withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 显示当前筛选状态
                    if (_selectedYear != "全部" || _selectedCountry != "全部")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (_selectedYear != "全部")
                                _buildFilterChip(
                                  label: '$_selectedYear年',
                                  onDeleted: () {
                                    setState(() {
                                      _selectedYear = "全部";
                                    });
                                  },
                                ),
                              if (_selectedCountry != "全部")
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _buildFilterChip(
                                    label: _selectedCountry,
                                    onDeleted: () {
                                      setState(() {
                                        _selectedCountry = "全部";
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    // 统计信息
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          color: AppTheme.cardColor.withOpacity(0.5),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '旅行统计',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      icon: Icons.location_on,
                                      label: '地点',
                                      value:
                                          _getUniqueLocations(
                                            widget.events,
                                          ).length.toString(),
                                      color: AppTheme.neonBlue,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.public,
                                      label: '国家',
                                      value:
                                          _getUniqueCountries(
                                            widget.events,
                                          ).length.toString(),
                                      color: AppTheme.neonPurple,
                                    ),
                                    _buildStatItem(
                                      icon: Icons.event,
                                      label: '旅行',
                                      value: widget.events.length.toString(),
                                      color: AppTheme.neonOrange,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 时间线内容 - 优化边距为填满
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child:
                            widget.events.isEmpty
                                ? _buildEmptyState()
                                : TravelTimeline(
                                  events: widget.events,
                                  scrollController: _scrollController,
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
      // 返回顶部按钮，只有滚动超过阈值时显示
      floatingActionButton:
          _showBackToTop
              ? FloatingActionButton(
                backgroundColor: AppTheme.buttonColor.withOpacity(0.8),
                mini: true,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                onPressed: _scrollToTop,
              )
              : null,
    );
  }

  // 计算国家数量
  int _countCountries(List<TimelineTravelEvent> events) {
    return _getUniqueCountries(events).length;
  }

  // 获取唯一的国家列表
  List<String> _getUniqueCountries(List<TimelineTravelEvent> events) {
    return events
        .where((e) => e.country != null)
        .map((e) => e.country!)
        .toSet()
        .toList();
  }

  // 获取唯一的地点列表
  List<String> _getUniqueLocations(List<TimelineTravelEvent> events) {
    return events.map((e) => e.location).toSet().toList();
  }

  // 构建空状态视图
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            '没有旅行记录',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '快来记录你的第一次旅行吧',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 构建统计项目
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  // 构建筛选选项卡
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: Icon(
                Icons.close,
                size: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
