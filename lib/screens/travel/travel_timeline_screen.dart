import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/travel_timeline.dart';

class TravelTimelineScreen extends StatelessWidget {
  final List<TravelEvent> events;

  const TravelTimelineScreen({Key? key, required this.events})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.getTheme().scaffoldBackgroundColor,
        title: const Text('旅行足迹'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.map, color: AppTheme.getTheme().primaryColor),
                const SizedBox(width: 8),
                Text(
                  '我的旅行足迹 (${events.length}个城市)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getTheme().cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TravelTimeline(events: events),
            ),
            const SizedBox(height: 16),
            Text(
              '足迹统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTheme().primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getTheme().cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.location_on,
                    count: events.length,
                    label: '城市',
                    color: Colors.blue,
                  ),
                  _buildStatItem(
                    icon: Icons.flag,
                    count: _countCountries(),
                    label: '国家',
                    color: Colors.orange,
                  ),
                  _buildStatItem(
                    icon: Icons.calendar_today,
                    count: _estimateTravelDays(),
                    label: '旅行天数',
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 25,
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  int _countCountries() {
    // 简单的估算，实际应用中应该从events中提取不同的国家
    return events.length > 5 ? 3 : (events.length / 2).ceil();
  }

  int _estimateTravelDays() {
    // 简单的估算，实际应用中应该根据日期计算
    return events.length * 3;
  }
}
