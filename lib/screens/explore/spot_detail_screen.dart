import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import '../../app_theme.dart';
import 'map_view_screen.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/network_image.dart' as network;
import 'package:animations/animations.dart';
import '../../widgets/glass_card.dart';
import '../../utils/dimensions.dart';
import 'dart:io' show File, Platform;
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  
  // 抽屉交互状态控制
  bool _isClosingDrawer = false;
  double _dragExtent = 0.0;
  
  // 添加刷新状态控制
  bool _isRefreshing = false;

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

    // 初始化图片画廊 - 使用更稳定的Picsum图片URL
    _imageGallery = [
      // 默认图片 - 使用景点图片或默认图片
      _getSpotImage(),
      // 固定的稳定图片URL - 使用Picsum API的ID模式
      'https://picsum.photos/id/1036/800/600', // 风景
      'https://picsum.photos/id/1039/800/600', // 自然风光
      'https://picsum.photos/id/1043/800/600', // 城市景观
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
    final screenWidth = MediaQuery.of(context).size.width;
    // 使用屏幕大小判断而不是平台判断
    final isSmallScreen = screenWidth < 340;
    final isMediumScreen = screenWidth >= 340 && screenWidth < 400;
    final isLargeScreen = screenWidth >= 400;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: _buildAnimatedAppBar(statusBarHeight),
      ),
      body: Stack(
        children: [
          // 主内容
          RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.buttonColor,
            backgroundColor: Colors.white,
            strokeWidth: 3,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部图片区域
                  _buildHeroImageSection(),
                  
                  // 使用动画包装内容
                  FadeTransition(
                    opacity: _pageAnimController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _pageAnimController,
                        curve: Curves.easeOutCubic,
                      )),
                      child: Column(
                        children: [
                          // 景点名称和评分
                          _buildTitleSection(),
                          
                          // 功能快捷按钮区
                          _buildQuickActionButtons(),
                          
                          // 景点信息区
                          _buildInfoSection(),
                          
                          // 景点详情描述
                          _buildDescriptionSection(),
                          
                          // 用户评论区
                          _buildReviewSection(),
                          
                          // 周边推荐区
                          _buildRecommendationSection(),
                        ],
                      ),
                    ),
                  ),
                  
                  // 底部间距 - 根据设备调整
                  SizedBox(height: 30 + bottomPadding),
                ],
              ),
            ),
          ),

          // 底部抽屉
          if (_isBottomDrawerVisible)
            _buildBottomDrawer(context, bottomPadding),
        ],
      ),
      floatingActionButton: Transform.scale(
        scale: isSmallScreen ? 0.9 : 1.1, // 根据屏幕大小调整按钮大小
        child: FloatingActionButton(
        onPressed: _showBottomDrawer,
        backgroundColor: AppTheme.buttonColor,
        child: Icon(Icons.more_horiz, color: Colors.white),
        // 添加弹出动画
        heroTag: 'fab',
          mini: isSmallScreen, // 在小屏幕上使用mini属性
        ),
      ),
    );
  }
  
  // 构建顶部图片英雄区域
  Widget _buildHeroImageSection() {
    return Container(
      height: MCPDimension.imageHeightHero,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
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
                fit: StackFit.expand,
                children: [
                  // 背景颜色
                  Container(color: AppTheme.cardColor.withOpacity(0.3)),
                  
                  // 图片 - 使用NetworkImage组件显示
                  Hero(
                    tag: 'spot_image_${widget.spotData['id'] ?? index}',
                    child: network.NetworkImage(
                      imageUrl: _imageGallery[index],
                      fit: BoxFit.cover,
                      placeholder: _buildImageLoadingIndicator(),
                      errorWidget: Container(
                        color: AppTheme.cardColor.withOpacity(0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image,
                                color: AppTheme.secondaryTextColor,
                                size: MCPDimension.iconSizeXLarge,
                              ),
                              SizedBox(height: MCPDimension.spacingSmall),
                              Text(
                                '图片无法显示',
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: MCPDimension.fontSizeMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 添加图片滤镜效果 - 提升艺术感
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // 图片指示器 - 改用更现代的设计
          Positioned(
            bottom: MCPDimension.spacingXXLarge * 5,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildImageIndicators(),
            ),
          ),
          
          // 景点名称卡片 - 玻璃态效果
          Positioned(
            bottom: MCPDimension.spacingXLarge,
            left: MCPDimension.spacingXLarge,
            right: MCPDimension.spacingXLarge,
            child: GlassCard(
              blur: 8.0,
              opacity: 0.15,
              borderRadius: MCPDimension.radiusXLarge,
              padding: MCPDimension.paddingLarge,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getSpotName(),
                          style: TextStyle(
                            fontSize: MCPDimension.fontSizeTitle,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: MCPDimension.spacingXSmall),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on, 
                              size: MCPDimension.iconSizeSmall, 
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(width: MCPDimension.spacingXSmall),
                            Expanded(
                              child: Text(
                                _getSpotLocation(),
                                style: TextStyle(
                                  fontSize: MCPDimension.fontSizeMedium,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MCPDimension.spacingMedium, 
                      vertical: MCPDimension.spacingSmall
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.neonOrange,
                      borderRadius: BorderRadius.circular(MCPDimension.radiusMedium),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star, 
                          color: Colors.white, 
                          size: MCPDimension.iconSizeMedium
                        ),
                        SizedBox(width: MCPDimension.spacingXSmall),
                        Text(
                          _getSpotRating(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MCPDimension.fontSizeMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 图片指示器列表 - 更现代的设计
  List<Widget> _buildImageIndicators() {
    return List.generate(
      _imageGallery.length,
      (index) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: MCPDimension.spacingXSmall),
        height: MCPDimension.spacingSmall,
        width: _currentImageIndex == index ? MCPDimension.spacingXXLarge : MCPDimension.spacingSmall,
        decoration: BoxDecoration(
          color: _currentImageIndex == index 
              ? AppTheme.neonOrange 
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(MCPDimension.radiusXSmall),
        ),
      ),
    );
  }
  
  // 建立标题部分
  Widget _buildTitleSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    // 基于屏幕宽度动态计算边距，而不是基于平台
    final horizontalMargin = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    
    return Container(
      margin: EdgeInsets.fromLTRB(
        horizontalMargin, 
        MCPDimension.spacingXLarge, 
        horizontalMargin, 
        MCPDimension.spacingMedium
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 价格与游览时间信息卡片
          Container(
            width: double.infinity, // 确保宽度填满父容器
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge, 
              vertical: MCPDimension.spacingMedium
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: MCPDimension.elevationLarge,
                  spreadRadius: 0,
                  offset: Offset(0, MCPDimension.elevationMedium),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardColor,
                  AppTheme.cardColor.withOpacity(0.9),
                ],
              ),
            ),
            child: screenWidth < 340 
                ? Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.attach_money_rounded,
                        title: '门票',
                        value: '¥${_getSpotPrice()}',
                        color: AppTheme.neonTeal,
                      ),
                      SizedBox(height: MCPDimension.spacingSmall),
                      Divider(
                        color: AppTheme.secondaryTextColor.withOpacity(0.2),
                        height: 1,
                      ),
                      SizedBox(height: MCPDimension.spacingSmall),
                      _buildInfoCard(
                        icon: Icons.access_time_rounded,
                        title: '开放时间',
                        value: _getSpotHours(),
                        color: AppTheme.neonOrange,
                      ),
                      SizedBox(height: MCPDimension.spacingSmall),
                      Divider(
                        color: AppTheme.secondaryTextColor.withOpacity(0.2),
                        height: 1,
                      ),
                      SizedBox(height: MCPDimension.spacingSmall),
                      _buildInfoCard(
                        icon: Icons.timelapse_rounded,
                        title: '建议游览',
                        value: _getSpotDuration(),
                        color: AppTheme.neonPurple,
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoCard(
                        icon: Icons.attach_money_rounded,
                        title: '门票',
                        value: '¥${_getSpotPrice()}',
                        color: AppTheme.neonTeal,
                      ),
                      Container(
                        height: MCPDimension.cardHeightSmall * 0.5,
                        width: 1,
                        color: AppTheme.secondaryTextColor.withOpacity(0.2),
                      ),
                      _buildInfoCard(
                        icon: Icons.access_time_rounded,
                        title: '开放时间',
                        value: _getSpotHours(),
                        color: AppTheme.neonOrange,
                      ),
                      Container(
                        height: MCPDimension.cardHeightSmall * 0.5,
                        width: 1,
                        color: AppTheme.secondaryTextColor.withOpacity(0.2),
                      ),
                      _buildInfoCard(
                        icon: Icons.timelapse_rounded,
                        title: '建议游览',
                        value: _getSpotDuration(),
                        color: AppTheme.neonPurple,
                      ),
                    ],
                  ),
          ),

          SizedBox(height: MCPDimension.spacingLarge),
          
          // 标签列表 - 修复跨平台滚动问题和居中问题
          Container(
            height: MCPDimension.cardHeightSmall * 0.45,
            width: double.infinity,
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: MCPDimension.spacingXSmall),
                children: _getSpotTags().map((tag) {
                  // 创建固定高度的容器确保所有标签高度一致
                  return Container(
                    height: 32, // 固定高度
                    margin: EdgeInsets.only(right: MCPDimension.spacingMedium),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
                      border: Border.all(
                        color: AppTheme.neonBlue.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    // 使用Align确保内容垂直居中
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MCPDimension.spacingLarge,
                          vertical: MCPDimension.spacingXSmall,
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: MCPDimension.fontSizeSmall,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.neonBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建信息卡片
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: MCPDimension.paddingSmall,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: MCPDimension.iconSizeMedium,
          ),
        ),
        SizedBox(height: MCPDimension.spacingXSmall),
        Text(
          title,
          style: TextStyle(
            fontSize: MCPDimension.fontSizeXSmall,
            color: AppTheme.secondaryTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: MCPDimension.spacingXXSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth < 340 ? MCPDimension.fontSizeXSmall : MCPDimension.fontSizeSmall,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
  
  // 快捷操作按钮
  Widget _buildQuickActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    final horizontalMargin = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    final buttonSpacing = screenWidth > 360 ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceAround;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        horizontalMargin, 
        MCPDimension.spacingXSmall, 
        horizontalMargin, 
        MCPDimension.spacingLarge
      ),
      padding: EdgeInsets.symmetric(
        vertical: MCPDimension.spacingLarge,
        horizontal: screenWidth < 340 ? MCPDimension.spacingXSmall : MCPDimension.spacingSmall
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(MCPDimension.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: MCPDimension.elevationLarge,
            spreadRadius: 0,
            offset: Offset(0, MCPDimension.elevationMedium),
          ),
        ],
      ),
      child: screenWidth < 340
          ? Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: MCPDimension.spacingMedium,
              runSpacing: MCPDimension.spacingMedium,
              children: [
                _buildActionButton(
                  Icons.map_rounded,
                  '导航',
                  AppTheme.neonBlue,
                  () => _launchMaps(),
                ),
                _buildActionButton(
                  Icons.share_rounded,
                  '分享',
                  AppTheme.neonPurple,
                  () => _shareSpot(),
                ),
                _buildActionButton(
                  Icons.favorite_rounded,
                  _isFavorite ? '已收藏' : '收藏',
                  _isFavorite ? AppTheme.neonPink : AppTheme.secondaryTextColor,
                  () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? '已添加到收藏' : '已取消收藏'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  Icons.camera_alt_rounded,
                  '拍照',
                  AppTheme.neonGreen,
                  () => _openCamera(),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: buttonSpacing,
              children: [
                _buildActionButton(
                  Icons.map_rounded,
                  '导航',
                  AppTheme.neonBlue,
                  () => _launchMaps(),
                ),
                _buildActionButton(
                  Icons.share_rounded,
                  '分享',
                  AppTheme.neonPurple,
                  () => _shareSpot(),
                ),
                _buildActionButton(
                  Icons.favorite_rounded,
                  _isFavorite ? '已收藏' : '收藏',
                  _isFavorite ? AppTheme.neonPink : AppTheme.secondaryTextColor,
                  () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? '已添加到收藏' : '已取消收藏'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  Icons.camera_alt_rounded,
                  '拍照',
                  AppTheme.neonGreen,
                  () => _openCamera(),
                ),
              ],
            ),
    );
  }
  
  // 单个操作按钮
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(MCPDimension.radiusMedium),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MCPDimension.spacingSmall, 
          horizontal: MCPDimension.spacingSmall
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: MCPDimension.paddingMedium,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: MCPDimension.iconSizeMedium,
              ),
            ),
            SizedBox(height: MCPDimension.spacingSmall),
            Text(
              label,
              style: TextStyle(
                fontSize: MCPDimension.fontSizeSmall,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 添加打开相机的方法
  Future<void> _openCamera() async {
    try {
      // 请求相机权限(权限处理在main.dart中已配置)
      
      // 使用ImagePicker拍照
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
      // 处理拍照结果
      if (photo != null) {
        // 照片拍摄成功，显示成功信息和分享选项
        _showPhotoOptionsDialog(photo);
      } else {
        // 用户取消了拍照
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已取消拍照'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          )
        );
      }
    } on PlatformException catch (e) {
      // 权限被拒绝或其他错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法使用相机: ${e.message}'),
          behavior: SnackBarBehavior.floating,
        )
      );
    } catch (e) {
      // 其他错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发生错误: $e'),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
  
  // 显示照片操作选项对话框
  void _showPhotoOptionsDialog(XFile photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 照片预览缩略图
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photo.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '拍摄成功!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '你想要怎么处理这张照片?',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // 操作按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoActionButton(
                    icon: Icons.share,
                    label: '分享照片',
                    onTap: () {
                      Navigator.pop(context);
                      _sharePhoto(photo);
                    },
                  ),
                  _buildPhotoActionButton(
                    icon: Icons.delete,
                    label: '删除',
                    onTap: () {
                      Navigator.pop(context);
                      _deletePhoto(photo);
                    },
                  ),
                  _buildPhotoActionButton(
                    icon: Icons.close,
                    label: '关闭',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
  
  // 构建照片操作按钮
  Widget _buildPhotoActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 85,
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppTheme.neonBlue,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 分享照片
  void _sharePhoto(XFile photo) {
    final spotName = _getSpotName();
    final location = _getSpotLocation();
    
    final String shareText = 
        '我在$spotName拍摄的照片\n'
        '位置: $location\n'
        '来自Travel Joy旅行应用';
    
    // 使用share_plus分享照片和文本
    Share.shareXFiles(
      [photo],
      text: shareText,
      subject: '我的旅行照片 - $spotName',
    ).then((_) {
      // 分享成功
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('照片分享成功!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        )
      );
    }).catchError((error) {
      // 分享失败
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('照片分享失败: $error'),
          behavior: SnackBarBehavior.floating,
        )
      );
    });
  }
  
  // 删除照片
  void _deletePhoto(XFile photo) {
    try {
      // 创建File对象
      final File photoFile = File(photo.path);
      
      // 检查文件是否存在
      if (photoFile.existsSync()) {
        // 删除文件
        photoFile.deleteSync();
        
        // 显示删除成功的消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('照片已删除'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          )
        );
      } else {
        // 文件不存在
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('照片不存在或已被删除'),
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } catch (e) {
      // 处理删除过程中发生的错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除照片失败: $e'),
          behavior: SnackBarBehavior.floating,
        )
      );
    }
  }
  
  // 景点信息区
  Widget _buildInfoSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 基于屏幕宽度动态计算边距，而不是基于平台
    final horizontalPadding = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(bottom: MCPDimension.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(MCPDimension.spacingLarge),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
              border: Border.all(
                color: AppTheme.neonBlue.withOpacity(0.1),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardColor.withOpacity(0.9),
                  AppTheme.cardColor.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: MCPDimension.elevationLarge,
                  spreadRadius: 0,
                  offset: Offset(0, MCPDimension.elevationSmall),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '景点基本信息',
                  style: TextStyle(
                    fontSize: MCPDimension.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                SizedBox(height: MCPDimension.spacingMedium),
                _buildInfoRow(Icons.place_outlined, '地址', _getSpotLocation()),
                SizedBox(height: MCPDimension.spacingMedium),
                _buildInfoRow(Icons.access_time_rounded, '最佳游览时间', _getSpotBestTime()),
                SizedBox(height: MCPDimension.spacingMedium),
                _buildInfoRow(Icons.group_outlined, '适合人群', '所有年龄段，尤其是${_getSpotSuitableFor()}'),
                SizedBox(height: MCPDimension.spacingMedium),
                _buildInfoRow(Icons.phone_outlined, '联系电话', _getSpotContact()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(IconData icon, String title, String content) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    
    return isSmallScreen
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(MCPDimension.spacingXSmall),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: AppTheme.neonBlue,
                      size: MCPDimension.iconSizeSmall,
                    ),
                  ),
                  SizedBox(width: MCPDimension.spacingSmall),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MCPDimension.fontSizeSmall,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MCPDimension.spacingXXSmall),
              Padding(
                padding: EdgeInsets.only(left: MCPDimension.spacingXXLarge),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: MCPDimension.fontSizeMedium,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(MCPDimension.spacingXSmall),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: AppTheme.neonBlue,
                  size: MCPDimension.iconSizeSmall,
                ),
              ),
              SizedBox(width: MCPDimension.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: MCPDimension.fontSizeSmall,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: MCPDimension.spacingXXSmall),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: MCPDimension.fontSizeMedium,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }

  // 构建描述部分
  Widget _buildDescriptionSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 基于屏幕宽度动态计算边距，而不是基于平台
    final horizontalPadding = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    final isSmallScreen = screenWidth < 340;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(bottom: MCPDimension.spacingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '景点详情',
            style: TextStyle(
              fontSize: isSmallScreen ? MCPDimension.fontSizeLarge : MCPDimension.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          SizedBox(height: MCPDimension.spacingLarge),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: MCPDimension.elevationLarge,
                  spreadRadius: 0,
                  offset: Offset(0, MCPDimension.elevationSmall),
                ),
              ],
            ),
            child: Text(
              _getSpotDescription(),
              style: TextStyle(
                fontSize: isSmallScreen ? MCPDimension.fontSizeSmall : MCPDimension.fontSizeMedium,
                color: AppTheme.primaryTextColor,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建评论部分
  Widget _buildReviewSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 基于屏幕宽度动态计算边距，而不是基于平台
    final horizontalPadding = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    final isSmallScreen = screenWidth < 340;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(bottom: MCPDimension.spacingXXLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '游客评论',
                style: TextStyle(
                  fontSize: isSmallScreen ? MCPDimension.fontSizeLarge : MCPDimension.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 查看全部评论
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('查看全部评论')),
                  );
                },
                child: Text(
                  '查看全部 >',
                  style: TextStyle(
                    color: AppTheme.buttonColor,
                    fontWeight: FontWeight.w500,
                    fontSize: isSmallScreen ? MCPDimension.fontSizeSmall : MCPDimension.fontSizeMedium,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: isSmallScreen 
                      ? EdgeInsets.symmetric(horizontal: MCPDimension.spacingSmall, vertical: MCPDimension.spacingXSmall)
                      : null,
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
          SizedBox(height: MCPDimension.spacingMedium),
          // 评论列表
          ..._reviews.map((review) => _buildReviewCard(review)).toList(),
        ],
      ),
    );
  }
  
  // 构建推荐部分
  Widget _buildRecommendationSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    // 基于屏幕宽度动态计算边距，而不是基于平台
    final horizontalPadding = screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge;
    final isSmallScreen = screenWidth < 340;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      margin: EdgeInsets.only(bottom: MCPDimension.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '附近景点推荐',
            style: TextStyle(
              fontSize: isSmallScreen ? MCPDimension.fontSizeLarge : MCPDimension.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          SizedBox(height: MCPDimension.spacingLarge),
          // 推荐景点列表
          Container(
            height: isSmallScreen ? 180 : 200, // 在小屏幕上略微减小高度
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: MCPDimension.spacingXSmall),
              children: [
                _buildRecommendationCard(
                  'https://picsum.photos/id/1061/300/200',
                  '山水风景区',
                  '距离: 5.2 公里',
                  4.7,
                ),
                _buildRecommendationCard(
                  'https://picsum.photos/id/1058/300/200',
                  '历史博物馆',
                  '距离: 3.8 公里',
                  4.5,
                ),
                _buildRecommendationCard(
                  'https://picsum.photos/id/1050/300/200',
                  '城市公园',
                  '距离: 2.1 公里',
                  4.8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建动画AppBar
  Widget _buildAnimatedAppBar(double statusBarHeight) {
    // 计算透明度 - 基于滚动位置
    final double opacity = (_scrollOffset / 150).clamp(0.0, 1.0);
    final Color titleColor = Color.lerp(
      Colors.transparent, 
      AppTheme.primaryTextColor,
      opacity,
    ) ?? Colors.white;
    
    final Color backgroundColor = Color.lerp(
      Colors.transparent,
      AppTheme.backgroundColor,
      opacity,
    ) ?? Colors.transparent;
    
    final screenWidth = MediaQuery.of(context).size.width;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: opacity > 0.8 ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ] : [],
      ),
      padding: EdgeInsets.only(top: statusBarHeight),
      alignment: Alignment.center,
      child: Container(
        height: kToolbarHeight,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 340 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: opacity,
                  child: Text(
                    _getSpotName(),
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth < 340 ? MCPDimension.fontSizeMedium : MCPDimension.fontSizeLarge,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 返回按钮
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: opacity < 0.5 ? 
                      Colors.black.withOpacity(0.3) : 
                      Colors.transparent,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded, 
                      color: opacity < 0.5 ? 
                        Colors.white : 
                        AppTheme.primaryTextColor,
                      size: screenWidth < 340 ? 18 : 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.all(screenWidth < 340 ? 8 : 12),
                    constraints: BoxConstraints(),
                  ),
                ),
                // 收藏按钮
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: opacity < 0.5 ? 
                      Colors.black.withOpacity(0.3) : 
                      Colors.transparent,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? 
                        Icons.favorite_rounded : 
                        Icons.favorite_border_rounded,
                      color: _isFavorite ? 
                        AppTheme.neonPink : 
                        (opacity < 0.5 ? Colors.white : AppTheme.primaryTextColor),
                      size: screenWidth < 340 ? 18 : 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isFavorite = !_isFavorite;
                      });
                      // 添加触觉反馈
                      HapticFeedback.lightImpact();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_isFavorite ? '已添加到收藏' : '已取消收藏'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    padding: EdgeInsets.all(screenWidth < 340 ? 8 : 12),
                    constraints: BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 获取景点名称
  String _getSpotName() {
    return widget.spotData['name'] ?? '景点名称';
  }
  
  // 获取景点位置
  String _getSpotLocation() {
    return widget.spotData['location'] ?? '景点位置';
  }
  
  // 获取景点评分
  String _getSpotRating() {
    return widget.spotData['rating']?.toString() ?? '4.8';
  }
  
  // 获取景点价格
  String _getSpotPrice() {
    return widget.spotData['price']?.toString() ?? '88';
  }

  // 获取景点开放时间
  String _getSpotHours() {
    return widget.spotData['hours'] ?? '09:00-18:00';
  }
  
  // 获取建议游览时间
  String _getSpotDuration() {
    return widget.spotData['duration'] ?? '2-3小时';
  }

  // 获取景点标签
  List<String> _getSpotTags() {
    return List<String>.from(widget.spotData['tags'] ?? ['自然', '风景', '文化', '热门']);
  }

  // 获取景点描述
  String _getSpotDescription() {
    return widget.spotData['description'] ?? 
    '这是一个令人惊叹的自然景观，周围环绕着壮丽的山脉和清澈的湖泊。这里的空气清新，植被茂盛，是户外活动和放松身心的理想场所。不论是徒步、摄影还是简单地欣赏自然美景，这里都能给您带来独特的体验。\n\n历史上，这里曾是多个古代文明的交汇点，留下了丰富的文化遗产。现在，这里保留着原始的自然风貌，同时也提供了现代化的设施，确保游客在探索过程中既舒适又安全。'
    '根据季节的不同，这里呈现出完全不同的景观：春天百花齐放，夏天绿意盎然，秋天色彩斑斓，冬天银装素裹。每个季节都有其独特的魅力，值得多次造访。\n\n游客可以在这里参加各种活动，包括导游带领的徒步旅行、文化体验、品尝当地美食等。周边还有多家风格各异的餐厅和商店，可以满足不同游客的需求。';
  }

  // 获取最佳游览时间
  String _getSpotBestTime() {
    return widget.spotData['bestTime'] ?? '春季和秋季 (3-5月, 9-11月)';
  }

  // 获取适合人群
  String _getSpotSuitableFor() {
    return widget.spotData['suitableFor'] ?? '摄影爱好者和自然探索者';
  }

  // 获取联系电话
  String _getSpotContact() {
    return widget.spotData['contact'] ?? '0571-88888888';
  }

  // 启动导航
  void _launchMaps() {
    final location = _getSpotLocation();
    final name = _getSpotName();
    
    // 使用通用URL方式，不再区分平台
    String url = 'https://www.google.com/maps/search/?api=1&query=$location';
    _launchExternalApp(url);
  }

  // 分享景点
  void _shareSpot() {
    final spotName = _getSpotName();
    final location = _getSpotLocation();
    final rating = _getSpotRating();
    
    final String shareText = 
      '📍我发现了一个很棒的地方: $spotName\n'
      '⭐评分: $rating\n'
      '📌位置: $location\n'
      '快来和我一起探索吧!\n'
      '来自Travel Joy旅行应用';
    
    Share.share(
      shareText,
      subject: '分享景点: $spotName',
    );
  }

  // 构建图片加载指示器
  Widget _buildImageLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonColor),
            strokeWidth: 3,
          ),
          SizedBox(height: 12),
          Text(
            '加载图片中...',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建评论卡片
  Widget _buildReviewCard(Map<String, dynamic> review) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: MCPDimension.spacingLarge),
      padding: EdgeInsets.all(isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: MCPDimension.elevationLarge,
            spreadRadius: 0,
            offset: Offset(0, MCPDimension.elevationSmall),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息行
          isSmallScreen
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头像和名称
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
                          child: _buildAvatarImage(review['avatar']),
                        ),
                        SizedBox(width: MCPDimension.spacingMedium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['userName'],
                              style: TextStyle(
                                fontSize: MCPDimension.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: MCPDimension.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: MCPDimension.spacingSmall),
                    // 评分
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MCPDimension.spacingMedium,
                        vertical: MCPDimension.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.neonOrange,
                            size: MCPDimension.iconSizeSmall,
                          ),
                          SizedBox(width: 2),
                          Text(
                            review['rating'].toString(),
                            style: TextStyle(
                              fontSize: MCPDimension.fontSizeSmall,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 头像和名称
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
                          child: _buildAvatarImage(review['avatar']),
                        ),
                        SizedBox(width: MCPDimension.spacingMedium),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['userName'],
                              style: TextStyle(
                                fontSize: MCPDimension.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              review['date'],
                              style: TextStyle(
                                fontSize: MCPDimension.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // 评分
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MCPDimension.spacingMedium,
                        vertical: MCPDimension.spacingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppTheme.neonOrange,
                            size: MCPDimension.iconSizeSmall,
                          ),
                          SizedBox(width: 2),
                          Text(
                            review['rating'].toString(),
                            style: TextStyle(
                              fontSize: MCPDimension.fontSizeSmall,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.neonOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          // 评论内容
          SizedBox(height: MCPDimension.spacingMedium),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: isSmallScreen ? MCPDimension.fontSizeSmall : MCPDimension.fontSizeMedium,
              color: AppTheme.primaryTextColor,
              height: 1.5,
            ),
          ),
          // 操作按钮
          SizedBox(height: MCPDimension.spacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildReviewActionButton(Icons.thumb_up_outlined, '有用'),
              SizedBox(width: MCPDimension.spacingLarge),
              _buildReviewActionButton(Icons.reply_outlined, '回复'),
            ],
          ),
        ],
      ),
    );
  }
  
  // 新添加的方法来处理头像加载及错误处理
  Widget _buildAvatarImage(String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.secondaryTextColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 错误处理 - 显示备用头像
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.secondaryTextColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
              ),
              child: Icon(
                Icons.person,
                color: AppTheme.secondaryTextColor,
                size: MCPDimension.iconSizeLarge,
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.secondaryTextColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MCPDimension.radiusCircular),
              ),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.buttonColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 评论操作按钮
  Widget _buildReviewActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label)),
        );
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: MCPDimension.iconSizeSmall,
            color: AppTheme.secondaryTextColor,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: MCPDimension.fontSizeSmall,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // 构建推荐卡片
  Widget _buildRecommendationCard(
    String imageUrl,
    String name,
    String distance,
    double rating,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 340 ? 140.0 : 160.0;
    
    // 创建模拟景点数据，实际应用中应该从API获取
    final recommendedSpotData = {
      'id': '${name.hashCode}',  // 生成唯一ID
      'name': name,
      'location': '杭州市西湖区',
      'rating': rating,
      'price': (rating * 20).toInt(),
      'imageUrl': imageUrl,
      'hours': '09:00-18:00',
      'duration': '2-3小时',
      'tags': ['自然', '景观', '热门'],
      'description': '这是$name的详细介绍。这里环境优美，景色宜人，是休闲娱乐的好去处。',
      'bestTime': '春季和秋季',
      'suitableFor': '所有年龄段游客',
      'contact': '0571-88888888',
    };
    
    return GestureDetector(
      onTap: () {
        // 点击时添加触觉反馈
        HapticFeedback.lightImpact();
        
        // 导航到新的详情页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotDetailScreen(spotData: recommendedSpotData),
          ),
        );
      },
      child: Hero(
        tag: 'spot_card_${recommendedSpotData['id']}',
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: MCPDimension.spacingLarge),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: MCPDimension.elevationLarge,
                  spreadRadius: 0,
                  offset: Offset(0, MCPDimension.elevationSmall),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图片
                Stack(
                  children: [
                    Container(
                      height: 100,
                      width: double.infinity,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: AppTheme.secondaryTextColor.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: AppTheme.secondaryTextColor,
                                size: MCPDimension.iconSizeLarge,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 100,
                            width: double.infinity,
                            color: AppTheme.secondaryTextColor.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.buttonColor,
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // 添加点击提示蒙层
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: AppTheme.buttonColor.withOpacity(0.2),
                          highlightColor: Colors.transparent,
                          onTap: () {}, // 空函数，实际点击由外层GestureDetector处理
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth < 340 ? MCPDimension.spacingSmall : MCPDimension.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 名称
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: screenWidth < 340 ? MCPDimension.fontSizeSmall : MCPDimension.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 距离
                      SizedBox(height: 4),
                      Text(
                        distance,
                        style: TextStyle(
                          fontSize: MCPDimension.fontSizeSmall,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      // 评分
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: MCPDimension.iconSizeSmall,
                                color: AppTheme.neonOrange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: TextStyle(
                                  fontSize: MCPDimension.fontSizeSmall,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.neonOrange,
                                ),
                              ),
                            ],
                          ),
                          // 添加箭头提示可点击查看详情
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: MCPDimension.iconSizeXSmall,
                            color: AppTheme.secondaryTextColor.withOpacity(0.7),
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
    );
  }

  // 构建底部抽屉
  Widget _buildBottomDrawer(BuildContext context, double bottomPadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    final drawerHeight = MediaQuery.of(context).size.height * (isSmallScreen ? 0.7 : 0.6);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _drawerAnimController,
        builder: (context, child) {
          final slideHeight = (1 - _drawerAnimation.value) * drawerHeight;
          return Transform.translate(
            offset: Offset(0, slideHeight),
            child: child,
          );
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (_isClosingDrawer) return;
            
            if (details.delta.dy > 0) {
              setState(() {
                _dragExtent += details.delta.dy;
              });
            }
          },
          onVerticalDragEnd: (details) {
            if (_isClosingDrawer) return;
            
            if (details.primaryVelocity! > 300 || _dragExtent > 150) {
              _closeBottomDrawer();
            } else {
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
                topLeft: Radius.circular(MCPDimension.radiusXXLarge),
                topRight: Radius.circular(MCPDimension.radiusXXLarge),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: MCPDimension.elevationXLarge,
                  spreadRadius: 0,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部把手和标题
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(MCPDimension.radiusXXLarge),
                      topRight: Radius.circular(MCPDimension.radiusXXLarge),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      // 顶部把手
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryTextColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(MCPDimension.radiusXXSmall),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge),
                      Text(
                        '更多服务',
                        style: TextStyle(
                          fontSize: isSmallScreen ? MCPDimension.fontSizeLarge : MCPDimension.fontSizeXLarge,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                // 服务选项列表
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge,
                      vertical: isSmallScreen ? MCPDimension.spacingSmall : MCPDimension.spacingMedium,
                    ),
                    children: [
                      _buildServiceOption(
                        icon: Icons.map_outlined,
                        title: '地图导航',
                        subtitle: '获取前往景点的导航路线',
                        onTap: () => _launchMaps(),
                        isSmallScreen: isSmallScreen,
                      ),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                      _buildServiceOption(
                        icon: Icons.share_outlined,
                        title: '分享景点',
                        subtitle: '与朋友分享这个景点',
                        onTap: () => _shareSpot(),
                        isSmallScreen: isSmallScreen,
                      ),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                      _buildServiceOption(
                        icon: Icons.camera_alt_outlined,
                        title: '拍摄照片',
                        subtitle: '记录美好瞬间',
                        onTap: () {
                          _closeBottomDrawer();
                          _openCamera();
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                      _buildServiceOption(
                        icon: Icons.bookmark_outline,
                        title: _isFavorite ? '取消收藏' : '收藏景点',
                        subtitle: '保存到您的收藏列表',
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFavorite ? '已添加到收藏' : '已取消收藏'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _closeBottomDrawer();
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                    ],
                  ),
                ),
                
                // 底部关闭按钮
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 360 ? MCPDimension.spacingMedium : MCPDimension.spacingLarge,
                    vertical: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.backgroundColor.withOpacity(0),
                        AppTheme.backgroundColor,
                      ],
                      stops: [0.0, 0.3],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _closeBottomDrawer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '关闭',
                            style: TextStyle(
                              fontSize: isSmallScreen ? MCPDimension.fontSizeMedium : MCPDimension.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: MCPDimension.spacingMedium),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(MCPDimension.radiusLarge),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.more_horiz, color: AppTheme.secondaryTextColor),
                          onPressed: () {
                            // 显示更多选项的菜单
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('更多选项'), behavior: SnackBarBehavior.floating)
                            );
                          },
                          padding: EdgeInsets.all(isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 底部安全区域
                SizedBox(height: bottomPadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 服务选项项目
  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSmallScreen = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MCPDimension.radiusMedium),
        splashColor: AppTheme.neonBlue.withOpacity(0.08),
        highlightColor: AppTheme.neonBlue.withOpacity(0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge,
            horizontal: isSmallScreen ? MCPDimension.spacingSmall : MCPDimension.spacingMedium,
          ),
          child: Row(
            children: [
              Container(
                padding: isSmallScreen ? MCPDimension.paddingSmall : MCPDimension.paddingMedium,
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonBlue.withOpacity(0.12),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppTheme.neonBlue,
                  size: isSmallScreen ? MCPDimension.iconSizeSmall : MCPDimension.iconSizeMedium,
                ),
              ),
              SizedBox(width: isSmallScreen ? MCPDimension.spacingMedium : MCPDimension.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isSmallScreen ? MCPDimension.fontSizeSmall : MCPDimension.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isSmallScreen ? MCPDimension.fontSizeXSmall : MCPDimension.fontSizeSmall,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.secondaryTextColor,
                size: isSmallScreen ? MCPDimension.iconSizeSmall/2 : MCPDimension.iconSizeSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 获取景点图片 URL
  String _getSpotImage() {
    return widget.spotData['imageUrl'] ?? 'https://picsum.photos/id/1031/800/600';
  }
}
