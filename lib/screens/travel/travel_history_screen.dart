import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/travel_timeline.dart';
import '../../utils/navigation_utils.dart';

class TravelHistoryScreen extends StatefulWidget {
  final List<TimelineTravelEvent> events;

  const TravelHistoryScreen({Key? key, required this.events}) : super(key: key);

  @override
  _TravelHistoryScreenState createState() => _TravelHistoryScreenState();
}

class _TravelHistoryScreenState extends State<TravelHistoryScreen> {
  String _selectedLocation = "全部";
  String _selectedCountry = "全部";

  // 获取所有地点
  List<String> _getLocations() {
    return widget.events.map((e) => e.location).toSet().toList();
  }

  // 获取所有国家
  List<String> _getCountries() {
    return widget.events.map((e) => e.country ?? "未知").toSet().toList();
  }

  // 按选择筛选事件
  List<TimelineTravelEvent> _getFilteredEvents() {
    return widget.events.where((event) {
      bool locationMatch =
          _selectedLocation == "全部" || event.location == _selectedLocation;
      bool countryMatch =
          _selectedCountry == "全部" || event.country == _selectedCountry;
      return locationMatch && countryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locations = ["全部", ..._getLocations()];
    final countries = ["全部", ..._getCountries()];

    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.cardColor, AppTheme.backgroundColor],
              ),
            ),
          ),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                // 顶部应用栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 返回按钮
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        radius: 18,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      // 标题
                      Text(
                        '我的旅行足迹',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 右侧分享按钮
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        radius: 18,
                        child: IconButton(
                          icon: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('分享功能即将上线'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 筛选器
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      // 地点筛选
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLocation,
                              isExpanded: true,
                              isDense: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              dropdownColor: AppTheme.cardColor,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedLocation = newValue!;
                                });
                              },
                              items:
                                  locations.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 8),

                      // 国家筛选
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountry,
                              isExpanded: true,
                              isDense: true,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              dropdownColor: AppTheme.cardColor,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCountry = newValue!;
                                });
                              },
                              items:
                                  countries.map<DropdownMenuItem<String>>((
                                    String value,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 时间线
                Expanded(
                  child:
                      filteredEvents.isEmpty
                          ? _buildEmptyState()
                          : TravelTimeline(events: filteredEvents),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建空状态视图
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            '没有找到旅行记录',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '尝试更改筛选条件或去探索新的地方吧',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 为事件添加国家信息
  List<TimelineTravelEvent> _addCountryToEvents() {
    final Map<String, String> countries = {};

    return widget.events.map((event) {
      countries[event.location] ??=
          (event.location.contains('York')
              ? '美国'
              : (event.location.contains('Tokyo') ? '日本' : '未知'));

      return TimelineTravelEvent(
        location: event.location,
        date: event.date,
        description: event.description,
        imageUrl: event.imageUrl,
        dotColor: event.dotColor,
        country: countries[event.location],
      );
    }).toList();
  }
}
