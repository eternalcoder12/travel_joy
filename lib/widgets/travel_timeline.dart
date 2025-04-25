import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:collection/collection.dart';
import 'package:travel_joy/widgets/animated_item.dart';

class TravelEvent {
  final String location;
  final String date;
  final String description;
  final String? imageUrl;
  final Color? dotColor;
  final String? country;

  TravelEvent({
    required this.location,
    required this.date,
    required this.description,
    this.imageUrl,
    this.dotColor,
    this.country,
  });
}

class TravelTimeline extends StatelessWidget {
  final List<TravelEvent> events;
  final ScrollController? scrollController;

  const TravelTimeline({Key? key, required this.events, this.scrollController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 按年份分组事件
    final groupedEvents = _groupEventsByYear();

    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final year = groupedEvents.keys.elementAt(index);
        final yearEvents = groupedEvents[year]!;

        return Column(
          children: [
            // 年份标记 - 添加动画效果
            AnimatedItem(
              duration: 800 + index * 100,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 0, 8), // 添加左侧间距16像素
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.neonBlue.withOpacity(0.2),
                      AppTheme.backgroundColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ), // 增加内边距
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withOpacity(0.3),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12), // 减小圆角
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        year,
                        style: const TextStyle(
                          fontSize: 16, // 略微增大字体
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 年份对应的事件列表 - 添加交错动画
            ...yearEvents.mapIndexed((eventIndex, event) {
              final isLast = eventIndex == yearEvents.length - 1;
              return AnimatedItem(
                duration: 800 + (index * 100) + (eventIndex * 100),
                delay: 100 * eventIndex,
                child: _buildTimelineItem(context, event, isLast, eventIndex),
              );
            }).toList(),

            // 年份之间的间距
            if (index < groupedEvents.length - 1)
              const SizedBox(height: 12), // 减小年份间间距
          ],
        );
      },
    );
  }

  // 按年份分组事件
  Map<String, List<TravelEvent>> _groupEventsByYear() {
    final Map<String, List<TravelEvent>> grouped = {};

    // 对事件进行排序 (从新到旧)
    final sortedEvents = List<TravelEvent>.from(events);
    sortedEvents.sort((a, b) => b.date.compareTo(a.date));

    for (var event in sortedEvents) {
      // 更健壮的年份提取，支持多种日期格式
      String year;
      if (event.date.contains('-')) {
        // 格式如 "2023-10-15"
        year = event.date.split('-')[0];
      } else if (event.date.contains('年')) {
        // 格式如 "2023年10月15日"
        year = event.date.split('年')[0];
      } else {
        // 其他格式，尝试提取前4个字符
        year = event.date.length >= 4 ? event.date.substring(0, 4) : event.date;
      }

      if (!grouped.containsKey(year)) {
        grouped[year] = [];
      }
      grouped[year]!.add(event);
    }

    return grouped;
  }

  // 构建时间线项目 - 减小元素尺寸
  Widget _buildTimelineItem(
    BuildContext context,
    TravelEvent event,
    bool isLast,
    int index,
  ) {
    // 确定时间线点的颜色
    final dotColor = event.dotColor ?? _getTimelineDotColor(index);

    // 模拟更多信息数据
    final travelDuration = _getRandomTravelDuration();
    final travelType = _getRandomTravelType(index);
    final travelMood = _getRandomTravelMood(index);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 8, 4), // 增加左侧间距
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间线 - 进一步精简
          SizedBox(
            width: 36, // 再次减小宽度
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 日期显示 - 更加现代化
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: dotColor.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getMonth(event.date),
                        style: TextStyle(
                          color: dotColor,
                          fontSize: 9, // 调整字体
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getDay(event.date),
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // 连接线和圆点 - 更现代化设计
                if (!isLast)
                  SizedBox(
                    height: 40, // 调整高度
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 连接线 - 虚线效果
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return CustomPaint(
                              size: Size(1, constraints.maxHeight),
                              painter: DashedLinePainter(
                                color: dotColor.withOpacity(0.5),
                                dashHeight: 3,
                                dashSpace: 3,
                              ),
                            );
                          },
                        ),

                        // 位置点 - 美化设计
                        Positioned(
                          top: 6,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.backgroundColor,
                              border: Border.all(color: dotColor, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.place,
                                color: dotColor,
                                size: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 14,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 位置点
                        Positioned(
                          top: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.backgroundColor.withOpacity(0.8),
                              border: Border.all(color: dotColor, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withOpacity(0.2),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.place,
                                color: dotColor,
                                size: 6,
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

          // 右侧内容区域
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: dotColor.withOpacity(0.1), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // 顶部渐变装饰
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              dotColor.withOpacity(0.7),
                              dotColor.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 主要内容
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 地点和标签行
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: dotColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTextColor,
                                  ),
                                ),
                              ),

                              // 右侧标签
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: dotColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      size: 10,
                                      color: dotColor,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      travelDuration,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: dotColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // 国家信息
                          if (event.country != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 14,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    event.country!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 描述文本
                          Text(
                            event.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryTextColor.withOpacity(0.8),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // 底部标签行
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 旅行类型
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      travelType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  // 旅行心情
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.backgroundColor
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      travelMood,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // 查看详情
                              TextButton(
                                onPressed: () {
                                  // 查看详情逻辑，暂不实现具体页面
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size.zero,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '查看详情',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: dotColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 9,
                                      color: dotColor,
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }

  // 提取月份
  String _getMonth(String date) {
    if (date.contains('-')) {
      final parts = date.split('-');
      return '${parts[1]}月';
    } else if (date.contains('年') && date.contains('月')) {
      final parts = date.split('年');
      final monthParts = parts[1].split('月');
      return '${monthParts[0]}月';
    }
    return '';
  }

  // 提取日
  String _getDay(String date) {
    if (date.contains('-')) {
      final parts = date.split('-');
      if (parts.length >= 3) {
        return parts[2];
      }
    } else if (date.contains('月') && date.contains('日')) {
      final parts = date.split('月');
      if (parts.length >= 2) {
        final dayParts = parts[1].split('日');
        return dayParts[0];
      }
    }
    return '';
  }

  // 构建空状态 - 减小尺寸
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_outlined,
            size: 36, // 减小图标
            color: AppTheme.secondaryTextColor.withOpacity(0.4),
          ),
          const SizedBox(height: 8), // 减小间距
          Text(
            '暂无旅行记录',
            style: TextStyle(
              fontSize: 14, // 减小字体
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2), // 减小间距
          Text(
            '开始您的旅行冒险吧',
            style: TextStyle(
              fontSize: 11, // 减小字体
              color: AppTheme.secondaryTextColor.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  // 获取时间线点的颜色
  Color _getTimelineDotColor(int index) {
    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonPurple,
      AppTheme.neonPink,
      AppTheme.neonOrange,
    ];
    return colors[index % colors.length];
  }

  // 随机生成旅行时长 (模拟数据)
  String _getRandomTravelDuration() {
    final durations = ['3天', '5天', '1周', '2周', '3天2晚', '5天4晚'];
    return durations[DateTime.now().microsecond % durations.length];
  }

  // 随机生成旅行类型 (模拟数据)
  String _getRandomTravelType(int index) {
    final types = ['自由行', '跟团游', '商务', '探亲', '蜜月', '度假'];
    return types[index % types.length];
  }

  // 随机生成旅行心情 (模拟数据)
  String _getRandomTravelMood(int index) {
    final moods = ['愉快', '惊喜', '放松', '振奋', '满足', '难忘'];
    return moods[(index + 1) % moods.length];
  }

  // 获取旅行类型对应图标
  IconData _getTravelTypeIcon(String type) {
    switch (type) {
      case '自由行':
        return Icons.directions_walk;
      case '跟团游':
        return Icons.groups;
      case '商务':
        return Icons.business;
      case '探亲':
        return Icons.family_restroom;
      case '蜜月':
        return Icons.favorite;
      case '度假':
        return Icons.beach_access;
      default:
        return Icons.travel_explore;
    }
  }

  // 获取心情对应图标
  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case '愉快':
        return Icons.sentiment_satisfied;
      case '惊喜':
        return Icons.emoji_emotions;
      case '放松':
        return Icons.spa;
      case '振奋':
        return Icons.auto_awesome;
      case '满足':
        return Icons.thumb_up_alt;
      case '难忘':
        return Icons.favorite;
      default:
        return Icons.mood;
    }
  }

  // 获取心情对应颜色
  Color _getMoodColor(String mood) {
    switch (mood) {
      case '愉快':
        return Colors.amber;
      case '惊喜':
        return Colors.purple;
      case '放松':
        return Colors.teal;
      case '振奋':
        return Colors.orange;
      case '满足':
        return Colors.blue;
      case '难忘':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

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
    // 计算城市和国家数量
    final cities = events.map((e) => e.location).toSet().length;
    final countries =
        events.map((e) => e.country).whereType<String>().toSet().length;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.cardColor, AppTheme.cardColor.withOpacity(0.9)],
        ),
        border: Border.all(color: AppTheme.neonBlue.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏 - 现代设计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonBlue.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.place_outlined,
                      color: AppTheme.neonBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '旅行足迹',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: onViewAllPressed,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.neonBlue,
                        AppTheme.neonBlue.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 统计区域 - 现代化设计
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.neonBlue.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.location_city_outlined,
                  value: cities.toString(),
                  label: '城市',
                  color: AppTheme.neonBlue,
                ),
                _buildDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.public_outlined,
                  value: countries.toString(),
                  label: '国家',
                  color: AppTheme.neonPurple,
                ),
                _buildDivider(),
                _buildStatItem(
                  context,
                  icon: Icons.flag_outlined,
                  value: events.length.toString(),
                  label: '足迹',
                  color: AppTheme.neonOrange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 预览内容
          events.isEmpty
              ? _buildEmptyState()
              : _buildTimelineEventCards(context),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标容器 - 添加光效
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        // 数值 - 更醒目
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        // 标签 - 更清晰
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 80, // 减小高度
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.secondaryTextColor.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff,
              color: AppTheme.secondaryTextColor.withOpacity(0.3),
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              '暂无旅行记录',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryTextColor.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEventCards(BuildContext context) {
    // 只显示最近的3个事件
    final displayEvents = events.length > 3 ? events.sublist(0, 3) : events;

    return Column(
      children:
          displayEvents.map((event) => _buildTimelineEventCard(event)).toList(),
    );
  }

  Widget _buildTimelineEventCard(TravelEvent event) {
    final dotColor = event.dotColor ?? AppTheme.neonBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dotColor.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          // 左侧圆点和日期 - 简化
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.3),
                      blurRadius: 3,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: dotColor.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
              Text(
                _formatDate(event.date),
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.secondaryTextColor.withOpacity(0.6),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // 右侧内容 - 简化
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 位置名称
                Text(
                  event.location,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTextColor,
                  ),
                ),

                const SizedBox(height: 2),

                // 简短描述
                Text(
                  event.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryTextColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // 右侧图标 - 简化
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: dotColor.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(color: dotColor.withOpacity(0.1), width: 1),
            ),
            child: Icon(Icons.arrow_forward, color: dotColor, size: 12),
          ),
        ],
      ),
    );
  }

  // 格式化日期显示
  String _formatDate(String date) {
    // 处理多种日期格式
    if (date.contains('-')) {
      // 格式: "2023-12-25"
      final parts = date.split('-');
      if (parts.length >= 3) {
        return '${parts[1]}月${parts[2]}日';
      }
    } else if (date.contains('年') && date.contains('月') && date.contains('日')) {
      // 格式: "2023年12月25日"
      try {
        final yearParts = date.split('年');
        final monthParts = yearParts[1].split('月');
        final dayParts = monthParts[1].split('日');
        return '${monthParts[0]}月${dayParts[0]}日';
      } catch (e) {
        // 如果解析失败，返回原始日期
        return date;
      }
    }
    return date;
  }

  // 添加分隔线方法
  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppTheme.secondaryTextColor.withOpacity(0.1),
    );
  }
}

// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashHeight;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashHeight = 3,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5;

    while (startY < size.height) {
      // 绘制一小段虚线
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.dashHeight != dashHeight ||
        oldDelegate.dashSpace != dashSpace;
  }
}
