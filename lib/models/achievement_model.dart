import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int currentProgress;
  final int maxProgress;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String? rewardDescription;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.currentProgress,
    required this.maxProgress,
    this.isUnlocked = false,
    this.unlockedDate,
    this.rewardDescription,
  });

  double get progressPercent =>
      maxProgress > 0
          ? (currentProgress / maxProgress).clamp(0.0, 1.0)
          : (isUnlocked ? 1.0 : 0.0);

  // 工厂方法：创建样例成就列表
  static List<Achievement> getSampleAchievements() {
    return [
      Achievement(
        id: 'ach_001',
        name: '首次旅行',
        description: '完成你的第一次旅行',
        icon: Icons.flight_takeoff,
        color: const Color(0xFF00B4D8), // neonBlue
        currentProgress: 1,
        maxProgress: 1,
        isUnlocked: true,
        unlockedDate: DateTime(2023, 10, 15),
        rewardDescription: '获得100积分',
      ),
      Achievement(
        id: 'ach_002',
        name: '摄影大师',
        description: '上传10张高质量旅行照片',
        icon: Icons.photo_camera,
        color: const Color(0xFF9D4EDD), // neonPurple
        currentProgress: 7,
        maxProgress: 10,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ach_003',
        name: '探索者',
        description: '访问5个不同的城市',
        icon: Icons.explore,
        color: const Color(0xFFFF48C4), // neonPink
        currentProgress: 3,
        maxProgress: 5,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ach_004',
        name: '文化鉴赏家',
        description: '参观10个历史文化景点',
        icon: Icons.museum,
        color: const Color(0xFFFFD700), // neonYellow
        currentProgress: 4,
        maxProgress: 10,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ach_005',
        name: '美食家',
        description: '品尝15种不同地方的特色美食',
        icon: Icons.restaurant,
        color: const Color(0xFFFF9E00), // neonOrange
        currentProgress: 8,
        maxProgress: 15,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ach_006',
        name: '冒险家',
        description: '参加3次户外冒险活动',
        icon: Icons.terrain,
        color: const Color(0xFF39D353), // neonGreen
        currentProgress: 2,
        maxProgress: 3,
        isUnlocked: false,
      ),
      Achievement(
        id: 'ach_007',
        name: '社交达人',
        description: '与10位其他旅行者建立联系',
        icon: Icons.people,
        color: const Color(0xFF2EC4B6), // neonTeal
        currentProgress: 10,
        maxProgress: 10,
        isUnlocked: true,
        unlockedDate: DateTime(2023, 11, 3),
        rewardDescription: '获得150积分',
      ),
      Achievement(
        id: 'ach_008',
        name: '5星评价',
        description: '获得5个景点5星评价',
        icon: Icons.star,
        color: const Color(0xFFFFD700), // neonYellow
        currentProgress: 5,
        maxProgress: 5,
        isUnlocked: true,
        unlockedDate: DateTime(2023, 12, 28),
        rewardDescription: '获得200积分和特殊徽章',
      ),
    ];
  }
}
