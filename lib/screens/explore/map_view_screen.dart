import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'dart:math' as math;
import '../../utils/navigation_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  // Google Map 控制器
  GoogleMapController? _mapController;
  
  // 地图标记集合
  Map<MarkerId, Marker> _markers = {};
  
  // 计算随机经纬度位置，模拟景点位置
  List<LatLng> _spotLocations = [];

  // 摄像机位置
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(39.9042, 116.4074), // 北京位置
    zoom: 14,
  );

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
    _generateLocations();

    // 启动页面进入动画
    _pageAnimController.forward();
    _contentAnimController.forward();
  }

  // 生成位置数据，此处为模拟数据，实际应用中应使用真实地点坐标
  void _generateLocations() {
    final random = math.Random();

    // 根据景点名称生成大致位置
    _spotLocations = widget.spots.map((spot) {
      if (spot['name'] == '故宫博物院') {
        return LatLng(39.9163, 116.3972); // 故宫实际位置
      } else if (spot['name'] == '西湖风景区') {
        return LatLng(30.2590, 120.1388); // 西湖实际位置
      } else if (spot['name'] == '黄山风景区') {
        return LatLng(30.1318, 118.1633); // 黄山实际位置
      } else {
        // 生成随机位置
        final latOffset = (random.nextDouble() * 0.1 - 0.05);
        final lngOffset = (random.nextDouble() * 0.1 - 0.05);
        return LatLng(39.9042 + latOffset, 116.4074 + lngOffset);
      }
    }).toList();

    // 设置初始摄像机位置为第一个景点
    if (_spotLocations.isNotEmpty) {
      _initialCameraPosition = CameraPosition(
        target: _spotLocations[_selectedSpotIndex],
        zoom: 14,
      );
    }
    
    // 创建标记
    _createMarkers();
  }
  
  // 创建地图标记
  void _createMarkers() {
    _markers.clear();
    
    for (int i = 0; i < _spotLocations.length; i++) {
      final markerId = MarkerId(i.toString());
      final spot = widget.spots[i];
      
      final marker = Marker(
        markerId: markerId,
        position: _spotLocations[i],
        infoWindow: InfoWindow(
          title: spot['name'],
          snippet: spot['location'],
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          i == _selectedSpotIndex ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() {
            _selectedSpotIndex = i;
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
          
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _spotLocations[i],
                zoom: 14,
              ),
            ),
          );
        },
      );
      
      _markers[markerId] = marker;
    }
  }

  @override
  void dispose() {
    _pageAnimController.dispose();
    _backgroundAnimController.dispose();
    _contentAnimController.dispose();
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 真实地图视图
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
      child: Stack(
        children: [
          // 使用备选的模拟地图
          _buildSimulatedMap(),
          
          if (_isMapLoading) 
            _buildMapLoadingIndicator(),
        ],
      ),
    );
  }
  
  // 构建模拟地图（当无法加载真实地图时使用）
  Widget _buildSimulatedMap() {
    return Stack(
      children: [
        // 模拟地图背景
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFE8EAED),
          child: CustomPaint(
            painter: SimulatedMapPainter(
              spotLocations: _spotLocations,
              selectedIndex: _selectedSpotIndex,
            ),
            size: Size.infinite,
          ),
        ),
        
        // 模拟地图上的标记点
        for (int i = 0; i < _spotLocations.length; i++)
          _buildMapMarker(i),
        
        // 提示信息
        Positioned(
          top: 80,
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.buttonColor, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '使用模拟地图，实际位置可能有误',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 隐藏底部的HTTP错误信息
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFFE8EAED),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建地图标记
  Widget _buildMapMarker(int index) {
    final spot = widget.spots[index];
    
    // 计算标记在屏幕上的位置
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // 根据index生成均匀分布的位置
    double angle = (index * (2 * math.pi / widget.spots.length)) + (math.pi / 4);
    double radius = math.min(screenWidth, screenHeight) * 0.25;
    
    double centerX = screenWidth * 0.5;
    double centerY = screenHeight * 0.38;
    
    double x = centerX + radius * math.cos(angle);
    double y = centerY + radius * math.sin(angle);
    
    if (index == _selectedSpotIndex) {
      // 选中的标记放在中心位置
      x = centerX;
      y = centerY;
    }
    
    return Positioned(
      left: x - 30,
      top: y - 50,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标记名称气泡
              if (index == _selectedSpotIndex)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    spot['name'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
              // 标记图标
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: index == _selectedSpotIndex
                          ? AppTheme.buttonColor
                          : Colors.grey,
                      size: index == _selectedSpotIndex ? 50 : 40,
                    ),
                    Positioned(
                      top: index == _selectedSpotIndex ? 10 : 8,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 20,
                        alignment: Alignment.center,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                spreadRadius: 1,
                              )
                            ]
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
}

// 模拟地图绘制器
class SimulatedMapPainter extends CustomPainter {
  final List<LatLng> spotLocations;
  final int selectedIndex;

  SimulatedMapPainter({
    required this.spotLocations,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final bgPaint = Paint()..color = const Color(0xFFE8EAED);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 绘制网格线
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final gridSize = 50.0;

    // 水平线
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 垂直线
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制一些模拟道路
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8.0
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
    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 4.0
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
    final buildingPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final buildingSize = random.nextDouble() * 30 + 10;

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

    // 绘制中心选中区域
    final centerX = size.width / 2;
    final centerY = size.height * 0.38;
    
    final highlightPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      100.0,
      highlightPaint,
    );
    
    // 绘制水域
    final waterPaint = Paint()
      ..color = Color(0xFFB3E5FC)
      ..style = PaintingStyle.fill;
    
    final waterPath = Path();
    waterPath.moveTo(size.width * 0.1, size.height * 0.8);
    waterPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.7,
      size.width * 0.5, size.height * 0.8
    );
    waterPath.quadraticBezierTo(
      size.width * 0.7, size.height * 0.9,
      size.width * 0.9, size.height * 0.75
    );
    waterPath.lineTo(size.width, size.height);
    waterPath.lineTo(0, size.height);
    waterPath.close();
    
    canvas.drawPath(waterPath, waterPaint);
    
    // 绘制公园区域
    final parkPaint = Paint()
      ..color = Color(0xFFC8E6C9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      50.0,
      parkPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
