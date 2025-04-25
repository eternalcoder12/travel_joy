import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/travel_timeline.dart';

class TravelTimelinePreview extends StatelessWidget {
  final List<TravelEvent> events;
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
        // 头部标题和查看全部按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    color: AppTheme.neonPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '旅行足迹',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 统计信息
        _buildStatisticsRow(),
        const SizedBox(height: 20),

        // 底部查看全部按钮
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 12,
            left: 16,
            right: 16,
          ),
          child: GestureDetector(
            onTap: onViewAllPressed,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.buttonColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.buttonColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '查看全部旅行足迹',
                    style: TextStyle(
                      color: AppTheme.buttonColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppTheme.buttonColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 构建统计信息行
  Widget _buildStatisticsRow() {
    // 计算唯一城市和国家
    final cities = _getUniqueCities();
    final countries = _getUniqueCountries();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.location_city,
            value: cities.length.toString(),
            label: '城市',
            color: AppTheme.neonBlue,
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            icon: Icons.public,
            value: countries.length.toString(),
            label: '国家',
            color: AppTheme.neonPurple,
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            icon: Icons.place,
            value: events.length.toString(),
            label: '足迹',
            color: AppTheme.neonPink,
          ),
        ],
      ),
    );
  }

  // 构建单个统计项 - 修改为与旅行偏好分析卡片类似的样式
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.buttonColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 48,
            color: AppTheme.secondaryTextColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无旅行足迹',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '记录您的旅行冒险，创建美好回忆！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 添加旅行记录的逻辑
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('添加旅行记录'),
          ),
        ],
      ),
    );
  }

  // 获取唯一城市列表
  Set<String> _getUniqueCities() {
    return events.map((event) => event.location).toSet();
  }

  // 获取唯一国家列表
  Set<String> _getUniqueCountries() {
    return events
        .where((event) => event.country != null)
        .map((event) => event.country!)
        .toSet();
  }
}
