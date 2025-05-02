import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/travel_timeline.dart'; 
import '../utils/navigation_utils.dart';

class TravelTimelinePreview extends StatelessWidget {
  final List<TimelineTravelEvent> events;
  final VoidCallback onViewAllPressed;

  const TravelTimelinePreview({
    Key? key,
    required this.events,
    required this.onViewAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部区域
        _buildHeader(context),

        // 预览时间线
        ...events.take(3).map((e) => _buildTimelineEventCard(e)).toList(),

        // 查看全部按钮
        _buildViewAllButton(context),
      ],
    );
  }

  // 顶部标题区域
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 16.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 顶部标题
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '旅行足迹',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '您去过 ${_getUniqueLocations().length} 个地方，${_getUniqueCountries().length} 个国家',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 13.0,
                ),
              ),
            ],
          ),

          // 统计数字
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppTheme.neonBlue,
                  size: 16.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  '${events.length}',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                Text(
                  ' 次旅行',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建时间线事件卡片
  Widget _buildTimelineEventCard(TimelineTravelEvent event) {
    final dotColor = event.dotColor ?? AppTheme.neonBlue;

    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 16.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧日期和装饰
          Column(
            children: [
              // 日期气泡
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: dotColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dotColor.withOpacity(0.3),
                    width: 2.0,
                  ),
                ),
                child: Text(
                  _formatDateBubble(event.date),
                  style: TextStyle(
                    color: dotColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 连接线
              if (events.indexOf(event) != events.length - 1)
                Container(
                  width: 2.0,
                  height: 40.0,
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        dotColor.withOpacity(0.7),
                        dotColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // 右侧内容卡片
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 地点信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16.0,
                              color: dotColor,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (event.country != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              top: 2.0,
                            ),
                            child: Text(
                              event.country!,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6.0),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: AppTheme.primaryTextColor.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // 右侧箭头
                  // 外层包裹的容器提供触摸区域
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.0,
                      color: AppTheme.secondaryTextColor,
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

  // 查看全部按钮
  Widget _buildViewAllButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
        child: InkWell(
          onTap: onViewAllPressed,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.buttonColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: AppTheme.buttonColor.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '查看全部足迹',
                  style: TextStyle(
                    color: AppTheme.buttonColor,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4.0),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.buttonColor,
                  size: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 空状态视图
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '旅行足迹',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.flight,
                color: AppTheme.secondaryTextColor,
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 40.0,
                  color: AppTheme.secondaryTextColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16.0),
                Text(
                  '暂无旅行记录',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '开始您的旅行，记录精彩时刻',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: onViewAllPressed,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.buttonColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    '添加旅行',
                    style: TextStyle(
                      color: AppTheme.buttonColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取唯一地点
  Set<String> _getUniqueLocations() {
    return events.map((event) => event.location).toSet();
  }

  // 获取唯一国家
  Set<String> _getUniqueCountries() {
    return events
        .where((event) => event.country != null)
        .map((event) => event.country!)
        .toSet();
  }

  // 格式化日期气泡显示
  String _formatDateBubble(String date) {
    // 简单地提取月/日
    if (date.contains('-')) {
      final parts = date.split('-');
      if (parts.length >= 2) {
        return '${parts[1]}';
      }
    } else if (date.contains('年') && date.contains('月')) {
      final month = date.split('年')[1].split('月')[0];
      return month;
    }
    
    // 默认返回短格式
    return date.length > 5 ? date.substring(5, 7) : date;
  }
}
