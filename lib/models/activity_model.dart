import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int participantsCount;
  final int maxParticipants;
  final String organizer;
  final List<String> tags;
  final bool isRegistered;
  final bool isHot;
  final String? imageUrl;
  final double? rating;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.participantsCount,
    required this.maxParticipants,
    required this.organizer,
    required this.tags,
    this.isRegistered = false,
    this.isHot = false,
    this.imageUrl,
    this.rating,
  });

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isFull => participantsCount >= maxParticipants;

  // 可注册状态：活动未开始且未满员且用户未注册
  bool get canRegister => isUpcoming && !isFull && !isRegistered;

  // 工厂方法：创建样例活动列表
  static List<Activity> getSampleActivities() {
    final now = DateTime.now();

    return [
      Activity(
        id: 'act_001',
        title: '成都美食探索之旅',
        description:
            '一起探索成都的美食文化，品尝正宗川菜，体验火锅文化，探访特色小吃街。活动包含三家知名餐厅和两条美食街的深度游览，专业导游全程陪同。',
        icon: Icons.restaurant,
        color: const Color(0xFFFF9E00), // neonOrange
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 5, hours: 4)),
        location: '成都市锦江区春熙路',
        participantsCount: 18,
        maxParticipants: 30,
        organizer: '川味美食会',
        tags: ['美食', '文化体验', '团队活动'],
        isHot: true,
        imageUrl: 'https://example.com/chengdu_food.jpg',
        rating: 4.8,
      ),
      Activity(
        id: 'act_002',
        title: '西湖徒步摄影团',
        description: '环绕西湖进行一次摄影徒步之旅，捕捉西湖十景的美丽瞬间。专业摄影师全程指导，适合各级摄影爱好者参与。',
        icon: Icons.photo_camera,
        color: const Color(0xFF9D4EDD), // neonPurple
        startDate: now.add(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 2, hours: 6)),
        location: '杭州市西湖区',
        participantsCount: 15,
        maxParticipants: 20,
        organizer: '杭州摄影协会',
        tags: ['摄影', '户外', '徒步'],
        isRegistered: true,
        isHot: true,
      ),
      Activity(
        id: 'act_003',
        title: '上海城市探索挑战赛',
        description: '在上海市中心进行的团队挑战赛，解开谜题，探索地标，发现隐藏景点。各小队将竞争完成任务，获胜团队将获得精美奖品。',
        icon: Icons.explore,
        color: const Color(0xFF2EC4B6), // neonTeal
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 10, hours: 5)),
        location: '上海市黄浦区',
        participantsCount: 45,
        maxParticipants: 60,
        organizer: '城市探险者俱乐部',
        tags: ['团队建设', '城市探索', '比赛'],
        imageUrl: 'https://example.com/shanghai_explore.jpg',
      ),
      Activity(
        id: 'act_004',
        title: '北京胡同文化之旅',
        description: '深入北京胡同，了解老北京的传统文化和生活方式。包含四合院参观、传统手工艺体验和当地美食品尝。',
        icon: Icons.history_edu,
        color: const Color(0xFF00B4D8), // neonBlue
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now
            .subtract(const Duration(days: 3))
            .add(const Duration(hours: 3)),
        location: '北京市东城区南锣鼓巷',
        participantsCount: 25,
        maxParticipants: 25,
        organizer: '北京文化遗产保护协会',
        tags: ['文化', '历史', '美食'],
        rating: 4.6,
      ),
      Activity(
        id: 'act_005',
        title: '张家界高空玻璃栈道挑战',
        description: '挑战张家界国家森林公园内的高空玻璃栈道，体验惊险刺激的同时欣赏壮丽的自然风光。包含专业教练指导和安全装备。',
        icon: Icons.terrain,
        color: const Color(0xFF39D353), // neonGreen
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 15, hours: 8)),
        location: '湖南省张家界市',
        participantsCount: 12,
        maxParticipants: 15,
        organizer: '极限运动爱好者协会',
        tags: ['极限运动', '自然风光', '刺激体验'],
        isHot: true,
        imageUrl: 'https://example.com/zhangjiajie.jpg',
      ),
      Activity(
        id: 'act_006',
        title: '云南少数民族文化节',
        description: '参与云南少数民族文化节，体验多样的民族文化、音乐、舞蹈和美食。活动包含参与传统仪式、学习民族舞蹈和品尝特色美食。',
        icon: Icons.celebration,
        color: const Color(0xFFFF48C4), // neonPink
        startDate: now.subtract(const Duration(hours: 12)),
        endDate: now.add(const Duration(days: 2)),
        location: '云南省大理市',
        participantsCount: 120,
        maxParticipants: 200,
        organizer: '云南文化旅游局',
        tags: ['文化节', '民族文化', '音乐舞蹈'],
        rating: 4.9,
        imageUrl: 'https://example.com/yunnan_festival.jpg',
      ),
      Activity(
        id: 'act_007',
        title: '海南海滩清洁行动',
        description: '加入海南三亚湾海滩清洁志愿活动，保护海洋环境，减少塑料污染。活动结束后将举行沙滩烧烤派对，感谢所有志愿者的参与。',
        icon: Icons.waves,
        color: const Color(0xFF00B4D8), // neonBlue
        startDate: now.add(const Duration(days: 8)),
        endDate: now.add(const Duration(days: 8, hours: 5)),
        location: '海南省三亚市三亚湾',
        participantsCount: 35,
        maxParticipants: 100,
        organizer: '蓝色海洋保护协会',
        tags: ['环保', '志愿活动', '海滩'],
        imageUrl: 'https://example.com/sanya_beach.jpg',
      ),
      Activity(
        id: 'act_008',
        title: '西安古城墙骑行',
        description: '在中国最完整的古城墙上骑行，环绕西安内城，欣赏古都风貌。途中将有文化讲解员介绍西安历史和相关景点。',
        icon: Icons.directions_bike,
        color: const Color(0xFFFFD700), // neonYellow
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 3, hours: 3)),
        location: '陕西省西安市城墙',
        participantsCount: 40,
        maxParticipants: 50,
        organizer: '西安旅游局',
        tags: ['骑行', '历史文化', '户外活动'],
        isRegistered: true,
        rating: 4.7,
      ),
    ];
  }
}
