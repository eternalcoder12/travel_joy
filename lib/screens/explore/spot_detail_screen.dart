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

  // 是否显示底部抽屉
  bool _showBottomDrawer = false;

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
    // 显示底部抽屉并添加动画效果
    setState(() {
      _showBottomDrawer = true;
    });
  }

  // 关闭底部抽屉
  void _closeBottomDrawer() {
    // 先设置关闭动画标记，而不是立即关闭
    setState(() {
      _isClosingDrawer = true;
    });

    // 延迟300毫秒后真正关闭抽屉
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showBottomDrawer = false;
          _isClosingDrawer = false;
        });
      }
    });
  }

  // 实际打开URL的方法
  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('无法打开: $url'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发生错误: $e'),
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
          if (_showBottomDrawer)
            Positioned.fill(
              child: Stack(
                children: [
                  // 背景遮罩
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeBottomDrawer,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                        child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),

                  // 抽屉内容
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                      tween: Tween<double>(
                        begin: _isClosingDrawer ? 0.0 : 1.0,
                        end: _isClosingDrawer ? 1.0 : 0.0,
                      ),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value * 500),
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        // 防止点击抽屉自身时关闭抽屉
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 标题和把手
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                                child: Column(
                                  children: [
                                    // 抽屉顶部把手
                                    Container(
                                      width: 40,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // 预订标题
                                    Text(
                                      "选择预订方式",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 预订选项列表
                              _buildDrawerOption(
                                Icons.map,
                                "地图导航",
                                "使用地图应用导航到该景点",
                                () {
                                  final spotName = Uri.encodeComponent(
                                    widget.spotData['name'],
                                  );
                                  // 改为使用固定的经纬度坐标，因为location字段只是一个地址描述字符串
                                  // 这里根据景点名称使用模拟的经纬度数据
                                  String lat, lng;
                                  if (widget.spotData['name'] == '西湖风景区') {
                                    lat = '30.2590';
                                    lng = '120.1388';
                                  } else if (widget.spotData['name'] ==
                                      '故宫博物院') {
                                    lat = '39.9163';
                                    lng = '116.3972';
                                  } else if (widget.spotData['name'] ==
                                      '黄山风景区') {
                                    lat = '30.1319';
                                    lng = '118.1647';
                                  } else if (widget.spotData['name'] ==
                                      '张家界国家森林公园') {
                                    lat = '29.1347';
                                    lng = '110.4795';
                                  } else if (widget.spotData['name'] ==
                                      '丽江古城') {
                                    lat = '26.8719';
                                    lng = '100.2282';
                                  } else {
                                    // 默认经纬度，如果没有找到匹配
                                    lat = '39.9042';
                                    lng = '116.4074'; // 北京默认位置
                                  }

                                  _openUrl(
                                    'https://maps.apple.com/?q=$spotName&ll=$lat,$lng&z=15',
                                  );
                                  _closeBottomDrawer();
                                },
                              ),

                              _buildDrawerOption(
                                Icons.public,
                                "浏览器查询",
                                "使用浏览器搜索相关门票信息",
                                () {
                                  final spotName = Uri.encodeComponent(
                                    widget.spotData['name'],
                                  );
                                  final location = Uri.encodeComponent(
                                    widget.spotData['location'],
                                  );
                                  _openUrl(
                                    'https://www.google.com/search?q=$spotName+$location+门票预订',
                                  );
                                  _closeBottomDrawer();
                                },
                              ),

                              _buildDrawerOption(
                                Icons.message,
                                "微信小程序",
                                "通过微信小程序预订",
                                () {
                                  _openUrl('weixin://');
                                  _closeBottomDrawer();
                                },
                              ),

                              _buildDrawerOption(
                                Icons.phone_android,
                                "第三方旅行应用",
                                "使用专业旅行应用进行预订",
                                () {
                                  // 尝试打开携程，如不成功则打开其网页
                                  _openUrl('ctrip://');
                                  _closeBottomDrawer();
                                },
                              ),

                              // 关闭按钮
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: _closeBottomDrawer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.withOpacity(
                                      0.2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    "取消",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: bottomPadding),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      // 底部操作栏
      bottomNavigationBar:
          _showBottomDrawer
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
                    color: AppTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
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
                                '价格',
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
  Widget _buildDrawerOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppTheme.buttonColor),
                  ),
                  const SizedBox(width: 16),
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
                    size: 16,
                    color: AppTheme.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        // 分隔线，除了最后一个选项外都添加
        if (title != "第三方旅行应用")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(
              color: AppTheme.cardColor.withOpacity(0.3),
              height: 1,
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
}
