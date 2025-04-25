import 'package:flutter/material.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final Color color;
  final IconData icon;
  final int participantsCount;
  final int maxParticipants;
  final bool isHot; // 是否热门
  final bool isNew; // 是否新活动
  final List<String> tags;
  final double price; // 价格，0表示免费
  final String organizerName;
  final bool isFavorite; // 是否收藏

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.color,
    required this.icon,
    required this.participantsCount,
    required this.maxParticipants,
    this.isHot = false,
    this.isNew = false,
    required this.tags,
    required this.price,
    required this.organizerName,
    this.isFavorite = false,
  });

  // 判断活动是否已结束
  bool get isFinished => DateTime.now().isAfter(endDate);

  // 判断活动是否正在进行中
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  // 判断活动是否即将开始
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  // 获取活动状态文本
  String get statusText {
    if (isFinished) {
      return "已结束";
    } else if (isOngoing) {
      return "进行中";
    } else {
      return "即将开始";
    }
  }

  // 获取活动状态颜色
  Color get statusColor {
    if (isFinished) {
      return Colors.grey;
    } else if (isOngoing) {
      return const Color(0xFF4CAF50); // 绿色
    } else {
      return const Color(0xFF00B4D8); // 蓝色
    }
  }

  // 剩余名额
  int get remainingSpots => maxParticipants - participantsCount;

  // 是否已满员
  bool get isFull => participantsCount >= maxParticipants;

  // 工厂方法：创建样例活动列表
  static List<Activity> getSampleActivities() {
    return [
      Activity(
        id: 'act_001',
        title: '徒步黄山三日游',
        description: '探索中国最美的山脉之一，欣赏云海日出和奇松怪石，体验中国传统山水画的真实场景。专业导游带队，含住宿和餐食。',
        location: '安徽省黄山市',
        startDate: DateTime.now().add(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        imageUrl: 'assets/images/activities/huangshan.jpg',
        color: const Color(0xFF39D353), // 绿色
        icon: Icons.terrain,
        participantsCount: 18,
        maxParticipants: 25,
        isHot: true,
        tags: ['户外', '徒步', '摄影', '团建'],
        price: 1580,
        organizerName: '户外探险俱乐部',
      ),
      Activity(
        id: 'act_002',
        title: '西湖单车环湖',
        description: '骑行西湖一周，欣赏湖光山色，途经十景名胜，品尝地道杭帮菜。提供专业自行车和骑行装备，专业教练带队。',
        location: '浙江省杭州市',
        startDate: DateTime.now().add(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 3)),
        imageUrl: 'assets/images/activities/westlake.jpg',
        color: const Color(0xFF00B4D8), // 蓝色
        icon: Icons.directions_bike,
        participantsCount: 10,
        maxParticipants: 15,
        isNew: true,
        tags: ['骑行', '休闲', '摄影'],
        price: 128,
        organizerName: '乐行单车俱乐部',
      ),
      Activity(
        id: 'act_003',
        title: '云南美食文化节',
        description: '体验云南多民族美食文化，品尝过桥米线、汽锅鸡、饵丝等特色美食，观看民族歌舞表演，参与互动体验活动。',
        location: '云南省昆明市',
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        imageUrl: 'assets/images/activities/yunnan_food.jpg',
        color: const Color(0xFFFF9E00), // 橙色
        icon: Icons.restaurant,
        participantsCount: 200,
        maxParticipants: 300,
        isHot: true,
        tags: ['美食', '文化', '节日'],
        price: 298,
        organizerName: '云南旅游局',
      ),
      Activity(
        id: 'act_004',
        title: '北京胡同深度游',
        description: '走进老北京胡同，探访四合院文化，体验传统手工艺，品尝老北京小吃。专业文化讲解员带队，提供详细历史文化背景介绍。',
        location: '北京市东城区',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        imageUrl: 'assets/images/activities/beijing_hutong.jpg',
        color: const Color(0xFF9D4EDD), // 紫色
        icon: Icons.history_edu,
        participantsCount: 8,
        maxParticipants: 12,
        tags: ['文化', '历史', '城市探索'],
        price: 158,
        organizerName: '北京文化遗产保护协会',
      ),
      Activity(
        id: 'act_005',
        title: '三亚海滩瑜伽课',
        description: '在美丽的三亚海滩上，伴随着海浪声，在专业瑜伽教练指导下进行晨练，放松身心，感受阳光与海风。提供瑜伽垫和装备。',
        location: '海南省三亚市亚龙湾',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        imageUrl: 'assets/images/activities/sanya_yoga.jpg',
        color: const Color(0xFFFF48C4), // 粉色
        icon: Icons.self_improvement,
        participantsCount: 15,
        maxParticipants: 20,
        isNew: true,
        tags: ['瑜伽', '健康', '海滩', '放松'],
        price: 298,
        organizerName: '三亚健康生活方式促进会',
      ),
      Activity(
        id: 'act_006',
        title: '重庆火锅品鉴之旅',
        description:
            '探访重庆最地道的火锅店，了解火锅文化历史，学习辨别各种食材和锅底，体验正宗重庆火锅的麻辣鲜香。包含3家知名火锅店品鉴。',
        location: '重庆市渝中区',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        imageUrl: 'assets/images/activities/chongqing_hotpot.jpg',
        color: const Color(0xFFE63946), // 红色
        icon: Icons.local_fire_department,
        participantsCount: 12,
        maxParticipants: 12,
        isHot: true,
        tags: ['美食', '文化', '体验'],
        price: 368,
        organizerName: '重庆美食协会',
      ),
      Activity(
        id: 'act_007',
        title: '莫干山竹海徒步',
        description: '穿越莫干山竹海，感受竹林的清新与宁静，聆听竹叶沙沙声，体验农家乐，品尝山野美食。含专业向导和午餐。',
        location: '浙江省湖州市德清县',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'assets/images/activities/moganshan.jpg',
        color: const Color(0xFF2EC4B6), // 青色
        icon: Icons.forest,
        participantsCount: 20,
        maxParticipants: 30,
        tags: ['徒步', '自然', '摄影', '美食'],
        price: 198,
        organizerName: '莫干山旅游协会',
      ),
      Activity(
        id: 'act_008',
        title: '故宫文化夜游',
        description:
            '夜晚的故宫别有一番韵味，在专业讲解员的带领下，了解故宫的历史与文化，欣赏夜色中的紫禁城，体验与白天完全不同的氛围。',
        location: '北京市东城区故宫博物院',
        startDate: DateTime.now().add(const Duration(days: 20)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        imageUrl: 'assets/images/activities/forbidden_city_night.jpg',
        color: const Color(0xFFFFD700), // 金色
        icon: Icons.nightlight_round,
        participantsCount: 45,
        maxParticipants: 60,
        isNew: true,
        tags: ['文化', '历史', '夜游', '摄影'],
        price: 258,
        organizerName: '故宫博物院',
      ),
      Activity(
        id: 'act_009',
        title: '免费城市定向挑战赛',
        description: '在城市中进行团队定向挑战，解决谜题，完成任务，探索城市的角落，体验团队合作的乐趣。适合朋友、同事或家庭参与。',
        location: '全国多地同时举行',
        startDate: DateTime.now().add(const Duration(days: 13)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        imageUrl: 'assets/images/activities/city_challenge.jpg',
        color: const Color(0xFF00B4D8), // 蓝色
        icon: Icons.emoji_events,
        participantsCount: 120,
        maxParticipants: 200,
        isHot: true,
        tags: ['团队', '挑战', '城市探索', '免费'],
        price: 0,
        organizerName: '城市探索者联盟',
      ),
      Activity(
        id: 'act_010',
        title: '传统陶艺工作坊',
        description: '跟随陶艺大师学习传统陶艺技艺，亲手制作陶器，了解陶艺历史和文化，带走自己的作品。含材料费和午餐。',
        location: '江苏省宜兴市丁蜀镇',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        imageUrl: 'assets/images/activities/pottery.jpg',
        color: const Color(0xFF9D4EDD), // 紫色
        icon: Icons.design_services,
        participantsCount: 8,
        maxParticipants: 10,
        tags: ['文化', '手工', '艺术', '体验'],
        price: 368,
        organizerName: '宜兴紫砂文化协会',
      ),
    ];
  }
}
