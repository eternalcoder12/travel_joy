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

  // 图片列表 - 在实际应用中，这些数据应该从API获取
  late List<String> _imageGallery;

  // 当前选中的图片索引
  int _currentImageIndex = 0;

  // 页面控制器，用于图片画廊
  final PageController _pageController = PageController();

  // 是否已收藏
  bool _isFavorite = false;

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

  @override
  void initState() {
    super.initState();

    // 初始化页面动画控制器
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
  Future<void> _launchExternalApp() async {
    final spotName = Uri.encodeComponent(widget.spotData['name']);
    final location = Uri.encodeComponent(widget.spotData['location']);

    // 尝试打开地图应用
    final mapsUrl = 'https://maps.apple.com/?q=$spotName&ll=$location';
    final mapsUri = Uri.parse(mapsUrl);

    try {
      // 尝试打开地图应用
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        // 尝试打开网页浏览器
        final webUrl =
            'https://www.google.com/search?q=${spotName}+${location}+门票预订';
        final webUri = Uri.parse(webUrl);

        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri);
        } else {
          // 显示提示
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('无法找到合适的应用进行预订'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('启动外部应用失败: $e'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

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
                        Text(
                          '设施与服务',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Wrap(
                          spacing: 20,
                          runSpacing: 16,
                          children: [
                            _buildFacilityItem(Icons.wifi, '免费WiFi'),
                            _buildFacilityItem(Icons.restaurant, '餐厅'),
                            _buildFacilityItem(Icons.directions_car, '停车场'),
                            _buildFacilityItem(Icons.accessible, '无障碍通道'),
                            _buildFacilityItem(Icons.photo_camera, '观景台'),
                            _buildFacilityItem(Icons.shopping_bag, '礼品店'),
                          ],
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

                        // 标题（当滚动到一定位置时显示）
                        if (_scrollOffset > 140)
                          Expanded(
                            child: Text(
                              widget.spotData['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 底部操作栏
      bottomNavigationBar: AnimatedBuilder(
        animation: _pageAnimController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _pageAnimController.value)),
            child: Opacity(opacity: _pageAnimController.value, child: child),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // 价格信息
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '门票价格',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${widget.spotData['price'] ?? '88'}/人',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 外部应用预订按钮
                ElevatedButton.icon(
                  onPressed: _launchExternalApp,
                  icon: const Icon(Icons.open_in_new, size: 16),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
}
