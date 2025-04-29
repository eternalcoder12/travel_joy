import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'dart:math' as math;
import '../../utils/navigation_utils.dart';

class MapViewScreen extends StatefulWidget {
  final List<Map<String, dynamic>> spots;
  final int initialSpotIndex;

  const MapViewScreen({
    Key? key,
    required this.spots,
    this.initialSpotIndex = 0,
  }) : super(key: key);

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen>
    with TickerProviderStateMixin {
  // 页面动画控制器
  late AnimationController _pageAnimController;

  // 背景动画控制器 - 从消息页面添加
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 内容动画控制器 - 从消息页面添加
  late AnimationController _contentAnimController;
  late Animation<double> _contentAnimation;

  // 当前选中的景点索引
  late int _selectedSpotIndex;

  // 是否显示列表视图
  bool _showListView = false;

  // 页面控制器
  late final PageController _pageController;

  // 计算随机经纬度位置，模拟景点位置
  List<Map<String, double>> _spotLocations = [];

  // 模拟地图缩放级别
  double _zoomLevel = 13.0;
  
  // 地图加载状态
  bool _isMapLoading = true;
  bool _hasMapError = false;

  @override
  void initState() {
    super.initState();

    _selectedSpotIndex = widget.initialSpotIndex;

    // 初始化页面动画控制器
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 初始化背景动画控制器 - 从消息页面添加
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化内容动画控制器 - 从消息页面添加
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentAnimation = CurvedAnimation(
      parent: _contentAnimController,
      curve: Curves.easeOutCubic,
    );

    // 初始化页面控制器
    _pageController = PageController(
      initialPage: _selectedSpotIndex,
      viewportFraction: 0.85,
    );

    // 生成随机位置（真实应用中应使用实际经纬度）
    _generateRandomLocations();

    // 启动页面进入动画
    _pageAnimController.forward();
    _contentAnimController.forward();
    
    // 模拟地图加载
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    });
  }

  // 生成随机位置数据，模拟景点在地图上的分布
  void _generateRandomLocations() {
    final random = math.Random();

    // 模拟北京附近的一组随机经纬度
    final baseLatitude = 39.9 + (random.nextDouble() * 0.1 - 0.05);
    final baseLongitude = 116.4 + (random.nextDouble() * 0.1 - 0.05);

    _spotLocations = List.generate(widget.spots.length, (index) {
      // 为每个景点生成随机偏移，使它们分散在地图上
      final latOffset = (random.nextDouble() * 0.1 - 0.05);
      final lngOffset = (random.nextDouble() * 0.1 - 0.05);

      return {
        'latitude': baseLatitude + latOffset,
        'longitude': baseLongitude + lngOffset,
      };
    });
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 模拟地图视图
          _buildMapView(),

          // 顶部应用栏
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 返回按钮
                    _buildCircleButton(
                      icon: Icons.arrow_back,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),

                    Row(
                      children: [
                        // 搜索按钮
                        _buildCircleButton(
                          icon: Icons.search,
                          onPressed: () {
                            _showSearchDialog();
                          },
                        ),
                        SizedBox(width: 12),
                        // 切换列表/地图视图按钮
                        _buildCircleButton(
                          icon: _showListView ? Icons.map : Icons.list,
                          onPressed: () {
                            setState(() {
                              _showListView = !_showListView;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 底部景点轮播卡片
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _contentAnimation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutCubic))
                    .animate(_contentAnimController),
                child: Column(
                  children: [
                    // 根据视图模式显示不同内容
                    _showListView ? _buildSpotListView() : _buildSpotCarousel(),

                    // 缩放控制按钮
                    if (!_showListView)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildZoomButton(Icons.remove, () {
                              setState(() {
                                _zoomLevel = math.max(10.0, _zoomLevel - 1.0);
                              });
                            }),
                            const SizedBox(width: 16),
                            _buildZoomButton(Icons.add, () {
                              setState(() {
                                _zoomLevel = math.min(18.0, _zoomLevel + 1.0);
                              });
                            }),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建圆形按钮
  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(
            icon,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  // 构建地图视图
  Widget _buildMapView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFFE8EAED),
      child: Stack(
        children: [
          if (_isMapLoading) 
            _buildMapLoadingIndicator()
          else if (_hasMapError)
            _buildSimulatedMap()
          else
            Stack(
              children: [
                // 模拟地图底图
                Image.network(
                  'https://maps.googleapis.com/maps/api/staticmap?center=${_spotLocations[_selectedSpotIndex]['latitude']},${_spotLocations[_selectedSpotIndex]['longitude']}&zoom=${_zoomLevel.round()}&size=600x600&scale=2&maptype=roadmap&key=YOUR_API_KEY',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildMapLoadingIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // 如果加载失败，显示模拟地图
                    setState(() {
                      _hasMapError = true;
                    });
                    return _buildSimulatedMap();
                  },
                ),

                // 覆盖在底图上的位置标记
                ..._buildLocationMarkers(),
              ],
            ),
        ],
      ),
    );
  }
  
  // 构建地图加载指示器
  Widget _buildMapLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: AppTheme.buttonColor,
                ),
                SizedBox(height: 16),
                Text(
                  '加载地图中...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建位置标记集合
  List<Widget> _buildLocationMarkers() {
    return _spotLocations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;

      // 计算位置标记在屏幕上的位置
      final double offsetX =
          (location['longitude']! -
              _spotLocations[_selectedSpotIndex]['longitude']!) *
          5000;
      final double offsetY =
          (location['latitude']! -
              _spotLocations[_selectedSpotIndex]['latitude']!) *
          8000;

      // 缩放因子
      final zoomFactor = _zoomLevel / 13.0;

      return Positioned(
        left: MediaQuery.of(context).size.width / 2 + offsetX * zoomFactor,
        top: MediaQuery.of(context).size.height / 2 - offsetY * zoomFactor,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedSpotIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: index == _selectedSpotIndex ? 60 : 40,
            width: index == _selectedSpotIndex ? 60 : 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 标记底部阴影
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 6,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),

                // 主标记
                Icon(
                  Icons.location_on,
                  color:
                      index == _selectedSpotIndex
                          ? AppTheme.buttonColor
                          : Colors.grey,
                  size: index == _selectedSpotIndex ? 50 : 40,
                ),

                // 标记内的数字
                Positioned(
                  top: index == _selectedSpotIndex ? 12 : 10,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // 构建模拟地图（当无法加载真实地图时使用）
  Widget _buildSimulatedMap() {
    return Stack(
      children: [
        CustomPaint(
          painter: SimulatedMapPainter(
            zoomLevel: _zoomLevel,
            spotLocations: _spotLocations,
            selectedIndex: _selectedSpotIndex,
          ),
          size: Size.infinite,
        ),
        // 添加模拟地图使用提示
        Positioned(
          top: 80,
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              '使用模拟地图，真实位置可能与标记不符',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // 搜索对话框
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('搜索景点'),
        content: TextField(
          decoration: InputDecoration(
            hintText: '输入景点名称',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('搜索功能将在后续版本推出')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('搜索'),
          ),
        ],
      ),
    );
  }

  // 构建景点轮播
  Widget _buildSpotCarousel() {
    return SizedBox(
      height: 140,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.spots.length,
        onPageChanged: (index) {
          setState(() {
            _selectedSpotIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final spot = widget.spots[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // 景点图片
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Image.network(
                    spot['image'],
                    width: 100,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // 景点信息
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 景点名称
                        Text(
                          spot['name'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // 景点位置
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                spot['location'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 景点评分
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${spot['rating']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryTextColor,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // 获取路线按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('导航到${spot['name']}'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(60, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions,
                                    size: 16,
                                    color: AppTheme.buttonColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '获取路线',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.buttonColor,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 构建景点列表视图
  Widget _buildSpotListView() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: Column(
        children: [
          // 顶部拖动指示器
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '附近景点',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
                Text(
                  '${widget.spots.length} 个景点',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // 景点列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: widget.spots.length,
              itemBuilder: (context, index) {
                final spot = widget.spots[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpotIndex = index;
                      // 切换回地图视图
                      _showListView = false;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          index == _selectedSpotIndex
                              ? AppTheme.cardColor.withOpacity(0.2)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            index == _selectedSpotIndex
                                ? AppTheme.buttonColor
                                : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 序号标记
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                index == _selectedSpotIndex
                                    ? AppTheme.buttonColor
                                    : Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color:
                                  index == _selectedSpotIndex
                                      ? Colors.white
                                      : AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // 景点信息
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                spot['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                spot['location'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 评分
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${spot['rating']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¥${spot['price']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建缩放按钮
  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: AppTheme.primaryTextColor,
      ),
    );
  }
}

// 模拟地图绘制器
class SimulatedMapPainter extends CustomPainter {
  final double zoomLevel;
  final List<Map<String, double>> spotLocations;
  final int selectedIndex;

  SimulatedMapPainter({
    required this.zoomLevel,
    required this.spotLocations,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final bgPaint = Paint()..color = const Color(0xFFE8EAED);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 绘制网格线
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.2)
          ..strokeWidth = 1.0;

    final gridSize = 50.0 * (zoomLevel / 13.0); // 根据缩放级别调整网格大小

    // 水平线
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 垂直线
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制一些模拟道路
    final roadPaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 8.0 * (zoomLevel / 13.0)
          ..style = PaintingStyle.stroke;

    // 主要道路
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      roadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      roadPaint,
    );

    // 次要道路
    final secondaryRoadPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 4.0 * (zoomLevel / 13.0)
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      secondaryRoadPaint,
    );

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.3),
      secondaryRoadPaint,
    );

    // 绘制一些模拟建筑物
    final buildingPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final buildingSize = (random.nextDouble() * 30 + 10) * (zoomLevel / 13.0);

      canvas.drawRect(
        Rect.fromLTWH(
          x - buildingSize / 2,
          y - buildingSize / 2,
          buildingSize,
          buildingSize,
        ),
        buildingPaint,
      );
    }

    // 突出显示当前所选位置区域
    final highlightPaint =
        Paint()
          ..color = AppTheme.buttonColor.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      100.0 * (zoomLevel / 13.0),
      highlightPaint,
    );

    // 添加一个中心标记
    final centerPaint =
        Paint()
          ..color = AppTheme.buttonColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      8.0 * (zoomLevel / 13.0),
      centerPaint,
    );

    // 绘制一个波纹效果，模拟GPS定位
    final ripplePaint1 =
        Paint()
          ..color = AppTheme.buttonColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final ripplePaint2 =
        Paint()
          ..color = AppTheme.buttonColor.withOpacity(0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final ripplePaint3 =
        Paint()
          ..color = AppTheme.buttonColor.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      15.0 * (zoomLevel / 13.0),
      ripplePaint1,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      25.0 * (zoomLevel / 13.0),
      ripplePaint2,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      35.0 * (zoomLevel / 13.0),
      ripplePaint3,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
