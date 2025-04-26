import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/travel_timeline.dart';

class TravelHistoryScreen extends StatefulWidget {
  final List<TravelEvent> events;

  const TravelHistoryScreen({Key? key, required this.events}) : super(key: key);

  @override
  State<TravelHistoryScreen> createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 计算不同城市和国家的数量
  int get _cityCount => _getUniqueCities().length;
  int get _countryCount => _getUniqueCountries().length;

  List<String> _getUniqueCities() {
    return widget.events.map((e) => e.location).toSet().toList();
  }

  List<String> _getUniqueCountries() {
    return widget.events.map((e) => e.country ?? "未知").toSet().toList();
  }

  @override
  void initState() {
    super.initState();

    // 创建页面进入动画
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryTextColor,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '我的旅行足迹',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.primaryTextColor,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor, const Color(0xFF2E2E4A)],
          ),
        ),
        child: Stack(
          children: [
            // 添加光晕效果
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 主要内容
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      // 时间线
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TravelTimeline(events: _addCountryToEvents()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 为事件添加国家信息（在实际项目中，这可能是从数据源获取的）
  List<TravelEvent> _addCountryToEvents() {
    // 国家映射表（示例）
    const countries = {
      '曼谷': '泰国',
      '纽约': '美国',
      '巴黎': '法国',
      '东京': '日本',
      '伦敦': '英国',
      '悉尼': '澳大利亚',
      '首尔': '韩国',
      '罗马': '意大利',
      '柏林': '德国',
      '马德里': '西班牙',
    };

    return widget.events.map((event) {
      // 尝试从映射表中获取国家，如果没有就使用默认值
      final country =
          countries[event.location] ??
          (event.location.contains('York')
              ? '美国'
              : (event.location.contains('Tokyo') ? '日本' : '未知'));

      return TravelEvent(
        location: event.location,
        date: event.date,
        description: event.description,
        imageUrl: event.imageUrl,
        dotColor: event.dotColor,
        country: country,
      );
    }).toList();
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor),
        ),
      ],
    );
  }
}
