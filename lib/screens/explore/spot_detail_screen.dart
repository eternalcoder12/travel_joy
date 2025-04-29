import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../app_theme.dart';
import 'map_view_screen.dart';
import '../../utils/navigation_utils.dart';

// 添加AppTheme的扩展属性
extension AppThemeExtension on AppTheme {
  static Color get secondaryBackgroundColor => AppTheme.cardColor;
  static Color get secondaryColor => AppTheme.accentColor;
}

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
  
  // 图片加载状态
  bool _imagesLoading = true;
  Map<int, bool> _imageLoadStatus = {};

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
  
  // 添加刷新状态控制
  bool _isRefreshing = false;

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
    
    // 初始化图片加载状态
    for (int i = 0; i < _imageGallery.length; i++) {
      _imageLoadStatus[i] = false;
    }
    
    // 模拟图片加载完成
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _imagesLoading = false;
          for (int i = 0; i < _imageGallery.length; i++) {
            _imageLoadStatus[i] = true;
          }
        });
      }
    });

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
  
  // 模拟刷新数据
  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    // 模拟网络请求延迟
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // 可以在这里更新数据，这里只是简单地随机切换收藏状态作为示例
        _isFavorite = !_isFavorite;
      });
      
      // 显示刷新成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('数据已更新'))
      );
    }
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
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.buttonColor,
            backgroundColor: Colors.white,
            strokeWidth: 3,
            child: CustomScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              slivers: [
                // 图片画廊和顶部应用栏
                _buildImageGallerySliverAppBar(),

                // 景点信息
                SliverToBoxAdapter(
                  child: _buildSpotInfo(),
                ),

                // 景点描述
                SliverToBoxAdapter(
                  child: _buildSpotDescription(),
                ),

                // 评论和评分
                SliverToBoxAdapter(
                  child: _buildReviews(),
                ),

                // 底部填充，确保内容不被底部按钮遮挡
                SliverToBoxAdapter(
                  child: SizedBox(height: 80 + bottomPadding),
                ),
              ],
            ),
          ),

          // 顶部应用栏 - 随着滚动变得不透明
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAnimatedAppBar(statusBarHeight),
          ),

          // 底部固定按钮
          _buildBottomButtons(bottomPadding),

          // 底部抽屉
          if (_isBottomDrawerVisible)
            _buildBottomDrawer(context, bottomPadding),
        ],
      ),
    );
  }

  // 构建图片画廊和顶部应用栏
  Widget _buildImageGallerySliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // 图片画廊
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
                    // 图片底色（加载中或加载失败时显示）
                    Container(
                      color: Colors.grey[300],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    
                    // 主图片
                    _imagesLoading || !(_imageLoadStatus[index] ?? false)
                        ? Center(
                            child: _buildImageLoadingIndicator(),
                          )
                        : Image.network(
                            _imageGallery[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red[300],
                                      size: 50,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '图片加载失败',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ],
                );
              },
            ),

            // 底部渐变遮罩
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),

            // 图片指示器
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _imageGallery.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // 透明的应用栏，实际内容在其他地方构建
      leading: Container(),
      actions: [Container()],
    );
  }
  
  // 构建图片加载指示器
  Widget _buildImageLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            '加载图片中...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 构建动态应用栏
  Widget _buildAnimatedAppBar(double statusBarHeight) {
    // 计算透明度 - 随着滚动逐渐变为不透明
    final double opacity = (_scrollOffset / 200).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: 56 + statusBarHeight,
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(opacity),
        boxShadow: opacity > 0.8
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: opacity > 0.5
                  ? AppTheme.primaryTextColor
                  : Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          // 景点名称 - 随着滚动显示
          if (opacity > 0.5)
            Expanded(
              child: Text(
                widget.spotData['name'],
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            )
          else
            Expanded(child: SizedBox()),

          // 收藏按钮
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.red
                  : (opacity > 0.5 ? AppTheme.primaryTextColor : Colors.white),
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite ? '已添加到收藏' : '已取消收藏',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建景点信息卡片
  Widget _buildSpotInfo() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppThemeExtension.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和评分
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.spotData['name'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.spotData['location'],
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // 评分
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.spotData['rating'].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 信息栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  icon: Icons.access_time,
                  label: '开放时间',
                  value: widget.spotData['hours'],
                ),
                _buildInfoItem(
                  icon: Icons.attach_money,
                  label: '门票',
                  value: widget.spotData['price'],
                ),
                _buildInfoItem(
                  icon: Icons.people,
                  label: '推荐游览',
                  value: widget.spotData['duration'],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 标签
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.spotData['tags'] as List<String>)
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppThemeExtension.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppThemeExtension.secondaryColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // 查看地图按钮
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapViewScreen(
                      spots: [widget.spotData],
                      initialSpotIndex: 0,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.buttonColor.withOpacity(0.1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      color: AppTheme.buttonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '在地图上查看',
                      style: TextStyle(
                        color: AppTheme.buttonColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建信息项目
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppThemeExtension.secondaryColor,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }

  // 构建景点描述
  Widget _buildSpotDescription() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppThemeExtension.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        builder: (context) => MapViewScreen(
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
          ],
        ),
      ),
    );
  }

  // 构建评论和评分
  Widget _buildReviews() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppThemeExtension.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
  Widget _buildBottomDrawer(BuildContext context, double bottomPadding) {
    final drawerHeight = MediaQuery.of(context).size.height * 0.6;

    return Positioned(
      bottom: -drawerHeight + _dragExtent,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _drawerAnimController,
        builder: (context, child) {
          final slideHeight = (1 - _drawerAnimation.value) * drawerHeight;
          final scale = 0.9 + (0.1 * _drawerAnimation.value); // 缩放效果
          final opacity = _drawerAnimation.value; // 透明度效果

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: child!,
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

  // 添加缺失的 _buildBottomButtons 方法
  Widget _buildBottomButtons(double bottomPadding) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2B3D),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 价格信息
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        color: Colors.white,
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
    );
  }
}
