import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../app_theme.dart';
import 'spot_detail_screen.dart';
import 'map_view_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class ExploreScreen extends StatefulWidget {
  final bool isCurrentPage;

  const ExploreScreen({
    Key? key,
    required this.isCurrentPage,
  }) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // 保持页面状态
  @override
  bool get wantKeepAlive => true;
  
  // 动画控制器
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;

  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();
  
  // 是否显示返回顶部按钮
  bool _showBackToTop = false;

  // 加载状态
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  // 内存优化 - 缓存预计算结果
  final Map<String, Widget> _cachedCategoryItems = {};
  final Map<String, Widget> _cachedSpotCards = {};
  final Map<String, Widget> _cachedCityItems = {};

  // 是否已请求位置权限
  bool _hasRequestedLocationPermission = false;
  bool _hasLocationPermission = false;

  // 探索数据
  final List<Map<String, dynamic>> _featuredSpots = [
    {
      'name': '西湖风景区',
      'location': '杭州, 浙江',
      'image': 'https://images.unsplash.com/photo-1575952111447-9a9a06e14d5a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.8,
      'recommendation': '游客必去',
      'tags': ['风景', '湖泊', '历史'],
      'description': '西湖是中国大陆首批国家重点风景名胜区和中国十大风景名胜之一，三面环山，面积约6.39平方千米。湖中被孤山、白堤、苏堤、杨公堤分隔，形成了外西湖、西里湖、北里湖、小南湖及岳湖等五片水面。',
      'hours': '全天开放',
      'duration': '3-4小时',
    },
    {
      'name': '故宫博物院',
      'location': '北京',
      'image': 'https://images.unsplash.com/photo-1584611133366-f8bd14af9a3f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.9,
      'recommendation': '文化瑰宝',
      'tags': ['历史', '文化', '建筑'],
      'description': '北京故宫是中国明清两代的皇家宫殿，旧称为紫禁城，是中国古代宫廷建筑之精华。北京故宫以三大殿为中心，占地面积72万平方米，建筑面积约15万平方米，有大小宫殿七十多座，房屋九千余间。',
      'hours': '8:30-17:00',
      'duration': '4-6小时',
    },
    {
      'name': '黄山风景区',
      'location': '黄山, 安徽',
      'image': 'https://images.unsplash.com/photo-1588656736117-8f79bd7f1d48?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      'rating': 4.7,
      'recommendation': '云海奇观',
      'tags': ['山水', '风景', '徒步'],
      'description': '黄山位于安徽省南部，是中国十大名山之一，以奇松、怪石、云海、温泉、冬雪"五绝"著称于世。黄山的自然景观丰富多彩，山上常年云雾缭绕，气象万千，被誉为"人间仙境"。',
      'hours': '6:30-17:30',
      'duration': '1-2天',
    },
  ];

  // 热门城市
  final List<Map<String, dynamic>> _popularCities = [
    {
      'name': '北京',
      'image': 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'spotCount': 32,
    },
    {
      'name': '上海',
      'image': 'https://images.unsplash.com/photo-1474181487882-5abf3f0ba6c2?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'spotCount': 28,
    },
    {
      'name': '杭州',
      'image': 'https://images.unsplash.com/photo-1598559309212-a7c2f5b5881b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'spotCount': 24,
    },
    {
      'name': '成都',
      'image': 'https://images.unsplash.com/photo-1565798846807-92720fc524ba?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'spotCount': 26,
    },
    {
      'name': '广州',
      'image': 'https://images.unsplash.com/photo-1583591749989-0d11dad40b8d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
      'spotCount': 20,
    },
  ];

  // 探索分类
  final List<Map<String, dynamic>> _exploreCategories = [
    {
      'name': '历史古迹',
      'icon': Icons.account_balance,
      'color': Color(0xFFFF6B6B),
    },
    {
      'name': '自然风光',
      'icon': Icons.landscape,
      'color': Color(0xFF4ECDC4),
    },
    {
      'name': '主题公园',
      'icon': Icons.attractions,
      'color': Color(0xFFFFD166),
    },
    {
      'name': '美食之旅',
      'icon': Icons.restaurant,
      'color': Color(0xFF9775FA),
    },
    {
      'name': '文化体验',
      'icon': Icons.theater_comedy,
      'color': Color(0xFF06D6A0),
    },
    {
      'name': '购物天堂',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFF06595),
    },
    {
      'name': '夜生活',
      'icon': Icons.nightlife,
      'color': Color(0xFF748FFC),
    },
    {
      'name': '海滩度假',
      'icon': Icons.beach_access,
      'color': Color(0xFFFFA94D),
    },
  ];

  @override
  void initState() {
    super.initState();

    // 初始化背景动画控制器 - 只在当前页面时才激活
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化内容动画控制器
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画 - 延迟一帧避免卡顿
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _contentAnimController.forward();
      if (widget.isCurrentPage) {
        _backgroundAnimController.repeat(reverse: true);
      }
    });

    // 检查位置权限
    _checkLocationPermission();
    
    // 添加滚动监听
    _scrollController.addListener(_onScroll);
    
    // 预缓存数据
    _precacheData();
  }
  
  // 预缓存数据处理
  void _precacheData() {
    // 在后台线程预处理分类项
    compute(_createCategoryItems, _exploreCategories).then((result) {
      if (mounted) {
        setState(() {
          _cachedCategoryItems.addAll(result);
        });
      }
    });
    
    // 预处理景点卡片
    compute(_createSpotCards, _featuredSpots).then((result) {
      if (mounted) {
        setState(() {
          _cachedSpotCards.addAll(result);
        });
      }
    });
    
    // 预处理城市卡片
    compute(_createCityItems, _popularCities).then((result) {
      if (mounted) {
        setState(() {
          _cachedCityItems.addAll(result);
        });
      }
    });
  }
  
  // 在后台线程创建分类项
  static Map<String, Widget> _createCategoryItems(List<Map<String, dynamic>> categories) {
    final Map<String, Widget> result = {};
    for (var category in categories) {
      final key = category['name'] as String;
      final icon = category['icon'] as IconData;
      final color = category['color'] as Color;
      
      result[key] = Container(
        width: 80,
        margin: EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(height: 8),
            Text(
              key,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    return result;
  }
  
  // 在后台线程创建景点卡片
  static Map<String, Widget> _createSpotCards(List<Map<String, dynamic>> spots) {
    // 注意：此函数无法创建完整Widget，因为它需要动画和导航功能
    // 仅作为优化示意，实际实现需在主线程完成
    return {};
  }
  
  // 在后台线程创建城市项
  static Map<String, Widget> _createCityItems(List<Map<String, dynamic>> cities) {
    // 注意：此函数无法创建完整Widget，因为它需要动画和导航功能
    // 仅作为优化示意，实际实现需在主线程完成
    return {};
  }
  
  // 滚动监听
  void _onScroll() {
    final showBackToTop = _scrollController.offset > 300;
    if (showBackToTop != _showBackToTop) {
      setState(() {
        _showBackToTop = showBackToTop;
      });
    }
  }
  
  // 返回顶部
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // 检查位置权限
  Future<void> _checkLocationPermission() async {
    if (_hasRequestedLocationPermission) return;

    try {
      final PermissionStatus status = await Permission.location.status;
      setState(() {
        _hasLocationPermission = status.isGranted;
        _hasRequestedLocationPermission = true;
      });
    } catch (e) {
      print('检查位置权限出错: $e');
    }
  }

  // 请求位置权限
  Future<void> _requestLocationPermission() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final PermissionStatus status = await Permission.location.request();
      
      setState(() {
        _hasLocationPermission = status.isGranted;
        _hasRequestedLocationPermission = true;
        _isLoading = false;
      });

      if (status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('感谢您允许我们访问位置信息，现在可以为您推荐附近的景点。'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '请求位置权限失败: $e';
      });
    }
  }

  // 显示权限对话框
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('需要位置权限'),
        content: Text('为了向您推荐附近的景点，我们需要访问您的位置信息。请在设置中开启位置权限。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('暂不开启'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
            ),
            child: Text('去设置'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当页面变为当前页面时，重置并播放动画
    if (widget.isCurrentPage && !oldWidget.isCurrentPage) {
      _contentAnimController.reset();
      _contentAnimController.forward();
      // 确保背景动画在页面可见时运行
      if (!_backgroundAnimController.isAnimating) {
        _backgroundAnimController.repeat(reverse: true);
      }
    } else if (!widget.isCurrentPage && oldWidget.isCurrentPage) {
      // 当页面不再是当前页面时，暂停耗费资源的背景动画
      _backgroundAnimController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，因为使用了AutomaticKeepAliveClientMixin
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          // 添加动态渐变背景，实现背景微动效果
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
          ),
        ),
        child: Stack(
          children: [
            // 动态光晕效果
            if (widget.isCurrentPage) _buildAnimatedBackground(),

            // 主要内容
            RefreshIndicator(
              onRefresh: _refreshData,
              color: AppTheme.buttonColor,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 顶部应用栏
                  _buildSliverAppBar(),

                  // 搜索栏
                  _buildSearchBar(),

                  // 特色景点
                  _buildFeaturedSpots(),

                  // 探索分类
                  _buildExploreCategories(),

                  // 热门城市
                  _buildPopularCities(),

                  // 底部间距
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
            
            // 返回顶部按钮
            if (_showBackToTop)
              Positioned(
                bottom: 100,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "backToTop",
                  backgroundColor: AppTheme.buttonColor,
                  onPressed: _scrollToTop,
                  child: Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _hasLocationPermission ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton(
          heroTag: "mapView",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MapViewScreen(
                  spots: _featuredSpots,
                  initialSpotIndex: 0,
                ),
              ),
            );
          },
          backgroundColor: AppTheme.buttonColor,
          child: Icon(Icons.map, color: Colors.white),
        ),
      ),
    );
  }

  // 构建动态背景效果 - 优化渲染性能
  Widget _buildAnimatedBackground() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              // 动态光晕效果1
              Positioned(
                left: MediaQuery.of(context).size.width *
                    (0.3 + 0.3 * math.sin(_backgroundAnimation.value * math.pi)),
                top: MediaQuery.of(context).size.height *
                    (0.3 + 0.2 * math.cos(_backgroundAnimation.value * math.pi)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.neonBlue.withOpacity(0.3),
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
                right: MediaQuery.of(context).size.width *
                    (0.2 + 0.3 * math.cos(_backgroundAnimation.value * math.pi)),
                bottom: MediaQuery.of(context).size.height *
                    (0.2 + 0.2 * math.sin(_backgroundAnimation.value * math.pi)),
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
    );
  }

  // 构建应用栏
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '探索',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '发现周边美景和热门目的地',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: FadeTransition(
          opacity: _contentAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(_contentAnimation),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '搜索目的地、景点、活动...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    _performSearch(query);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建特色景点
  Widget _buildFeaturedSpots() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '推荐景点',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 导航到全部景点页面
                  },
                  child: Text(
                    '查看全部',
                    style: TextStyle(
                      color: AppTheme.buttonColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20),
              physics: BouncingScrollPhysics(),
              itemCount: _featuredSpots.length,
              itemBuilder: (context, index) {
                final spot = _featuredSpots[index];
                return _buildSpotCard(spot);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建景点卡片 - 增加RepaintBoundary减少重绘
  Widget _buildSpotCard(Map<String, dynamic> spot) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailScreen(spotData: spot),
          ),
        );
      },
      child: FadeTransition(
        opacity: _contentAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(_contentAnimation),
          child: RepaintBoundary(
            child: Container(
              width: 220,
              margin: EdgeInsets.only(right: 16, bottom: 10),
              decoration: BoxDecoration(
                color: Color(0xFF2A2A45),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图片部分
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // 使用缓存图片
                        CachedNetworkImage(
                          imageUrl: spot['image'],
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.grey.withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.buttonColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.grey.withOpacity(0.3),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white70,
                                size: 40,
                              ),
                            ),
                          ),
                          memCacheHeight: 320, // 设置内存缓存高度
                          memCacheWidth: 440, // 设置内存缓存宽度
                        ),
                        // 渐变遮罩
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 评分
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${spot['rating']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 位置
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                spot['location'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 内容部分
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spot['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neonTeal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    color: AppTheme.neonTeal,
                                    size: 12.0,
                                  ),
                                  const SizedBox(width: 3.0),
                                  Text(
                                    spot['recommendation'] ?? '推荐景点',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.neonTeal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.buttonColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '查看详情',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建探索分类
  Widget _buildExploreCategories() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
            child: Text(
              '探索分类',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20),
              physics: BouncingScrollPhysics(),
              itemCount: _exploreCategories.length,
              itemBuilder: (context, index) {
                final category = _exploreCategories[index];
                return _buildCategoryItem(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建分类项 - 使用RepaintBoundary减少重绘
  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final name = category['name'] as String;
    
    // 使用缓存如果可用
    if (_cachedCategoryItems.containsKey(name)) {
      return FadeTransition(
        opacity: _contentAnimation,
        child: _cachedCategoryItems[name]!,
      );
    }
    
    return FadeTransition(
      opacity: _contentAnimation,
      child: RepaintBoundary(
        child: Container(
          width: 80,
          margin: EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: category['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  category['icon'],
                  color: category['color'],
                  size: 30,
                ),
              ),
              SizedBox(height: 8),
              Text(
                category['name'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建热门城市
  Widget _buildPopularCities() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
            child: Text(
              '热门城市',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 20),
              physics: BouncingScrollPhysics(),
              itemCount: _popularCities.length,
              itemBuilder: (context, index) {
                final city = _popularCities[index];
                return _buildCityItem(city);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建城市项 - 增加RepaintBoundary减少重绘
  Widget _buildCityItem(Map<String, dynamic> city) {
    return FadeTransition(
      opacity: _contentAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(_contentAnimation),
        child: RepaintBoundary(
          child: Container(
            width: 130,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 使用缓存图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: city['image'],
                    height: 160,
                    width: 130,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160,
                      width: 130,
                      color: Colors.grey.withOpacity(0.3),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.buttonColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160,
                      width: 130,
                      color: Colors.grey.withOpacity(0.3),
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 40,
                        ),
                      ),
                    ),
                    memCacheHeight: 320, // 设置内存缓存高度
                    memCacheWidth: 260, // 设置内存缓存宽度
                  ),
                ),
                // 渐变遮罩
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
                // 文字内容
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${city['spotCount']}个景点',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
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

  // 刷新数据
  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求
    try {
      await Future.delayed(Duration(seconds: 2));
      
      if (!mounted) return;

      // 随机变换数据顺序，模拟刷新效果
      setState(() {
        _featuredSpots.shuffle();
        _popularCities.shuffle();
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = '刷新数据失败: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 执行搜索
  void _performSearch(String query) {
    // TODO: 实现搜索功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在搜索: $query'),
        duration: Duration(seconds: 1),
      ),
    );
  }
} 