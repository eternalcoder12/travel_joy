import 'package:flutter/material.dart';
import '../../app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _cardAnimationController;
  late AnimationController _communityAnimationController;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();

    // 初始化卡片动画控制器
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // 初始化社区内容动画控制器
    _communityAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 初始化按钮动画控制器
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // 延迟200毫秒启动社区内容动画
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _communityAnimationController.forward();
      }
    });

    // 启动按钮动画
    _buttonAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _communityAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [
    const _HomeTab(),
    const Center(child: Text('探索', style: TextStyle(color: Colors.white))),
    const Center(child: Text('消息', style: TextStyle(color: Colors.white))),
    const Center(child: Text('我的', style: TextStyle(color: Colors.white))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: AppTheme.cardColor,
            selectedItemColor: AppTheme.primaryTextColor,
            unselectedItemColor: AppTheme.secondaryTextColor,
            type: BottomNavigationBarType.fixed, // 确保4个项目时也显示文字
            showSelectedLabels: true,
            showUnselectedLabels: true,
            enableFeedback: false, // 禁用触感反馈
            // 完全禁用所有点击动画效果
            selectedFontSize: 14.0,
            unselectedFontSize: 14.0, // 使选中和未选中字体大小相同，防止动画
            iconSize: 24.0, // 固定图标大小
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
              BottomNavigationBarItem(icon: Icon(Icons.explore), label: '探索'),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: '消息'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _communityAnimationController;
  late AnimationController _buttonAnimationController;

  @override
  void initState() {
    super.initState();

    // 初始化卡片动画控制器
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // 初始化社区内容动画控制器
    _communityAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 初始化按钮动画控制器
    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 0.8,
    );

    // 延迟200毫秒启动社区内容动画
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _communityAnimationController.forward();
      }
    });

    // 启动按钮动画
    _buttonAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _communityAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题
              Text(
                '欢迎来到 Travel Joy',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8.0), // 标题与副标题间距
              // 副标题
              Text(
                '探索小众景点，获取最佳推荐',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24.0), // 副标题与功能卡片间距
              // 功能入口卡片（2x2网格）
              AnimatedBuilder(
                animation: _cardAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cardAnimationController.value,
                    child: child,
                  );
                },
                child: SizedBox(
                  height: 220, // 设置固定高度
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(), // 禁止滚动
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    children: [
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.location_on,
                        title: '热门景点',
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.hotel,
                        title: '酒店预订',
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.restaurant,
                        title: '餐厅推荐',
                      ),
                      _buildFeatureCard(
                        context: context,
                        icon: Icons.map,
                        title: '旅行攻略',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24.0), // 功能卡片与社区推荐区域间距
              // 社区推荐区域
              AnimatedBuilder(
                animation: _communityAnimationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _communityAnimationController.value,
                    child: child,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '最新分享',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        Text(
                          '快来分享你的旅行故事，赢取积分！',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0), // 社区推荐标题与内容列表间距
                    // 用户分享内容列表
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildCommunityItem(
                            context: context,
                            username: '旅行者${index + 1}',
                            content:
                                '这是我在${['巴厘岛', '日本京都', '瑞士阿尔卑斯山'][index]}的难忘旅行，非常推荐大家前往...',
                            likes: (120 - index * 30).toString(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16.0), // 列表与"查看更多"按钮间距
                    // "查看更多"按钮
                    Center(
                      child: AnimatedBuilder(
                        animation: _buttonAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonAnimationController.value,
                            child: child,
                          );
                        },
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/discover');
                            print('跳转到发现页面');
                          },
                          style: AppTheme.getTheme().elevatedButtonTheme.style,
                          child: const Text('查看更多'),
                        ),
                      ),
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

  // 功能卡片
  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 功能卡片点击处理
          print('点击了: $title');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('您点击了: $title'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        splashColor: AppTheme.accentColor.withOpacity(0.3),
        highlightColor: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.iconColor, size: 32.0),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }

  // 社区内容项
  Widget _buildCommunityItem({
    required BuildContext context,
    required String username,
    required String content,
    required String likes,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('查看详情: $username 的分享');
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户昵称
                Text(
                  username,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),

                // 图片（占位图）
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: AppTheme.accentColor.withOpacity(0.2),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: AppTheme.iconColor.withOpacity(0.5),
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                // 内容摘要
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),

                // 点赞数
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.favorite, color: AppTheme.iconColor, size: 18),
                    const SizedBox(width: 4.0),
                    Text(likes, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
