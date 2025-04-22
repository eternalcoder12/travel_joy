import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _currentPage = 0;
  bool _isLastPageAnimated = false;

  // 引导页内容
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.travel_explore,
      'title': '探索小众景点',
      'description': '发现鲜为人知的绝美目的地\n体验独特的旅行路线',
      'color': AppTheme.neonPurple,
    },
    {
      'icon': Icons.emoji_events,
      'title': '旅行成就系统',
      'description': '完成旅行挑战，解锁独特成就徽章\n登上旅行者排行榜',
      'color': AppTheme.neonBlue,
    },
    {
      'icon': Icons.trending_up,
      'title': '旅行等级与积分',
      'description': '每次旅行提升等级，累积旅行值\n解锁更多专属特权',
      'color': AppTheme.neonTeal,
    },
    {
      'icon': Icons.card_giftcard,
      'title': '积分兑换好礼',
      'description': '用旅行积分兑换精美礼品\n专属优惠和限定体验',
      'color': AppTheme.neonOrange,
    },
    {
      'icon': Icons.photo_camera,
      'title': '分享旅行记忆',
      'description': '记录并分享你的独特旅行故事\n与志同道合的旅行者互动',
      'color': AppTheme.neonPink,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateLastPageButton() {
    if (_currentPage == _pages.length - 1 && !_isLastPageAnimated) {
      _animationController.forward();
      setState(() {
        _isLastPageAnimated = true;
      });
    } else if (_currentPage != _pages.length - 1) {
      _animationController.reset();
      setState(() {
        _isLastPageAnimated = false;
      });
    }
  }

  // 标记已看过引导页
  Future<void> _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景渐变装饰
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    _currentPage < _pages.length
                        ? _pages[_currentPage]['color'].withOpacity(0.2)
                        : AppTheme.neonPurple.withOpacity(0.2),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),

          // 装饰圆形
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _currentPage < _pages.length
                        ? _pages[_currentPage]['color'].withOpacity(0.3)
                        : AppTheme.neonPurple.withOpacity(0.3),
                    AppTheme.backgroundColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _currentPage < _pages.length
                        ? _pages[_currentPage]['color'].withOpacity(0.3)
                        : AppTheme.neonPurple.withOpacity(0.3),
                    AppTheme.backgroundColor.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),

          // 添加右上角跳过按钮
          if (_currentPage != _pages.length - 1)
            Positioned(
              top: 60,
              right: 20,
              child: GlassCard(
                borderRadius: 25,
                blur: 10,
                opacity: 0.1,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () {
                  // 直接跳转到主页面
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(
                  '跳过',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50), // 顶部增加间距
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _animateLastPageButton();
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(
                        context: context,
                        icon: _pages[index]['icon'],
                        title: _pages[index]['title'],
                        description: _pages[index]['description'],
                        color: _pages[index]['color'],
                        index: index,
                      );
                    },
                  ),
                ),
                _buildPageIndicator(),
                _buildBottomButton(context),
                const SizedBox(height: 40), // 底部增加间距
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建每个引导页面
  Widget _buildPage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required int index,
  }) {
    // 使用TweenAnimationBuilder实现淡入效果
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // 从下向上滑入效果
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 图标带3D效果
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
                ),
                boxShadow: [
                  // 外阴影
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 25,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                  // 内亮光
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: -1,
                    offset: const Offset(-5, -5),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 70.0,
                color: AppTheme.primaryTextColor,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            // 标题
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryTextColor,
                shadows: [
                  Shadow(
                    color: color.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // 描述
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                height: 1.5,
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 构建页面指示器
  Widget _buildPageIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _pages.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            height: 10,
            width: _currentPage == index ? 25 : 10, // 当前页面指示器更长
            decoration: BoxDecoration(
              color:
                  _currentPage == index
                      ? _pages[index]['color']
                      : AppTheme.secondaryTextColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
              boxShadow:
                  _currentPage == index
                      ? [
                        BoxShadow(
                          color: _pages[index]['color'].withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
          ),
        ),
      ),
    );
  }

  // 构建底部按钮
  Widget _buildBottomButton(BuildContext context) {
    if (_currentPage == _pages.length - 1) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: GradientButton(
                onPressed: _markOnboardingComplete,
                gradient: LinearGradient(
                  colors: [AppTheme.neonPurple, AppTheme.neonBlue],
                ),
                text: '开始探索',
              ),
            ),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: GradientButton(
          onPressed: () {
            _pageController.animateToPage(
              _currentPage + 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          gradient: LinearGradient(
            colors: [
              _pages[_currentPage]['color'],
              _pages[_currentPage]['color'].withOpacity(0.7),
            ],
          ),
          text: '下一步',
        ),
      );
    }
  }
}
