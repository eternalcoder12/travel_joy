import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import 'dart:math' as math;

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  // 动画控制器
  late AnimationController _backgroundController;
  late AnimationController _itemController;
  late AnimationController _particleController;
  late AnimationController _podiumController;

  // 排行榜数据
  List<LeaderboardUser> leaderboardData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _itemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _podiumController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 加载排行榜数据
    _loadLeaderboardData();

    // 启动动画
    _backgroundController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _podiumController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _itemController.forward();
    });
  }

  void _loadLeaderboardData() {
    // 模拟加载数据，实际应用中应该从服务器获取数据
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          leaderboardData = [
            LeaderboardUser(
              id: '1',
              rank: 1,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '张三',
              points: 9876,
              level: 18,
              positionChange: 0,
            ),
            LeaderboardUser(
              id: '2',
              rank: 2,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '李四',
              points: 8654,
              level: 15,
              positionChange: 2,
            ),
            LeaderboardUser(
              id: '3',
              rank: 3,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '王五',
              points: 7543,
              level: 14,
              positionChange: -1,
            ),
            LeaderboardUser(
              id: '4',
              rank: 4,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '赵六',
              points: 6789,
              level: 12,
              positionChange: 3,
            ),
            LeaderboardUser(
              id: '5',
              rank: 5,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '钱七',
              points: 5432,
              level: 10,
              positionChange: 0,
            ),
            LeaderboardUser(
              id: '6',
              rank: 6,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '孙八',
              points: 4567,
              level: 9,
              positionChange: -2,
            ),
            LeaderboardUser(
              id: '7',
              rank: 7,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '周九',
              points: 3456,
              level: 8,
              positionChange: 1,
            ),
            LeaderboardUser(
              id: '8',
              rank: 8,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '吴十',
              points: 2345,
              level: 7,
              positionChange: -1,
            ),
            LeaderboardUser(
              id: '9',
              rank: 9,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '郑十一',
              points: 1234,
              level: 6,
              positionChange: 2,
            ),
            LeaderboardUser(
              id: '10',
              rank: 10,
              avatar: 'assets/images/avatars/default_avatar.png',
              name: '冯十二',
              points: 987,
              level: 5,
              positionChange: 4,
            ),
          ];
          isLoading = false;
        });
      }
    });
  }

  void _refreshLeaderboard() {
    setState(() {
      isLoading = true;
    });

    // 重置动画
    _backgroundController.reset();
    _itemController.reset();
    _podiumController.reset();

    // 重新加载数据
    _loadLeaderboardData();

    // 重新播放动画
    _backgroundController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _podiumController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _itemController.forward();
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _itemController.dispose();
    _particleController.dispose();
    _podiumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-20 * (1.0 - _backgroundController.value), 0),
              child: Opacity(
                opacity: _backgroundController.value,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppTheme.primaryTextColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            );
          },
        ),
        title: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Opacity(
              opacity: _backgroundController.value,
              child: const Text(
                '旅行者排行榜',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(20 * (1.0 - _backgroundController.value), 0),
                child: Opacity(
                  opacity: _backgroundController.value,
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: AppTheme.primaryTextColor,
                    ),
                    onPressed: _refreshLeaderboard,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部栏和前三名
          _buildLeaderboardHeader(),

          // 排行榜列表
          Expanded(child: _buildLeaderboardList()),
        ],
      ),
    );
  }

  Widget _buildLeaderboardHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 统计信息
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return Opacity(
                  opacity: _backgroundController.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        icon: Icons.emoji_events,
                        title: '我的排名',
                        value: '24',
                        color: AppTheme.neonOrange,
                      ),
                      _buildStatItem(
                        icon: Icons.star,
                        title: '我的积分',
                        value: '1,865',
                        color: AppTheme.neonYellow,
                      ),
                      _buildStatItem(
                        icon: Icons.trending_up,
                        title: '距上一名',
                        value: '192分',
                        color: AppTheme.neonGreen,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 前三名容器
          _buildTopUsers(),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTopUsers() {
    // 确保至少有3个用户显示
    final topUsers =
        isLoading
            ? List.generate(3, (index) => null)
            : leaderboardData.take(3).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 第二名底座
          AnimatedBuilder(
            animation: _podiumController,
            builder: (context, child) {
              return Positioned(
                left: 20,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - _podiumController.value)),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildRankBase(
                      height: 70,
                      width: 80,
                      rank: 2,
                      color: const Color(0xFFADD8E6), // 淡蓝色
                    ),
                  ),
                ),
              );
            },
          ),

          // 第一名底座
          AnimatedBuilder(
            animation: _podiumController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - _podiumController.value)),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildRankBase(
                      height: 100,
                      width: 90,
                      rank: 1,
                      color: const Color(0xFFFFD700), // 金色
                    ),
                  ),
                ),
              );
            },
          ),

          // 第三名底座
          AnimatedBuilder(
            animation: _podiumController,
            builder: (context, child) {
              return Positioned(
                right: 20,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _podiumController.value)),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildRankBase(
                      height: 50,
                      width: 80,
                      rank: 3,
                      color: const Color(0xFFD2B48C), // 铜色
                    ),
                  ),
                ),
              );
            },
          ),

          // 第二名头像
          if (!isLoading && topUsers.length > 1)
            AnimatedBuilder(
              animation: _podiumController,
              builder: (context, child) {
                final user = topUsers[1];
                return Positioned(
                  left: 30,
                  bottom: 70,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - _podiumController.value)),
                    child: Opacity(
                      opacity: _podiumController.value,
                      child: _buildTopUserAvatar(user!, 2),
                    ),
                  ),
                );
              },
            ),

          // 第一名头像
          if (!isLoading && topUsers.isNotEmpty)
            AnimatedBuilder(
              animation: _podiumController,
              builder: (context, child) {
                final user = topUsers[0];
                return Positioned(
                  bottom: 100,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - _podiumController.value)),
                    child: Opacity(
                      opacity: _podiumController.value,
                      child: _buildTopUserAvatar(user!, 1),
                    ),
                  ),
                );
              },
            ),

          // 第三名头像
          if (!isLoading && topUsers.length > 2)
            AnimatedBuilder(
              animation: _podiumController,
              builder: (context, child) {
                final user = topUsers[2];
                return Positioned(
                  right: 30,
                  bottom: 50,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - _podiumController.value)),
                    child: Opacity(
                      opacity: _podiumController.value,
                      child: _buildTopUserAvatar(user!, 3),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRankBase({
    required double height,
    required double width,
    required int rank,
    required Color color,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildTopUserAvatar(LeaderboardUser user, int rank) {
    final isCrowned = rank == 1;

    return Column(
      children: [
        if (isCrowned)
          CustomPaint(size: const Size(30, 20), painter: CrownPainter()),
        const SizedBox(height: 5),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rank == 1
                    ? const Color(0xFFFFD700)
                    : rank == 2
                    ? const Color(0xFFADD8E6)
                    : const Color(0xFFD2B48C),
                Colors.white,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(user.avatar),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Lv.${user.level}',
              style: TextStyle(
                color:
                    rank == 1
                        ? const Color(0xFFFFD700)
                        : rank == 2
                        ? const Color(0xFFADD8E6)
                        : const Color(0xFFD2B48C),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 10,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              '${user.points}分',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaderboardData.length,
      itemBuilder: (context, index) {
        // 前3名在顶部已经显示，这里跳过
        if (index < 3) return const SizedBox.shrink();

        final user = leaderboardData[index];
        return AnimatedBuilder(
          animation: _itemController,
          builder: (context, child) {
            final delay = index * 0.05;
            final curvedAnimation = CurvedAnimation(
              parent: _itemController,
              curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
            );

            return Transform.translate(
              offset: Offset(0, 50 * (1 - curvedAnimation.value)),
              child: Opacity(
                opacity: curvedAnimation.value,
                child: _buildLeaderboardItem(user),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardUser user) {
    final rankColor =
        user.rank <= 10 ? AppTheme.neonBlue : AppTheme.secondaryTextColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 排名
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColor.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  '${user.rank}',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 用户头像
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(user.avatar),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 用户信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.buttonColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Lv.${user.level}',
                          style: const TextStyle(
                            color: AppTheme.buttonColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: AppTheme.neonYellow,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.points}',
                        style: const TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 排名变化
            _buildPositionChangeIndicator(user.positionChange),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionChangeIndicator(int change) {
    if (change == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          '-',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final isUp = change > 0;
    final color = isUp ? AppTheme.neonGreen : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            change.abs().toString(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFFFD700)
          ..style = PaintingStyle.fill;

    final path = Path();

    // 绘制皇冠
    path.moveTo(size.width / 2, 0); // 顶点
    path.lineTo(0, size.height * 0.6); // 左侧
    path.lineTo(size.width * 0.3, size.height * 0.4); // 左凹槽
    path.lineTo(size.width / 2, size.height); // 中间
    path.lineTo(size.width * 0.7, size.height * 0.4); // 右凹槽
    path.lineTo(size.width, size.height * 0.6); // 右侧
    path.close();

    // 绘制装饰
    canvas.drawPath(path, paint);

    // 添加高光
    final highlightPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    final highlightPath = Path();
    highlightPath.moveTo(size.width / 2, size.height * 0.2);
    highlightPath.lineTo(size.width * 0.2, size.height * 0.5);
    highlightPath.lineTo(size.width * 0.35, size.height * 0.4);
    highlightPath.close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LeaderboardUser {
  final String id;
  final int rank;
  final String avatar;
  final String name;
  final int points;
  final int level;
  final int positionChange; // 正数表示上升，负数表示下降，0表示不变

  LeaderboardUser({
    required this.id,
    required this.rank,
    required this.avatar,
    required this.name,
    required this.points,
    required this.level,
    required this.positionChange,
  });
}
