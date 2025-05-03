import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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

// 添加UI常量，避免硬编码
class UIConstants {
  // 圆角常量
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // 间距常量
  static const double paddingTiny = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 12.0;
  static const double paddingLarge = 16.0;

  // 字体大小常量
  static const double fontSizeTiny = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;

  // 图标大小常量
  static const double iconSizeTiny = 14.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 18.0;
  static const double iconSizeLarge = 20.0;
}

// 用户激励系统常量
class RewardConstants {
  // 积分奖励
  static const int pointsAddFoodInfo = 10;
  static const int pointsAddReview = 15;
  static const int pointsShareSpot = 5;

  // 经验值奖励
  static const int expAddFoodInfo = 8;
  static const int expAddReview = 12;
  static const int expShareSpot = 3;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('数据已更新')));
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

  // 功能快捷操作按钮区 - 全新设计，更加现代美观
  Widget _buildQuickActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    final horizontalMargin =
        screenWidth < 360
            ? MCPDimension.spacingMedium
            : MCPDimension.spacingLarge;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        horizontalMargin,
        MCPDimension.spacingSmall,
        horizontalMargin,
        MCPDimension.spacingMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModernActionButton(
            Icons.map_rounded,
            '导航',
            AppTheme.neonBlue,
            () => _launchMaps(),
          ),
          _buildModernActionButton(
            Icons.share_rounded,
            '分享',
            AppTheme.neonPurple,
            () => _shareSpot(),
          ),
          _buildModernActionButton(
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
          _buildModernActionButton(
            Icons.camera_alt_rounded,
            '拍照',
            AppTheme.neonGreen,
            () => _openCamera(),
          ),
        ],
      ),
    );
  }

  // 全新现代化操作按钮设计
  Widget _buildModernActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // 使用Grid布局重新设计功能与服务区域 - 更紧凑的版本
  Widget _buildBottomDrawer(BuildContext context, double bottomPadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;
    final drawerHeight =
        MediaQuery.of(context).size.height *
        (isSmallScreen ? 0.55 : 0.45); // 减小抽屉高度

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
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部把手和标题 - 更紧凑
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.cardColor.withOpacity(0.6),
                        AppTheme.backgroundColor,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      // 顶部把手
                      Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            color: AppTheme.neonBlue,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '景点服务',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 服务选项 - 更紧凑的Grid布局
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3, // 增加每行显示的数量
                    padding: EdgeInsets.all(12),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1, // 更方形的布局
                    children: [
                      _buildCompactGridServiceOption(
                        icon: Icons.map_outlined,
                        title: '地图导航',
                        onTap: () => _launchMaps(),
                        color: AppTheme.neonTeal,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.share_outlined,
                        title: '分享景点',
                        onTap: () => _shareSpot(),
                        color: AppTheme.neonPurple,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.camera_alt_outlined,
                        title: '拍照',
                        onTap: () {
                          _closeBottomDrawer();
                          _openCamera();
                        },
                        color: AppTheme.neonGreen,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.bookmark_outline,
                        title: _isFavorite ? '取消收藏' : '收藏',
                        onTap: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isFavorite ? '已添加到收藏' : '已取消收藏'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _closeBottomDrawer();
                        },
                        color:
                            _isFavorite ? AppTheme.neonPink : AppTheme.neonBlue,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.info_outline,
                        title: '景点介绍',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('查看景点详细介绍'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        color: AppTheme.neonOrange,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.star_outline,
                        title: '评价',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('查看游客评价'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        color: Colors.amber,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.local_dining_outlined,
                        title: '美食',
                        onTap: () {
                          _showFoodServiceOptions(context);
                        },
                        color: AppTheme.neonPink,
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.hotel_outlined,
                        title: '住宿',
                        onTap: () {
                          _showAccommodationOptions(context);
                        },
                        color: AppTheme.neonBlue.withOpacity(0.8),
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.directions_car_outlined,
                        title: '交通',
                        onTap: () {
                          _showTransportationOptions(context);
                        },
                        color: AppTheme.neonGreen.withOpacity(0.8),
                      ),
                      _buildCompactGridServiceOption(
                        icon: Icons.close,
                        title: '关闭',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _closeBottomDrawer();
                        },
                        color: AppTheme.secondaryTextColor,
                      ),
                    ],
                  ),
                ),

                // 底部安全区域
                SizedBox(
                  height: bottomPadding > 0 ? bottomPadding / 2 : 0,
                ), // 减少安全区域
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 网格布局服务选项-更紧凑版本
  Widget _buildCompactGridServiceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 美化标签区域
  Widget _buildTagList() {
    // 标签列表显示
    return Container(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildTagChip('历史', AppTheme.neonBlue),
          _buildTagChip('文化', AppTheme.neonPurple),
          _buildTagChip('建筑', AppTheme.neonTeal),
        ],
      ),
    );
  }

  // 美化标签样式
  Widget _buildTagChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 美化功能快捷按钮区域 - 替换原来的_buildQuickActionButtons调用
  Widget _buildFeaturedActions() {
    final iconSize = 20.0;
    final containerSize = 40.0;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionIconButton(
            Icons.map,
            '导航',
            AppTheme.neonTeal,
            iconSize,
            containerSize,
            () => _launchMaps(),
          ),
          _buildActionIconButton(
            Icons.hotel,
            '住宿',
            AppTheme.neonPurple,
            iconSize,
            containerSize,
            () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('查看附近住宿')));
            },
          ),
          _buildActionIconButton(
            Icons.history,
            '历史',
            AppTheme.neonBlue,
            iconSize,
            containerSize,
            () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('查看历史背景')));
            },
          ),
          _buildActionIconButton(
            Icons.camera_alt,
            '拍照',
            AppTheme.neonGreen,
            iconSize,
            containerSize,
            () => _openCamera(),
          ),
        ],
      ),
    );
  }

  // 美化操作按钮
  Widget _buildActionIconButton(
    IconData icon,
    String label,
    Color color,
    double iconSize,
    double containerSize,
    VoidCallback onTap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(containerSize / 2),
          child: Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(child: Icon(icon, color: color, size: iconSize)),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.primaryTextColor),
        ),
      ],
    );
  }

  // 更紧凑的标签设计
  Widget _buildCompactTagChip(String label, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 6), // 减少右边距
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 减少内边距
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10, // 减小字体大小
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 更紧凑的信息行
  Widget _buildCompactInfoRow(IconData icon, String title, String content) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 340;

    return isSmallScreen
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4), // 减少内边距
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.neonBlue,
                    size: 12,
                  ), // 减小图标大小
                ),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 22), // 减少左边距
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 12,
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
              padding: EdgeInsets.all(4), // 减少内边距
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.neonBlue, size: 12), // 减小图标大小
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  // 更紧凑的信息卡片
  Widget _buildCompactInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6), // 减少内边距
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 14), // 减小图标大小
        ),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: AppTheme.secondaryTextColor),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
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

  // 构建动画AppBar
  Widget _buildAnimatedAppBar(double statusBarHeight) {
    // 计算透明度 - 基于滚动位置
    final double opacity = (_scrollOffset / 150).clamp(0.0, 1.0);
    final Color titleColor =
        Color.lerp(Colors.transparent, AppTheme.primaryTextColor, opacity) ??
        Colors.white;

    final Color backgroundColor =
        Color.lerp(Colors.transparent, AppTheme.backgroundColor, opacity) ??
        Colors.transparent;

    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow:
            opacity > 0.8
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ]
                : [],
      ),
      padding: EdgeInsets.only(top: statusBarHeight),
      alignment: Alignment.center,
      child: Container(
        height: kToolbarHeight,
        padding: EdgeInsets.symmetric(horizontal: screenWidth < 340 ? 12 : 16),
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
                      fontSize: screenWidth < 340 ? 14 : 16,
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
                    color:
                        opacity < 0.5
                            ? Colors.black.withOpacity(0.3)
                            : Colors.transparent,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color:
                          opacity < 0.5
                              ? Colors.white
                              : AppTheme.primaryTextColor,
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
                    color:
                        opacity < 0.5
                            ? Colors.black.withOpacity(0.3)
                            : Colors.transparent,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color:
                          _isFavorite
                              ? AppTheme.neonPink
                              : (opacity < 0.5
                                  ? Colors.white
                                  : AppTheme.primaryTextColor),
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

    Share.share(shareText, subject: '分享景点: $spotName');
  }

  // 获取景点评分
  String _getSpotRating() {
    return widget.spotData['rating']?.toString() ?? '4.8';
  }

  // 获取景点名称
  String _getSpotName() {
    return widget.spotData['name'] ?? '景点名称';
  }

  // 获取景点位置
  String _getSpotLocation() {
    return widget.spotData['location'] ?? '景点位置';
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

  // 获取景点描述
  String _getSpotDescription() {
    return widget.spotData['description'] ??
        '这是一个令人惊叹的自然景观，周围环绕着壮丽的山脉和清澈的湖泊。这里的空气清新，植被茂盛，是户外活动和放松身心的理想场所。不论是徒步、摄影还是简单地欣赏自然美景，这里都能给您带来独特的体验。\n\n历史上，这里曾是多个古代文明的交汇点，留下了丰富的文化遗产。现在，这里保留着原始的自然风貌，同时也提供了现代化的设施，确保游客在探索过程中既舒适又安全。'
            '根据季节的不同，这里呈现出完全不同的景观：春天百花齐放，夏天绿意盎然，秋天色彩斑斓，冬天银装素裹。每个季节都有其独特的魅力，值得多次造访。';
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
          ),
        );
      }
    } on PlatformException catch (e) {
      // 权限被拒绝或其他错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('无法使用相机: ${e.message}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // 其他错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('发生错误: $e'),
          behavior: SnackBarBehavior.floating,
        ),
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

  // 构建照片操作按钮 - 减小尺寸
  Widget _buildPhotoActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10), // 减小边框圆角
      child: Container(
        width: 75, // 减小宽度
        padding: EdgeInsets.symmetric(vertical: 8), // 减小垂直内边距
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8), // 减小内边距
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.neonBlue, size: 20), // 减小图标尺寸
            ),
            SizedBox(height: 6), // 减小间距
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.primaryTextColor,
              ), // 减小字体大小
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
    Share.shareXFiles([photo], text: shareText, subject: '我的旅行照片 - $spotName')
        .then((_) {
          // 分享成功
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('照片分享成功!'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
            ),
          );
        })
        .catchError((error) {
          // 分享失败
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('照片分享失败: $error'),
              behavior: SnackBarBehavior.floating,
            ),
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
          ),
        );
      } else {
        // 文件不存在
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('照片不存在或已被删除'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 处理删除过程中发生的错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('删除照片失败: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 获取景点图片 URL
  String _getSpotImage() {
    return widget.spotData['imageUrl'] ??
        'https://picsum.photos/id/1031/800/600';
  }

  // 构建服务网格项
  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36, // 减小宽度
            height: 36, // 减小高度
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: color, size: 18)), // 减小图标大小
          ),
          SizedBox(height: 4), // 减少间距
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 显示美食服务选项
  void _showFoodServiceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部把手和标题栏
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 把手示意
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant,
                              color: AppTheme.neonPink,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '周边美食推荐',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neonPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '用户提供',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.neonPink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 美食列表
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(16),
                      children: [
                        // 暂无数据提示
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.no_food,
                                color: Colors.grey.withOpacity(0.5),
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '暂无周边美食信息',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '您可以分享您发现的美食信息，帮助其他游客',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.secondaryTextColor
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 添加美食信息按钮
                        ElevatedButton.icon(
                          icon: Icon(Icons.add, size: 16),
                          label: Text('添加美食信息'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.buttonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddFoodInfoDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 显示住宿服务选项
  void _showAccommodationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(UIConstants.borderRadiusLarge),
                  topRight: Radius.circular(UIConstants.borderRadiusLarge),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 顶部把手和标题栏
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: UIConstants.paddingMedium,
                      horizontal: UIConstants.paddingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(UIConstants.borderRadiusLarge),
                        topRight: Radius.circular(UIConstants.borderRadiusLarge),
                      ),
                    ),
                    child: Column(
                      children: [
                        // 把手示意
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: UIConstants.paddingMedium),
                        Row(
                          children: [
                            Icon(
                              Icons.hotel,
                              color: AppTheme.neonBlue,
                              size: UIConstants.iconSizeMedium,
                            ),
                            SizedBox(width: UIConstants.paddingSmall),
                            Text(
                              '周边住宿推荐',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: UIConstants.paddingSmall,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.neonBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: UIConstants.iconSizeTiny,
                                    color: AppTheme.neonBlue,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '第三方平台',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeTiny,
                                      color: AppTheme.neonBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 外部API集成示意(实际项目中这里需要接入真实API)
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(UIConstants.paddingLarge),
                      children: [
                        // 数据合作说明
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          margin: EdgeInsets.only(bottom: UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(UIConstants.paddingSmall),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.handshake_outlined,
                                  color: Colors.blue,
                                  size: UIConstants.iconSizeMedium,
                                ),
                              ),
                              SizedBox(width: UIConstants.paddingSmall),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '数据合作说明',
                                      style: TextStyle(
                                        fontSize: UIConstants.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '我们与携程、去哪儿等平台建立了数据合作，但当前API对接仍在进行中。点击下方按钮将跳转至对应平台查看住宿信息。',
                                      style: TextStyle(
                                        fontSize: UIConstants.fontSizeTiny,
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // 推荐酒店（模拟数据）
                        SizedBox(height: UIConstants.paddingSmall),
                        Text(
                          '周边热门酒店',
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: UIConstants.paddingSmall),
                        
                        // 酒店列表
                        _buildHotelItem(
                          '西湖湖畔酒店',
                          '4.8',
                          '￥688',
                          '距景区200米，可欣赏西湖全景',
                          AppTheme.neonBlue,
                        ),
                        _buildHotelItem(
                          '杭州国际青年旅舍',
                          '4.5',
                          '￥128',
                          '背包客首选，交通便利',
                          Colors.amber,
                        ),
                        _buildHotelItem(
                          '西子湖四季酒店',
                          '4.9',
                          '￥1688',
                          '五星级酒店，提供豪华服务',
                          AppTheme.neonPink,
                        ),
                        
                        SizedBox(height: UIConstants.paddingMedium),
                        Text(
                          '以上数据仅为示例，请点击下方按钮查看真实信息',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeTiny,
                            color: AppTheme.secondaryTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: UIConstants.paddingMedium),
                        
                        // 选择跳转平台
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '前往预订平台',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              SizedBox(height: UIConstants.paddingMedium),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildPlatformButton(
                                    '携程', 
                                    AppTheme.neonBlue, 
                                    () => _launchBookingApp('ctrip://', '携程'),
                                  ),
                                  _buildPlatformButton(
                                    '去哪儿', 
                                    Colors.green, 
                                    () => _launchBookingApp('qunar://', '去哪儿'),
                                  ),
                                  _buildPlatformButton(
                                    '美团', 
                                    Colors.amber, 
                                    () => _launchBookingApp('imeituan://', '美团'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // 添加贡献信息和积分奖励
                        SizedBox(height: UIConstants.paddingLarge),
                        OutlinedButton.icon(
                          icon: Icon(
                            Icons.add,
                            size: UIConstants.iconSizeSmall,
                          ),
                          label: Text('添加住宿推荐'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.neonBlue,
                            side: BorderSide(
                              color: AppTheme.neonBlue.withOpacity(0.5),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
                            ),
                            padding: EdgeInsets.symmetric(vertical: UIConstants.paddingMedium),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddAccommodationDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // 构建酒店项
  Widget _buildHotelItem(
    String name,
    String rating,
    String price,
    String description,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: UIConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _launchBookingApp('ctrip://', '携程'),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        child: Padding(
          padding: EdgeInsets.all(UIConstants.paddingMedium),
          child: Row(
            children: [
              // 酒店图标
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                ),
                child: Center(
                  child: Icon(
                    Icons.hotel,
                    color: color,
                    size: UIConstants.iconSizeLarge,
                  ),
                ),
              ),
              SizedBox(width: UIConstants.paddingMedium),
              // 酒店信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: UIConstants.paddingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                rating,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(UIConstants.paddingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: UIConstants.iconSizeMedium),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: UIConstants.fontSizeMedium,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: UIConstants.fontSizeTiny,
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  // 整体优化UI界面
  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
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
                  // 顶部图片区域 - 减少高度
                  Container(
                    height: MCPDimension.imageHeightHero * 0.85, // 减少高度
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
                                Container(
                                  color: AppTheme.cardColor.withOpacity(0.3),
                                ),
                                Hero(
                                  tag:
                                      'spot_image_${widget.spotData['id'] ?? index}',
                                  child: network.NetworkImage(
                                    imageUrl: _imageGallery[index],
                                    fit: BoxFit.cover,
                                    placeholder: _buildImageLoadingIndicator(),
                                    errorWidget: Container(
                                      color: AppTheme.cardColor.withOpacity(
                                        0.5,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.image,
                                          color: AppTheme.secondaryTextColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
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

                        // 移动到底部的景点信息卡片
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: GlassCard(
                            blur: 8.0,
                            opacity: 0.15,
                            borderRadius: 16,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getSpotName(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.white.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                          SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              _getSpotLocation(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withOpacity(
                                                  0.8,
                                                ),
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
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonOrange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        _getSpotRating(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),

                  // 使用动画包装内容
                  FadeTransition(
                    opacity: _pageAnimController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _pageAnimController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: Column(
                        children: [
                          // 价格、时间和标签部分整合为一个更紧凑的容器
                          Container(
                            margin: EdgeInsets.fromLTRB(12, 12, 12, 8), // 减少边距
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 价格与时间卡片
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12), // 减少内边距
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child:
                                      screenWidth < 340
                                          ? Column(
                                            children: [
                                              _buildCompactInfoCard(
                                                icon:
                                                    Icons.attach_money_rounded,
                                                title: '门票',
                                                value: '¥${_getSpotPrice()}',
                                                color: AppTheme.neonTeal,
                                              ),
                                              Divider(
                                                height: 12,
                                                thickness: 0.5,
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withOpacity(0.2),
                                              ),
                                              _buildCompactInfoCard(
                                                icon: Icons.access_time_rounded,
                                                title: '开放时间',
                                                value: _getSpotHours(),
                                                color: AppTheme.neonOrange,
                                              ),
                                              Divider(
                                                height: 12,
                                                thickness: 0.5,
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withOpacity(0.2),
                                              ),
                                              _buildCompactInfoCard(
                                                icon: Icons.timelapse_rounded,
                                                title: '建议游览',
                                                value: _getSpotDuration(),
                                                color: AppTheme.neonPurple,
                                              ),
                                            ],
                                          )
                                          : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              _buildCompactInfoCard(
                                                icon:
                                                    Icons.attach_money_rounded,
                                                title: '门票',
                                                value: '¥${_getSpotPrice()}',
                                                color: AppTheme.neonTeal,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 1,
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withOpacity(0.2),
                                              ),
                                              _buildCompactInfoCard(
                                                icon: Icons.access_time_rounded,
                                                title: '开放时间',
                                                value: _getSpotHours(),
                                                color: AppTheme.neonOrange,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 1,
                                                color: AppTheme
                                                    .secondaryTextColor
                                                    .withOpacity(0.2),
                                              ),
                                              _buildCompactInfoCard(
                                                icon: Icons.timelapse_rounded,
                                                title: '建议游览',
                                                value: _getSpotDuration(),
                                                color: AppTheme.neonPurple,
                                              ),
                                            ],
                                          ),
                                ),
                              ],
                            ),
                          ),

                          // 景点信息区 - 更紧凑的设计，将标签整合在这里
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ), // 减少水平内边距
                            margin: EdgeInsets.only(bottom: 16), // 减少下边距
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12), // 减少内边距
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '景点基本信息',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          // 添加"景点标签"小标识
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.neonBlue
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              '景点标签',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppTheme.neonBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      // 将标签放在这里
                                      Container(
                                        height: 28, // 减少高度
                                        child: ListView(
                                          scrollDirection: Axis.horizontal,
                                          padding: EdgeInsets.only(bottom: 4),
                                          children: [
                                            _buildCompactTagChip(
                                              '历史',
                                              AppTheme.neonBlue,
                                            ),
                                            _buildCompactTagChip(
                                              '文化',
                                              AppTheme.neonPurple,
                                            ),
                                            _buildCompactTagChip(
                                              '建筑',
                                              AppTheme.neonTeal,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      _buildCompactInfoRow(
                                        Icons.place_outlined,
                                        '地址',
                                        _getSpotLocation(),
                                      ),
                                      SizedBox(height: 8),
                                      _buildCompactInfoRow(
                                        Icons.access_time_rounded,
                                        '最佳游览时间',
                                        _getSpotBestTime(),
                                      ),
                                      SizedBox(height: 8),
                                      _buildCompactInfoRow(
                                        Icons.group_outlined,
                                        '适合人群',
                                        '所有年龄段，尤其是${_getSpotSuitableFor()}',
                                      ),
                                      SizedBox(height: 8),
                                      _buildCompactInfoRow(
                                        Icons.phone_outlined,
                                        '联系电话',
                                        _getSpotContact(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 添加景点详情描述区域
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            margin: EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            color: AppTheme.neonTeal,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '景点详情',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        _getSpotDescription(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.primaryTextColor,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 添加景点服务网格布局（原来在抽屉中的内容）
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.transparent, // 确保没有黄色边框
                                width: 0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(
                                    12,
                                    10,
                                    12,
                                    8,
                                  ), // 减少顶部和底部内边距
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardColor.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.transparent, // 透明边框，移除黄色
                                      width: 0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.grid_view_rounded,
                                            color: AppTheme.neonBlue,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '景点服务',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                          Spacer(),
                                          // 添加查看更多按钮
                                          TextButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('查看全部服务'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              minimumSize: Size(20, 20),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              '更多',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppTheme.neonBlue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8), // 减少间距
                                      // 用GridView展示服务选项
                                      GridView.count(
                                        crossAxisCount:
                                            screenWidth < 340
                                                ? 3
                                                : 4, // 增加每行数量到4个
                                        shrinkWrap: true,
                                        physics:
                                            NeverScrollableScrollPhysics(), // 禁止滚动，嵌入在SingleChildScrollView中
                                        crossAxisSpacing: 6, // 更小的间距
                                        mainAxisSpacing: 6, // 更小的间距
                                        childAspectRatio: 0.85, // 调整宽高比使其更紧凑
                                        padding: EdgeInsets.symmetric(
                                          vertical: 4,
                                        ), // 减少内边距
                                        children: [
                                          _buildServiceItem(
                                            icon: Icons.map_outlined,
                                            title: '导航',
                                            color: AppTheme.neonTeal,
                                            onTap: () => _launchMaps(),
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.share_outlined,
                                            title: '分享',
                                            color: AppTheme.neonPurple,
                                            onTap: () => _shareSpot(),
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.camera_alt_outlined,
                                            title: '拍照',
                                            color: AppTheme.neonGreen,
                                            onTap: () => _openCamera(),
                                          ),
                                          _buildServiceItem(
                                            icon:
                                                _isFavorite
                                                    ? Icons.favorite
                                                    : Icons
                                                        .favorite_border_outlined,
                                            title: _isFavorite ? '已收藏' : '收藏',
                                            color:
                                                _isFavorite
                                                    ? AppTheme.neonPink
                                                    : AppTheme.neonBlue,
                                            onTap: () {
                                              setState(() {
                                                _isFavorite = !_isFavorite;
                                              });
                                              HapticFeedback.mediumImpact();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    _isFavorite
                                                        ? '已添加到收藏'
                                                        : '已取消收藏',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.info_outline,
                                            title: '景点介绍',
                                            color: AppTheme.neonOrange,
                                            onTap: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('查看景点详细介绍'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.star_outline,
                                            title: '评价',
                                            color: Colors.amber,
                                            onTap: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('查看游客评价'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.local_dining_outlined,
                                            title: '美食',
                                            color: AppTheme.neonPink,
                                            onTap: () {
                                              _showFoodServiceOptions(context);
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.hotel_outlined,
                                            title: '住宿',
                                            color: AppTheme.neonBlue
                                                .withOpacity(0.8),
                                            onTap: () {
                                              _showAccommodationOptions(
                                                context,
                                              );
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.directions_car_outlined,
                                            title: '交通',
                                            color: AppTheme.neonGreen
                                                .withOpacity(0.8),
                                            onTap: () {
                                              _showTransportationOptions(
                                                context,
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 底部安全区域
                          SizedBox(height: 20 + bottomPadding),
                        ],
                      ),
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
}
