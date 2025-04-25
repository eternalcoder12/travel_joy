import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/travel_timeline.dart';
import 'package:travel_joy/utils/navigation_utils.dart';
import 'dart:math' as math;

class TravelTimelineScreen extends StatefulWidget {
  final List<TravelEvent> events;

  const TravelTimelineScreen({Key? key, required this.events})
    : super(key: key);

  @override
  State<TravelTimelineScreen> createState() => _TravelTimelineScreenState();
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
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _backgroundAnimController.dispose();
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
              color: AppTheme.cardColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryTextColor,
              size: 20,
            ),
          ),
          onPressed: () {
            // 使用 NavigationUtils 而不是直接的 Navigator.pop
            Navigator.of(context).pop();
          },
        ),
      ),
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
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.1,
                              ),
                            ),

                            // 国家统计
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonPurple.withOpacity(
                                        0.1,
                                      ),
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
                                    '${_countCountries()}个国家',
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

                      // 时间线内容 - 优化边距为填满
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: TravelTimeline(
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
  int _countCountries() {
    final countries =
        widget.events
            .where((event) => event.country != null)
            .map((event) => event.country)
            .toSet();
    return countries.length;
  }
}
