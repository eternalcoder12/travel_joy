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
  static const int pointsAddAccommodation = 12; // 添加住宿信息的积分奖励

  // 经验值奖励
  static const int expAddFoodInfo = 8;
  static const int expAddReview = 12;
  static const int expShareSpot = 3;
  static const int expAddAccommodation = 10; // 添加住宿信息的经验值奖励
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

  // 显示奖励对话框方法 - 移到这里，使其在被调用前声明
  void _showRewardDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('太棒了'),
            ),
          ],
        );
      },
    );
  }

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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        opacity < 0.5
                            ? AppTheme.cardColor.withOpacity(0.3)
                            : AppTheme.cardColor.withOpacity(0.3),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),

                // 收藏按钮
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cardColor.withOpacity(0.3),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? AppTheme.neonPink : Colors.white,
                      size: 18,
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
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 启动导航 (修改为调用手机导航应用)
  void _launchMaps() {
    _showNavigationOptions(context);
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

    // 确保分享功能正确工作
    try {
      Share.share(shareText, subject: '分享景点: $spotName');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    }
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

  // 获取景点经度
  double _getSpotLongitude() {
    return widget.spotData['longitude'] ?? 120.12603;
  }

  // 获取景点纬度
  double _getSpotLatitude() {
    return widget.spotData['latitude'] ?? 30.259933;
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

  // 构建服务网格项 - 更美观的版本
  Widget _buildServiceItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          // 移除边框，用阴影替代
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 美化图标容器
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            // 改进标题样式
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTextColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
                    padding: EdgeInsets.symmetric(
                      vertical: UIConstants.paddingMedium,
                      horizontal: UIConstants.paddingLarge,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(UIConstants.borderRadiusLarge),
                        topRight: Radius.circular(
                          UIConstants.borderRadiusLarge,
                        ),
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
                              Icons.restaurant,
                              color: AppTheme.neonPink,
                              size: UIConstants.iconSizeMedium,
                            ),
                            SizedBox(width: UIConstants.paddingSmall),
                            Text(
                              '特色美食推荐',
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
                                color: AppTheme.neonPink.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  UIConstants.borderRadiusMedium,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_user,
                                    size: UIConstants.iconSizeTiny,
                                    color: AppTheme.neonPink,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '数据来源：用户贡献',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeTiny,
                                      color: AppTheme.neonPink,
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

                  // 内容区域
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(UIConstants.paddingLarge),
                      children: [
                        // 特色美食列表
                        _buildFoodItem(
                          name: '西湖醋鱼',
                          description: '杭州名菜，选用西湖中的草鱼制作，口味酸甜适中，鱼肉鲜嫩。',
                          price: '88-128元',
                          rating: '4.8',
                          imagePath: 'https://picsum.photos/id/1080/200/200',
                          onTap: () {},
                        ),
                        SizedBox(height: UIConstants.paddingMedium),

                        _buildFoodItem(
                          name: '龙井虾仁',
                          description: '以龙井茶与虾仁烹饪而成，茶香与虾的鲜美完美结合。',
                          price: '68-98元',
                          rating: '4.6',
                          imagePath: 'https://picsum.photos/id/1060/200/200',
                          onTap: () {},
                        ),
                        SizedBox(height: UIConstants.paddingMedium),

                        _buildFoodItem(
                          name: '东坡肉',
                          description: '传说是苏东坡发明的杭州传统名菜，肥而不腻，口感醇厚。',
                          price: '58-78元',
                          rating: '4.7',
                          imagePath: 'https://picsum.photos/id/1025/200/200',
                          onTap: () {},
                        ),

                        // 添加美食信息按钮
                        Container(
                          margin: EdgeInsets.only(
                            top: UIConstants.paddingLarge,
                          ),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('添加美食信息'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonPink,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: UIConstants.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  UIConstants.borderRadiusMedium,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddFoodInfoDialog(context);
                            },
                          ),
                        ),

                        // 奖励提示
                        Container(
                          margin: EdgeInsets.only(
                            top: UIConstants.paddingMedium,
                          ),
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: UIConstants.iconSizeMedium,
                              ),
                              SizedBox(width: UIConstants.paddingSmall),
                              Expanded(
                                child: Text(
                                  '提供真实有效的美食信息将获得 ${RewardConstants.pointsAddFoodInfo} 积分和 ${RewardConstants.expAddFoodInfo} 经验值奖励！',
                                  style: TextStyle(
                                    fontSize: UIConstants.fontSizeSmall,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  // 构建美食项
  Widget _buildFoodItem({
    required String name,
    required String description,
    required String price,
    required String rating,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.all(UIConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 美食图片
            ClipRRect(
              borderRadius: BorderRadius.circular(
                UIConstants.borderRadiusSmall,
              ),
              child: network.NetworkImage(
                imageUrl: imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: UIConstants.paddingMedium),

            // 美食信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadiusSmall,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 12),
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
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '价格: $price',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.neonPink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                        topRight: Radius.circular(
                          UIConstants.borderRadiusLarge,
                        ),
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
                              '附近住宿',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Spacer(),
                            // 添加上传按钮
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _showAddAccommodationDialog(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: UIConstants.paddingSmall,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.borderRadiusMedium,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.upload_outlined,
                                      size: UIConstants.iconSizeTiny,
                                      color: AppTheme.neonBlue,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '上传住宿信息',
                                      style: TextStyle(
                                        fontSize: UIConstants.fontSizeTiny,
                                        color: AppTheme.neonBlue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 内容区域
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(UIConstants.paddingLarge),
                      children: [
                        // 住宿平台选择
                        Text(
                          '选择预订平台',
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: UIConstants.paddingMedium),

                        Wrap(
                          spacing: UIConstants.paddingSmall,
                          runSpacing: UIConstants.paddingSmall,
                          children: [
                            _buildPlatformButton(
                              platformName: '携程旅行',
                              icon: Icons.hotel,
                              color: Colors.blue,
                              onTap: () => _launchBookingApp('ctrip://', '携程'),
                            ),
                            _buildPlatformButton(
                              platformName: '去哪儿旅行',
                              icon: Icons.flight,
                              color: Colors.deepPurple,
                              onTap: () => _launchBookingApp('qunar://', '去哪儿'),
                            ),
                            _buildPlatformButton(
                              platformName: '美团旅行',
                              icon: Icons.hotel_class,
                              color: Colors.green,
                              onTap:
                                  () => _launchBookingApp('imeituan://', '美团'),
                            ),
                          ],
                        ),

                        SizedBox(height: UIConstants.paddingLarge),

                        // 推荐住宿
                        Text(
                          '景区周边推荐住宿',
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                        SizedBox(height: UIConstants.paddingMedium),

                        // 酒店列表
                        _buildHotelItem(
                          name: '西湖湖畔酒店',
                          description: '位于西湖边，环境优美，交通便利，可俯瞰西湖美景。',
                          price: '¥688起',
                          distance: '800米',
                          rating: '4.8',
                          imagePath: 'https://picsum.photos/id/164/200/200',
                          onTap: () => _launchBookingApp('ctrip://', '携程'),
                        ),
                        SizedBox(height: UIConstants.paddingMedium),

                        _buildHotelItem(
                          name: '杭州西溪悦榕庄',
                          description: '奢华的五星级酒店，提供spa服务和各种娱乐设施。',
                          price: '¥1288起',
                          distance: '2.5公里',
                          rating: '4.9',
                          imagePath: 'https://picsum.photos/id/237/200/200',
                          onTap: () => _launchBookingApp('ctrip://', '携程'),
                        ),

                        // 添加住宿信息按钮
                        Container(
                          margin: EdgeInsets.only(
                            top: UIConstants.paddingLarge,
                          ),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.add),
                            label: Text('添加住宿信息'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: UIConstants.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  UIConstants.borderRadiusMedium,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _showAddAccommodationDialog(context);
                            },
                          ),
                        ),

                        // 奖励提示
                        Container(
                          margin: EdgeInsets.only(
                            top: UIConstants.paddingMedium,
                          ),
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: UIConstants.iconSizeMedium,
                              ),
                              SizedBox(width: UIConstants.paddingSmall),
                              Expanded(
                                child: Text(
                                  '提供真实有效的住宿信息将获得 ${RewardConstants.pointsAddAccommodation} 积分和 ${RewardConstants.expAddAccommodation} 经验值奖励！',
                                  style: TextStyle(
                                    fontSize: UIConstants.fontSizeSmall,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  Widget _buildHotelItem({
    required String name,
    required String description,
    required String price,
    required String distance,
    required String rating,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.all(UIConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒店图片
            ClipRRect(
              borderRadius: BorderRadius.circular(
                UIConstants.borderRadiusSmall,
              ),
              child: network.NetworkImage(
                imageUrl: imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: UIConstants.paddingMedium),

            // 酒店信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingSmall,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadiusSmall,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 12),
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
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.neonBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '距离: $distance',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryTextColor,
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

                          // 修改景点详情和景点服务区块的部分
                          // 首先删除独立的景点详情区块
                          /*
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                          */

                          // 修改后的景点服务模块
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            margin: EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(18, 16, 18, 14),
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
                                            Icons.grid_view_rounded,
                                            color: AppTheme.neonBlue,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '景点服务',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryTextColor,
                                            ),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      // 用GridView展示服务选项
                                      GridView.count(
                                        crossAxisCount:
                                            screenWidth < 340 ? 3 : 4,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.9,
                                        padding: EdgeInsets.only(bottom: 8),
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
                                              _showSpotIntroduction(context);
                                            },
                                          ),
                                          _buildServiceItem(
                                            icon: Icons.star_outline,
                                            title: '评价',
                                            color: Colors.amber,
                                            onTap: () {
                                              _showReviews(context);
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

  // 显示交通服务选项
  void _showTransportationOptions(BuildContext context) {
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
                        topRight: Radius.circular(
                          UIConstants.borderRadiusLarge,
                        ),
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
                              Icons.directions,
                              color: AppTheme.neonGreen,
                              size: UIConstants.iconSizeMedium,
                            ),
                            SizedBox(width: UIConstants.paddingSmall),
                            Text(
                              '交通出行指南',
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
                                color: AppTheme.neonGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  UIConstants.borderRadiusMedium,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    size: UIConstants.iconSizeTiny,
                                    color: AppTheme.neonGreen,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '数据来源：景区官网',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeTiny,
                                      color: AppTheme.neonGreen,
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

                  // 交通指南内容
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(UIConstants.paddingLarge),
                      children: [
                        // 数据来源说明
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          margin: EdgeInsets.only(
                            bottom: UIConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue,
                                size: UIConstants.iconSizeMedium,
                              ),
                              SizedBox(width: UIConstants.paddingSmall),
                              Expanded(
                                child: Text(
                                  '以下信息来自景区官方网站和用户贡献，仅供参考。实际交通情况可能因季节、天气或其他因素而变化。',
                                  style: TextStyle(
                                    fontSize: UIConstants.fontSizeSmall,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 官方交通信息
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          margin: EdgeInsets.only(
                            bottom: UIConstants.paddingMedium,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_bus,
                                    color: AppTheme.neonGreen,
                                    size: UIConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '公共交通',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                '杭州市区至西湖景区：\n乘坐公交K599路、Y2路、Y9路等可直达西湖景区。',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              Divider(height: 24),
                              Row(
                                children: [
                                  Icon(
                                    Icons.train,
                                    color: AppTheme.neonGreen,
                                    size: UIConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '地铁路线',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                '地铁1号线：龙翔桥站、定安路站下车后步行可达\n地铁2号线：凤起路站换乘公交车可达',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              Divider(height: 24),
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_car,
                                    color: AppTheme.neonGreen,
                                    size: UIConstants.iconSizeSmall,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '自驾导航',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                '导航至"西湖风景区"，可停车场：\n· 湖滨停车场（收费）\n· 断桥停车场（收费）\n· 岳庙停车场（收费）',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 地图导航按钮
                        ElevatedButton.icon(
                          icon: Icon(
                            Icons.map,
                            size: UIConstants.iconSizeSmall,
                          ),
                          label: Text('打开地图导航'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                UIConstants.borderRadiusMedium,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: UIConstants.paddingMedium,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _launchMaps();
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

  // 显示添加美食信息的对话框
  void _showAddFoodInfoDialog(BuildContext context) {
    // 美食名称控制器
    TextEditingController nameController = TextEditingController();
    // 美食描述控制器
    TextEditingController descriptionController = TextEditingController();
    // 美食价格控制器
    TextEditingController priceController = TextEditingController();
    // 是否推荐
    bool isRecommended = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
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
              child: Padding(
                padding: EdgeInsets.all(UIConstants.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          color: AppTheme.neonPink,
                          size: UIConstants.iconSizeMedium,
                        ),
                        SizedBox(width: UIConstants.paddingSmall),
                        Text(
                          '添加美食信息',
                          style: TextStyle(
                            fontSize: UIConstants.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: UIConstants.paddingMedium),

                    // 美食名称输入
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '美食名称',
                        hintText: '例如：西湖醋鱼',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: UIConstants.paddingMedium),

                    // 美食描述输入
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: '美食描述',
                        hintText: '例如：杭州特色传统名菜，味道鲜美...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: UIConstants.paddingMedium),

                    // 价格范围输入
                    TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: '价格范围',
                        hintText: '例如：58-128元',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            UIConstants.borderRadiusMedium,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: UIConstants.paddingMedium),

                    // 是否推荐选项
                    Row(
                      children: [
                        Checkbox(
                          value: isRecommended,
                          onChanged: (value) {
                            setState(() {
                              isRecommended = value ?? false;
                            });
                          },
                          activeColor: AppTheme.neonPink,
                        ),
                        Text(
                          '我向其他用户推荐这道美食',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: UIConstants.fontSizeMedium,
                          ),
                        ),
                      ],
                    ),

                    // 奖励提示
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: UIConstants.paddingMedium,
                      ),
                      padding: EdgeInsets.all(UIConstants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          UIConstants.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: UIConstants.iconSizeMedium,
                          ),
                          SizedBox(width: UIConstants.paddingSmall),
                          Expanded(
                            child: Text(
                              '提供真实有效的美食信息将获得 ${RewardConstants.pointsAddFoodInfo} 积分和 ${RewardConstants.expAddFoodInfo} 经验值奖励！',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeSmall,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 这里应该添加数据验证和提交逻辑
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text('请输入美食名称')));
                            return;
                          }

                          // 模拟成功提交
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('美食信息提交成功，感谢您的贡献！'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // 关闭对话框
                          Navigator.pop(context);

                          // 模拟积分和经验值奖励提示
                          Future.delayed(Duration(milliseconds: 500), () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.emoji_events,
                                        color: Colors.amber,
                                      ),
                                      SizedBox(width: 8),
                                      Text('获得奖励'),
                                    ],
                                  ),
                                  content: Text(
                                    '感谢您的贡献！您获得了：\n'
                                    '· ${RewardConstants.pointsAddFoodInfo} 积分\n'
                                    '· ${RewardConstants.expAddFoodInfo} 经验值',
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('太棒了'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonPink,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: UIConstants.paddingMedium,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                          ),
                        ),
                        child: Text('提交美食信息'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // 构建平台按钮
  Widget _buildPlatformButton({
    required String platformName,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: UIConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: UIConstants.iconSizeSmall),
            SizedBox(width: UIConstants.paddingSmall),
            Text(
              platformName,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: UIConstants.fontSizeSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 启动预订应用
  Future<void> _launchBookingApp(String appUrl, String appName) async {
    try {
      // 尝试打开App
      final bool launched = await launchUrlString(
        appUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // 如果无法打开App，显示提示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$appName 应用未安装'),
              action: SnackBarAction(
                label: '获取',
                onPressed: () {
                  // 提供下载链接(这里模拟打开应用商店)
                  String storeUrl =
                      Platform.isIOS
                          ? 'itms-apps://itunes.apple.com/app/id$appName'
                          : 'market://details?id=com.$appName';
                  launchUrlString(
                    storeUrl,
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('无法打开 $appName: $e')));
      }
    }
  }

  // 显示导航选项对话框
  void _showNavigationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(UIConstants.paddingLarge),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.map,
                    color: AppTheme.neonBlue,
                    size: UIConstants.iconSizeMedium,
                  ),
                  SizedBox(width: UIConstants.paddingSmall),
                  Text(
                    '选择导航应用',
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.paddingLarge),

              // 导航选项列表
              InkWell(
                onTap: () => _launchMapApp('百度地图', 'baidumap://'),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusMedium,
                ),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(UIConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.blue,
                          size: UIConstants.iconSizeMedium,
                        ),
                      ),
                      SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '百度地图',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              '提供详细的实时路况和公交信息',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.secondaryTextColor,
                        size: UIConstants.iconSizeTiny,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: UIConstants.paddingSmall),

              InkWell(
                onTap: () => _launchMapApp('高德地图', 'androidamap://'),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusMedium,
                ),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(UIConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.green,
                          size: UIConstants.iconSizeMedium,
                        ),
                      ),
                      SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '高德地图',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              '准确的定位和路线规划',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.secondaryTextColor,
                        size: UIConstants.iconSizeTiny,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: UIConstants.paddingSmall),

              InkWell(
                onTap: () => _launchMapApp('腾讯地图', 'qqmap://'),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusMedium,
                ),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(UIConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.blue.shade800,
                          size: UIConstants.iconSizeMedium,
                        ),
                      ),
                      SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '腾讯地图',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              '精准导航和热门景点推荐',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.secondaryTextColor,
                        size: UIConstants.iconSizeTiny,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: UIConstants.paddingSmall),

              InkWell(
                onTap: () => _launchMapApp('Apple地图', 'maps://'),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusMedium,
                ),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(UIConstants.paddingSmall),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.map_outlined,
                          color: Colors.grey,
                          size: UIConstants.iconSizeMedium,
                        ),
                      ),
                      SizedBox(width: UIConstants.paddingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Apple地图',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeMedium,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            Text(
                              '适用于iOS设备的原生地图应用',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeSmall,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.secondaryTextColor,
                        size: UIConstants.iconSizeTiny,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: UIConstants.paddingLarge),
              // 取消按钮
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusMedium,
                ),
                child: Container(
                  padding: EdgeInsets.all(UIConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      UIConstants.borderRadiusMedium,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '取消',
                    style: TextStyle(
                      fontSize: UIConstants.fontSizeMedium,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 启动地图应用
  Future<void> _launchMapApp(String appName, String appUrl) async {
    final location = _getSpotLocation();
    final name = _getSpotName();
    // 获取经纬度
    final double latitude = _getSpotLatitude();
    final double longitude = _getSpotLongitude();
    final String spotCoordinates = '$latitude,$longitude';

    try {
      String mapUrl = appUrl;

      // 打开指定地图App并搜索地点
      switch (appName) {
        case '百度地图':
          mapUrl =
              'baidumap://map/direction?destination=$spotCoordinates&destinationname=$name&coord_type=bd09ll&mode=driving';
          break;
        case '高德地图':
          mapUrl =
              'androidamap://viewMap?sourceApplication=Travel Joy&poiname=$name&lat=$latitude&lon=$longitude&dev=0';
          break;
        case '腾讯地图':
          mapUrl =
              'qqmap://map/search?keyword=$name&center=$spotCoordinates&coordtype=1';
          break;
        case 'Apple地图':
          mapUrl = 'maps://?q=$name&ll=$spotCoordinates';
          break;
        default:
          mapUrl = 'geo:$spotCoordinates?q=$name';
      }

      final bool launched = await launchUrlString(
        mapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$appName 未安装，请选择其他地图应用'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('无法打开 $appName: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // 显示景点介绍对话框
  void _showSpotIntroduction(BuildContext context) {
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
                        topRight: Radius.circular(
                          UIConstants.borderRadiusLarge,
                        ),
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
                              Icons.info_outline,
                              color: AppTheme.neonOrange,
                              size: UIConstants.iconSizeMedium,
                            ),
                            SizedBox(width: UIConstants.paddingSmall),
                            Text(
                              '景点介绍与详情',
                              style: TextStyle(
                                fontSize: UIConstants.fontSizeLarge,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 内容区域
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(UIConstants.paddingLarge),
                      children: [
                        // 景点详情区块
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_outlined,
                                    color: AppTheme.neonTeal,
                                    size: UIConstants.iconSizeMedium,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '景点详情',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                _getSpotDescription(),
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: UIConstants.paddingMedium),

                        // 历史背景
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AppTheme.neonBlue,
                                    size: UIConstants.iconSizeMedium,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '历史背景',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                '西湖风景区内有许多著名的历史文化景点，如雷峰塔、岳庙、苏堤春晓等。这些景点历史悠久，文化内涵丰富，见证了杭州的历史变迁。西湖十景"苏堤春晓、曲院风荷、平湖秋月、断桥残雪、柳浪闻莺、花港观鱼、雷峰夕照、双峰插云、南屏晚钟、三潭印月"成为游客观赏的重点。',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: UIConstants.paddingMedium),

                        // 文化特色
                        Container(
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(
                              UIConstants.borderRadiusMedium,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.palette,
                                    color: AppTheme.neonPurple,
                                    size: UIConstants.iconSizeMedium,
                                  ),
                                  SizedBox(width: UIConstants.paddingSmall),
                                  Text(
                                    '文化特色',
                                    style: TextStyle(
                                      fontSize: UIConstants.fontSizeMedium,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: UIConstants.paddingSmall),
                              Text(
                                '西湖是中国传统审美文化的代表，自古以来就是文人墨客吟咏的对象，留下了众多脍炙人口的诗词佳句。西湖还是白娘子与许仙、梁山伯与祝英台等民间传说的发源地，这些传说为西湖增添了浪漫色彩。另外，西湖龙井茶也是杭州的特色文化符号之一。',
                                style: TextStyle(
                                  fontSize: UIConstants.fontSizeSmall,
                                  color: AppTheme.primaryTextColor,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
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

  // 显示评论对话框
  void _showReviews(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final reviewController = TextEditingController();
        double userRating = 5.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
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
                            topLeft: Radius.circular(
                              UIConstants.borderRadiusLarge,
                            ),
                            topRight: Radius.circular(
                              UIConstants.borderRadiusLarge,
                            ),
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
                                  Icons.star,
                                  color: Colors.amber,
                                  size: UIConstants.iconSizeMedium,
                                ),
                                SizedBox(width: UIConstants.paddingSmall),
                                Text(
                                  '游客评价',
                                  style: TextStyle(
                                    fontSize: UIConstants.fontSizeLarge,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: UIConstants.paddingMedium,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.borderRadiusMedium,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        _getSpotRating(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
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

                      // 写评论区域
                      Container(
                        padding: EdgeInsets.all(UIConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppTheme.cardColor.withOpacity(0.5),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '写下您的评价',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                            SizedBox(height: 8),

                            // 评分选择器
                            Row(
                              children: [
                                Text(
                                  '您的评分：',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                ),
                                // 评分星星
                                Row(
                                  children: List.generate(5, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          userRating = index + 1.0;
                                        });
                                      },
                                      child: Icon(
                                        index < userRating.floor()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  userRating.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            // 评论输入框
                            TextField(
                              controller: reviewController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: '分享您的体验和建议...',
                                border: OutlineInputBorder(),
                              ),
                            ),

                            SizedBox(height: 12),

                            // 推荐选项
                            Row(
                              children: [
                                Checkbox(value: true, onChanged: (value) {}),
                                Text('我向其他用户推荐这个景点'),
                              ],
                            ),

                            SizedBox(height: 16),

                            // 提交按钮
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.buttonColor,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // 验证评论内容
                                  if (reviewController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('请输入评论内容')),
                                    );
                                    return;
                                  }

                                  // 关闭对话框
                                  Navigator.pop(context);

                                  // 成功提示
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('评论发布成功！'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // 积分奖励弹窗
                                  Future.delayed(Duration(milliseconds: 500), () {
                                    _showRewardDialog(
                                      title: '评价奖励',
                                      content:
                                          '感谢您的评价！您获得了：\n'
                                          '· ${RewardConstants.pointsAddReview} 积分\n'
                                          '· ${RewardConstants.expAddReview} 经验值',
                                    );
                                  });
                                },
                                child: Text('发布评论'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 评论列表区域
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.all(UIConstants.paddingMedium),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 用户信息与评分
                                  Row(
                                    children: [
                                      // 头像
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: network.NetworkImage(
                                          imageUrl: review['avatar'] as String,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 12),

                                      // 用户名和日期
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review['userName'] as String,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppTheme.primaryTextColor,
                                              ),
                                            ),
                                            Text(
                                              review['date'] as String,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppTheme.secondaryTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 评分
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 14,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${review['rating']}',
                                              style: TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12),

                                  // 评论内容
                                  Text(
                                    review['comment'] as String,
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // 添加住宿信息对话框
  void _showAddAccommodationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isRecommended = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('添加住宿信息'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: '住宿名称 *',
                        hintText: '例如: 湖畔度假酒店',
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        labelText: '地址',
                        hintText: '例如: 杭州市西湖区湖滨路18号',
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '参考价格 (¥/晚)',
                        hintText: '例如: 388',
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: '描述',
                        hintText: '请描述住宿环境、服务等特点',
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isRecommended,
                          onChanged: (value) {
                            setState(() {
                              isRecommended = value ?? true;
                            });
                          },
                        ),
                        Text('我向其他用户推荐这个住宿'),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 验证输入
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('请输入住宿名称')));
                      return;
                    }

                    // 关闭对话框
                    Navigator.of(context).pop();

                    // 显示提交成功信息
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('住宿信息提交成功，感谢您的贡献！'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // 显示积分奖励对话框
                    Future.delayed(Duration(milliseconds: 500), () {
                      _showRewardDialog(
                        title: '获得奖励',
                        content:
                            '感谢您的贡献！您获得了：\n'
                            '· ${RewardConstants.pointsAddAccommodation} 积分\n'
                            '· ${RewardConstants.expAddAccommodation} 经验值',
                      );
                    });
                  },
                  child: Text('提交'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
