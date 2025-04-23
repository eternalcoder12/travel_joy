import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../app_theme.dart';
import 'map_view_screen.dart';

class SpotDetailScreen extends StatefulWidget {
  final Map<String, dynamic> spotData;

  const SpotDetailScreen({Key? key, required this.spotData}) : super(key: key);

  @override
  _SpotDetailScreenState createState() => _SpotDetailScreenState();
}

class _SpotDetailScreenState extends State<SpotDetailScreen>
    with TickerProviderStateMixin {
  // 页面动画控制器
  late AnimationController _pageAnimController;

  // 抽屉动画控制器
  late AnimationController _drawerAnimController;
  late Animation<double> _drawerAnimation;

  // 图片列表 - 在实际应用中，这些数据应该从API获取
  late List<String> _imageGallery;

  // 当前选中的图片索引
  int _currentImageIndex = 0;

  // 页面控制器，用于图片画廊
  final PageController _pageController = PageController();

  // 是否已收藏
  bool _isFavorite = false;

  // 是否显示底部抽屉
  bool _isBottomDrawerVisible = false;

  // 顶部滚动位置监听
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  // 模拟评论数据
  final List<Map<String, dynamic>> _reviews = [
    {
      'userName': '李明',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'date': '2023-07-15',
      'rating': 4.8,
      'comment': '风景非常优美，空气清新，是一个放松身心的好地方。强烈推荐给所有热爱自然的朋友们！',
    },
    {
      'userName': '王丽',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'date': '2023-06-28',
      'rating': 4.5,
      'comment': '景点很漂亮，但人有点多。建议早上或傍晚前去，可以避开人流高峰期。',
    },
    {
      'userName': '张伟',
      'avatar': 'https://randomuser.me/api/portraits/men/55.jpg',
      'date': '2023-05-19',
      'rating': 5.0,
      'comment': '绝对是我去过的最美的地方之一！拍照很上镜，附近也有很多美食小店，度过了愉快的一天！',
    },
  ];

  // 在类顶部添加这个变量
  bool _isClosingDrawer = false;

  // 新增拖拽距离变量
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();

    // 初始化页面动画控制器
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 初始化抽屉动画控制器
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _drawerAnimation = CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // 启动页面进入动画
    _pageAnimController.forward();

    // 初始化图片画廊 - 使用Unsplash高质量图片
    final spotName =
        widget.spotData['name'].toString().replaceAll(' ', '-').toLowerCase();
    _imageGallery = [
      // 使用景点原始图片作为第一张
      widget.spotData['image'],
      // 使用Unsplash图片 - 根据景点名称搜索相关图片
      'https://source.unsplash.com/1600x900/?${spotName},scenery',
      'https://source.unsplash.com/1600x900/?${spotName},view',
      'https://source.unsplash.com/1600x900/?${spotName},landscape',
    ];

    // 监听滚动事件
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  // 尝试打开外部应用进行预订
  Future<void> _launchExternalApp(
    String url, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    if (_isClosingDrawer) return; // 如果正在关闭抽屉，不再触发新的打开操作

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: mode);
        _closeBottomDrawer();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('无法打开 $url')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('发生错误: $e')));
    }
  }

  void _closeBottomDrawer() {
    // 启动反向动画
    _drawerAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isBottomDrawerVisible = false;
          _isClosingDrawer = false;
          _dragExtent = 0;
        });
      }
    });

    setState(() {
      _isClosingDrawer = true;
    });
  }

  // 打开底部抽屉
  void _showBottomDrawer() {
    setState(() {
      _dragExtent = 0; // 重置拖拽距离
      _isClosingDrawer = false;
      _isBottomDrawerVisible = true;
    });

    // 启动正向动画
    _drawerAnimController.forward();
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _drawerAnimController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 主内容
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 图片画廊和顶部应用栏
              _buildImageGallerySliverAppBar(),

              // 景点信息
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _pageAnimController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _pageAnimController.value)),
                      child: Opacity(
                        opacity: _pageAnimController.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 景点名称和收藏按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.spotData['name'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _isFavorite ? '已添加到收藏' : '已从收藏中移除',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      _isFavorite
                                          ? Colors.red.withOpacity(0.1)
                                          : AppTheme.cardColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      _isFavorite
                                          ? Colors.red
                                          : AppTheme.secondaryTextColor,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 位置和评分
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.secondaryTextColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.spotData['location'],
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              widget.spotData['rating'].toString(),
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/5.0',
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 标签
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              (widget.spotData['tags'] as List<String>).map((
                                tag,
                              ) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // 关于部分
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '关于',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),

                            // 查看地图按钮
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => MapViewScreen(
                                          spots: [widget.spotData],
                                          initialSpotIndex: 0,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.buttonColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.map,
                                      color: AppTheme.buttonColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '查看地图',
                                      style: TextStyle(
                                        color: AppTheme.buttonColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Text(
                          widget.spotData['description'] ??
                              '这个神奇的地方拥有壮观的自然景观和丰富的文化历史。无论是徒步爱好者、摄影师还是历史爱好者，这里都能满足您的需求。清新的空气、美丽的风景和友好的当地人将为您的旅行增添难忘的回忆。',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 设施信息
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ), // 去掉水平内边距
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '设施与服务',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 使用GridView替代Wrap，确保每行4个并对齐
                              GridView.count(
                                crossAxisCount: 4,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                mainAxisSpacing: 16,
                                children: [
                                  _buildFacilityItem(Icons.wifi, '免费WiFi'),
                                  _buildFacilityItem(Icons.restaurant, '餐厅'),
                                  _buildFacilityItem(
                                    Icons.directions_car,
                                    '停车场',
                                  ),
                                  _buildFacilityItem(Icons.accessible, '无障碍通道'),
                                  _buildFacilityItem(Icons.photo_camera, '观景台'),
                                  _buildFacilityItem(Icons.shopping_bag, '礼品店'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 评论部分
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '用户评论',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // TODO: 导航到所有评论页面
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('查看全部评论'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Text(
                                '查看全部',
                                style: TextStyle(
                                  color: AppTheme.buttonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // 评论列表
                        ..._reviews.map((review) => _buildReviewItem(review)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 半透明玻璃效果顶部导航栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: statusBarHeight + 56,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: EdgeInsets.only(top: statusBarHeight),
                    color: Colors.black.withOpacity(
                      _scrollOffset > 140 ? 0.6 : 0.2,
                    ),
                    child: Row(
                      children: [
                        // 返回按钮 - 优化样式
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // 添加景点类型标题
                        Expanded(
                          child: Text(
                            _scrollOffset > 140
                                ? widget.spotData['name']
                                : "景点详情",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 添加一个空白占位，保持对称
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(width: 40),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 底部抽屉 - 使用ModalBarrier模式
          if (_isBottomDrawerVisible)
            Positioned.fill(
              child: Stack(
                children: [
                  // 背景遮罩
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _drawerAnimController,
                      builder: (context, _) {
                        return GestureDetector(
                          onTap: _closeBottomDrawer,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5.0 * _drawerAnimation.value,
                              sigmaY: 5.0 * _drawerAnimation.value,
                            ),
                            child: Container(
                              color: AppTheme.backgroundColor.withOpacity(
                                0.5 * _drawerAnimation.value,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 抽屉内容
                  _buildBottomDrawer(),
                ],
              ),
            ),
        ],
      ),

      // 底部操作栏
      bottomNavigationBar:
          _isBottomDrawerVisible
              ? null
              : AnimatedBuilder(
                animation: _pageAnimController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - _pageAnimController.value)),
                    child: Opacity(
                      opacity: _pageAnimController.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2B3D), // 使用更深的背景色以增加对比度
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      // 确保垂直居中
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 价格信息
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center, // 垂直居中
                            children: [
                              Text(
                                '价格',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥${widget.spotData['price'] ?? '88'}/人',
                                style: const TextStyle(
                                  color: Colors.white, // 更鲜明的颜色对比
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 外部应用预订按钮
                        ElevatedButton.icon(
                          onPressed: _showBottomDrawer,
                          icon: const Icon(Icons.shopping_cart, size: 16),
                          label: const Text('前往预订'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  // 构建抽屉选项
  Widget _buildDrawerOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.buttonColor, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.secondaryTextColor,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 88.0),
            child: Divider(
              height: 1,
              color: AppTheme.cardColor.withOpacity(0.2),
            ),
          ),
      ],
    );
  }

  // 构建顶部图片画廊App Bar
  Widget _buildImageGallerySliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // 图片页面指示器
            PageView.builder(
              controller: _pageController,
              itemCount: _imageGallery.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    // 图片
                    Positioned.fill(
                      child: Image.network(
                        _imageGallery[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: AppTheme.cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.buttonColor,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.cardColor,
                            child: Center(
                              child: Icon(
                                Icons.error,
                                color: AppTheme.primaryTextColor,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 图片底部渐变阴影
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 图片指示器
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imageGallery.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentImageIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color:
                          _currentImageIndex == index
                              ? AppTheme.buttonColor
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建设施项
  Widget _buildFacilityItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.buttonColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
        ),
      ],
    );
  }

  // 构建评论项
  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['avatar']),
              ),
              const SizedBox(width: 12),

              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'],
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          review['date'],
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          review['rating'].toString(),
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 评论内容
          Text(
            review['comment'],
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 8),

          // 分隔线
          Divider(color: AppTheme.cardColor.withOpacity(0.3)),
        ],
      ),
    );
  }

  // 构建底部抽屉
  Widget _buildBottomDrawer() {
    final drawerHeight = MediaQuery.of(context).size.height * 0.6;

    return AnimatedBuilder(
      animation: _drawerAnimController,
      builder: (context, child) {
        final slideHeight = (1 - _drawerAnimation.value) * drawerHeight;
        final scale = 0.9 + (0.1 * _drawerAnimation.value); // 缩放效果
        final opacity = _drawerAnimation.value; // 透明度效果

        return Positioned(
          bottom: -slideHeight + _dragExtent,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child!,
            ),
          ),
        );
      },
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          // 跟踪拖拽的位置变化
          if (details.delta.dy > 0) {
            // 向下拖动时，根据拖动距离调整抽屉位置
            setState(() {
              _dragExtent += details.delta.dy; // 累加拖拽距离
            });
          }
        },
        onVerticalDragEnd: (details) {
          // 根据拖拽速度决定是否关闭抽屉
          if (details.primaryVelocity! > 300) {
            _closeBottomDrawer();
          } else if (_dragExtent > MediaQuery.of(context).size.height * 0.2) {
            // 拖拽超过屏幕高度的20%也关闭抽屉
            _closeBottomDrawer();
          } else {
            // 重置拖拽距离，抽屉回弹到原位
            setState(() {
              _dragExtent = 0;
            });
          }
        },
        child: Container(
          height: drawerHeight,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              // 抽屉顶部把手
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryTextColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 抽屉标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "选择购票方式",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 抽屉选项列表
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 地图导航选项
                      _buildDrawerOption(
                        icon: Icons.map_outlined,
                        title: "地图导航",
                        subtitle: "打开地图应用进行导航",
                        onTap: () {
                          _launchMaps();
                        },
                      ),
                      // 浏览器搜索选项
                      _buildDrawerOption(
                        icon: Icons.search_outlined,
                        title: "浏览器搜索",
                        subtitle: "打开浏览器搜索购票信息",
                        onTap: () {
                          _launchBrowser();
                        },
                      ),
                      // 微信小程序选项
                      _buildDrawerOption(
                        icon: Icons.wechat_outlined,
                        title: "微信小程序",
                        subtitle: "打开微信应用",
                        onTap: () {
                          _launchWeChat();
                        },
                      ),
                      // 第三方旅行应用选项
                      _buildDrawerOption(
                        icon: Icons.travel_explore,
                        title: "第三方旅行应用",
                        subtitle: "尝试打开携程等应用",
                        onTap: () {
                          _launchTravelApp();
                        },
                        showDivider: false,
                      ),
                      SizedBox(height: 20),
                      // 取消按钮
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ElevatedButton(
                          onPressed: () => _closeBottomDrawer(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cardColor,
                            foregroundColor: AppTheme.buttonColor,
                            minimumSize: Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppTheme.secondaryTextColor.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "取消",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 打开地图应用
  void _launchMaps() {
    _closeBottomDrawer();
    // 尝试打开Apple地图
    String spotName = widget.spotData['name'] ?? '景点';
    String location = widget.spotData['location'] ?? '地址未知';
    launchUrl(Uri.parse('maps://?q=$spotName&address=$location'));
  }

  // 打开浏览器搜索
  void _launchBrowser() {
    _closeBottomDrawer();
    // 打开Google搜索
    String spotName = widget.spotData['name'] ?? '景点';
    launchUrl(Uri.parse('https://www.google.com/search?q=$spotName+门票+预订'));
  }

  // 打开微信应用
  void _launchWeChat() {
    _closeBottomDrawer();
    // 尝试打开微信
    launchUrl(Uri.parse('weixin://'));
  }

  // 打开第三方旅行应用
  void _launchTravelApp() {
    _closeBottomDrawer();
    // 尝试打开携程APP
    launchUrl(Uri.parse('ctrip://'));
  }
}
