import 'package:flutter/material.dart';
import '../../app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
  late AnimationController _toolsAnimationController;
  late AnimationController _communityAnimationController;
  late AnimationController _buttonAnimationController;

  // Unsplash图片URL
  final String _communityImageUrl =
      'https://images.unsplash.com/photo-1516815231560-8f41ec531527?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80'; // 巴厘岛

  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // 初始化卡片动画控制器
    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    // 初始化工具区域动画控制器
    _toolsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

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

    // 延迟200毫秒启动工具区域动画
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _toolsAnimationController.forward();
      }
    });

    // 延迟400毫秒启动社区内容动画
    Future.delayed(const Duration(milliseconds: 400), () {
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
    _toolsAnimationController.dispose();
    _communityAnimationController.dispose();
    _buttonAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // 渐变背景从AppTheme.backgroundColor到深蓝色
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 搜索栏和筛选按钮
                Row(
                  children: [
                    // 搜索输入框
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '搜索景点、酒店...',
                          hintStyle: TextStyle(color: AppTheme.hintTextColor),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.iconColor,
                          ),
                          filled: true,
                          fillColor: AppTheme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                          ),
                        ),
                      ),
                    ),
                    // 筛选按钮
                    Container(
                      margin: const EdgeInsets.only(left: 12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.filter_list,
                          color: AppTheme.iconColor,
                        ),
                        onPressed: () {
                          print('点击了筛选按钮');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16.0), // 搜索栏与标题间距
                // 标题
                Text(
                  '发现旅途乐趣',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8.0), // 标题与副标题间距
                // 副标题
                Text(
                  '探索小众景点，畅游治愈之旅',
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
                    height: 270, // 设置更大的固定高度
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

                const SizedBox(height: 24.0), // 功能卡片与辅助工具区域间距
                // 辅助工具区域
                AnimatedBuilder(
                  animation: _toolsAnimationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _toolsAnimationController.value,
                      child: child,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 辅助工具标题
                      Text(
                        '实用工具',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16.0), // 辅助工具标题与工具卡片间距
                      // 工具卡片（水平排列）
                      Row(
                        children: [
                          // 地图导航卡片
                          Expanded(
                            child: _buildToolCard(
                              context: context,
                              icon: Icons.map_outlined,
                              title: '地图导航',
                            ),
                          ),
                          const SizedBox(width: 16.0), // 工具卡片之间间距
                          // 旅行清单卡片
                          Expanded(
                            child: _buildToolCard(
                              context: context,
                              icon: Icons.checklist,
                              title: '旅行清单',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24.0), // 辅助工具区域与社区推荐预览间距
                // 社区推荐预览
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
                      // 社区推荐标题和副标题
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '旅友推荐',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          Text(
                            '看看大家都在分享什么',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0), // 社区推荐标题与内容间距
                      // 社区推荐内容
                      _buildCommunityPreview(
                        context: context,
                        username: '旅行者1',
                        content: '这是我在巴厘岛的难忘旅行，非常推荐大家前往，水清沙白，景色宜人...',
                        likes: '120',
                        comments: '50',
                        imageUrl: _communityImageUrl,
                      ),

                      const SizedBox(height: 16.0), // 内容与"查看更多"按钮间距
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
                            style:
                                AppTheme.getTheme().elevatedButtonTheme.style,
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
      ),
    );
  }

  // 圆形功能卡片 - 更大尺寸
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
        customBorder: const CircleBorder(),
        splashColor: AppTheme.accentColor.withOpacity(0.3),
        highlightColor: AppTheme.accentColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8, // 增大阴影模糊度
                offset: const Offset(0, 4), // 增大阴影偏移
              ),
            ],
            // 渐变边框
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.iconColor, size: 40.0), // 增大图标尺寸
              const SizedBox(height: 12), // 增大间距
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }

  // 辅助工具卡片
  Widget _buildToolCard({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 工具卡片点击处理
          print('点击了工具: $title');
        },
        borderRadius: BorderRadius.circular(12.0),
        splashColor: AppTheme.accentColor.withOpacity(0.3),
        highlightColor: AppTheme.accentColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
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
              const SizedBox(height: 8.0),
              Text(title, style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }

  // 社区推荐预览项
  Widget _buildCommunityPreview({
    required BuildContext context,
    required String username,
    required String content,
    required String likes,
    required String comments,
    required String imageUrl,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('查看详情: $username 的分享');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            // 渐变边框
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
              stops: const [0.0, 0.5],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片（Unsplash图片）
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      // 加载错误时显示占位图
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              color: AppTheme.iconColor.withOpacity(0.5),
                              size: 40,
                            ),
                          ),
                        );
                      },
                      // 加载中显示进度指示器
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppTheme.cardColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accentColor,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                // 用户昵称
                Text(
                  username,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4.0),

                // 内容摘要
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),

                // 互动元素：点赞和评论
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.favorite, color: AppTheme.iconColor, size: 18),
                    const SizedBox(width: 4.0),
                    Text(likes, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(width: 16.0),
                    Icon(
                      Icons.chat_bubble_outline,
                      color: AppTheme.iconColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      comments,
                      style: Theme.of(context).textTheme.bodyMedium,
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
}
