import 'package:flutter/material.dart';
import '../../app_theme.dart';

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
    },
    {
      'icon': Icons.emoji_events,
      'title': '旅行成就系统',
      'description': '完成旅行挑战，解锁独特成就徽章\n登上旅行者排行榜',
    },
    {
      'icon': Icons.trending_up,
      'title': '旅行等级与积分',
      'description': '每次旅行提升等级，累积旅行值\n解锁更多专属特权',
    },
    {
      'icon': Icons.card_giftcard,
      'title': '积分兑换好礼',
      'description': '用旅行积分兑换精美礼品\n专属优惠和限定体验',
    },
    {
      'icon': Icons.photo_camera,
      'title': '分享旅行记忆',
      'description': '记录并分享你的独特旅行故事\n与志同道合的旅行者互动',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 添加右上角跳过按钮
            if (_currentPage != _pages.length - 1)
              Positioned(
                top: 20,
                right: 20,
                child: TextButton(
                  onPressed: () {
                    // 直接跳转到主页面
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.cardColor.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
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
            Column(
              children: [
                const SizedBox(height: 30), // 顶部增加间距
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
          ],
        ),
      ),
    );
  }

  // 构建每个引导页面
  Widget _buildPage({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
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
            // 图标
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, size: 80.0, color: AppTheme.iconColor),
            ),
            const SizedBox(height: 60),
            // 标题
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // 描述
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 18, height: 1.5),
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
                      ? AppTheme.primaryTextColor
                      : AppTheme.secondaryTextColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  // 构建底部按钮
  Widget _buildBottomButton(BuildContext context) {
    if (_currentPage == _pages.length - 1) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 220,
          height: 60,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppTheme.buttonColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              foregroundColor: AppTheme.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              elevation: 0,
            ),
            child: Text(
              '开始旅行✈️',
              style: TextStyle(
                color: AppTheme.backgroundColor,
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTextColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTextColor,
            foregroundColor: AppTheme.backgroundColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 0,
          ),
          child: Icon(
            Icons.arrow_forward,
            color: AppTheme.backgroundColor,
            size: 30,
          ),
        ),
      );
    }
  }
}
