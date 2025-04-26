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
    // 确保至少有3名用户
    while (leaderboardData.length < 3) {
      leaderboardData.add(
        LeaderboardUser(
          id: 'placeholder-${leaderboardData.length + 1}',
          rank: leaderboardData.length + 1,
          avatar: 'assets/images/avatars/default_avatar.png',
          name: '用户${leaderboardData.length + 1}',
          points: 0,
          level: 1,
          positionChange: 0,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _podiumController,
      builder: (context, child) {
        // 第二名的偏移和透明度动画
        final secondUserOffsetY =
            Tween<double>(begin: 50.0, end: 0.0)
                .animate(
                  CurvedAnimation(
                    parent: _podiumController,
                    curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
                  ),
                )
                .value;

        // 第一名的偏移和透明度动画
        final firstUserOffsetY =
            Tween<double>(begin: 80.0, end: 0.0)
                .animate(
                  CurvedAnimation(
                    parent: _podiumController,
                    curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
                  ),
                )
                .value;

        // 第三名的偏移和透明度动画
        final thirdUserOffsetY =
            Tween<double>(begin: 50.0, end: 0.0)
                .animate(
                  CurvedAnimation(
                    parent: _podiumController,
                    curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
                  ),
                )
                .value;

        return Container(
          width: double.infinity,
          height: 280,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 第二名（左侧）
              Positioned(
                left: 0,
                bottom: 30,
                child: Transform.translate(
                  offset: Offset(0, secondUserOffsetY),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildTopUserAvatar(
                      leaderboardData[1],
                      80,
                      AppTheme.neonBlue,
                      showCrown: false,
                    ),
                  ),
                ),
              ),

              // 第一名（中间）
              Positioned(
                bottom: 30,
                child: Transform.translate(
                  offset: Offset(0, firstUserOffsetY),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildTopUserAvatar(
                      leaderboardData[0],
                      100,
                      Colors.amber,
                      showCrown: true,
                    ),
                  ),
                ),
              ),

              // 第三名（右侧）
              Positioned(
                right: 0,
                bottom: 30,
                child: Transform.translate(
                  offset: Offset(0, thirdUserOffsetY),
                  child: Opacity(
                    opacity: _podiumController.value,
                    child: _buildTopUserAvatar(
                      leaderboardData[2],
                      70,
                      AppTheme.accentColor,
                      showCrown: false,
                    ),
                  ),
                ),
              ),

              // 排名基座
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 70,
                  child: Stack(
                    children: [
                      // 第二名基座
                      Positioned(
                        left: 20,
                        bottom: 0,
                        child: _buildRankBase(
                          70,
                          AppTheme.neonBlue,
                          '2',
                          animation: _podiumController,
                          delay: const Interval(
                            0.1,
                            0.6,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),

                      // 第一名基座
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: _buildRankBase(
                            100,
                            Colors.amber,
                            '1',
                            animation: _podiumController,
                            delay: const Interval(
                              0.2,
                              0.7,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                      ),

                      // 第三名基座
                      Positioned(
                        right: 20,
                        bottom: 0,
                        child: _buildRankBase(
                          50,
                          AppTheme.accentColor,
                          '3',
                          animation: _podiumController,
                          delay: const Interval(
                            0.0,
                            0.5,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建排名基座
  Widget _buildRankBase(
    double height,
    Color color,
    String rank, {
    required Animation<double> animation,
    required Interval delay,
  }) {
    final heightAnim = Tween<double>(
      begin: 0.0,
      end: height,
    ).animate(CurvedAnimation(parent: animation, curve: delay));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 70,
          height: heightAnim.value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Opacity(
              opacity: animation.value,
              child: Text(
                rank,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建顶部用户头像
  Widget _buildTopUserAvatar(
    LeaderboardUser user,
    double size,
    Color color, {
    bool showCrown = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 皇冠
        if (showCrown)
          SizedBox(
            width: 60,
            height: 30,
            child: CustomPaint(painter: CrownPainter(color: Colors.amber)),
          ),

        // 用户头像
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 3),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(child: Image.asset(user.avatar, fit: BoxFit.cover)),
        ),

        const SizedBox(height: 8),

        // 用户名称
        Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // 等级和积分
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.5), width: 1),
              ),
              child: Text(
                'Lv.${user.level}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${user.points}分',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
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
        return _buildLeaderboardItem(user, index);
      },
    );
  }

  // 构建排行榜项目
  Widget _buildLeaderboardItem(LeaderboardUser user, int index) {
    final rankColor =
        user.rank <= 10 ? AppTheme.accentColor : AppTheme.secondaryTextColor;

    return AnimatedBuilder(
      animation: _itemController,
      builder: (context, child) {
        // 为每个项目应用延迟进入动画
        final delay = index * 0.1;
        final startTime = delay * 0.75;
        final endTime = startTime + 0.25;

        double animationValue;
        if (_itemController.value < startTime) {
          animationValue = 0.0;
        } else if (_itemController.value >= endTime) {
          animationValue = 1.0;
        } else {
          animationValue =
              (_itemController.value - startTime) / (endTime - startTime);
        }

        // 使用Curves.easeOutBack曲线使动画更加生动
        final curveValue = Curves.easeOutBack.transform(animationValue);

        return Transform.translate(
          offset: Offset(0, 50 * (1.0 - curveValue)),
          child: Opacity(
            opacity: curveValue,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 排名
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${user.rank}',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 头像
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentColor.withOpacity(0.5),
                          AppTheme.accentColor.withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(user.avatar, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 用户名和等级
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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
                                color: AppTheme.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Lv.${user.level}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.points}分',
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
                  _buildPositionChange(user.positionChange),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 构建排名变化指示器
  Widget _buildPositionChange(int change) {
    if (change == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.remove, color: Colors.grey, size: 14),
            SizedBox(width: 2),
            Text(
              '0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    final isUp = change > 0;
    final color = isUp ? Colors.green : Colors.red;
    final icon = isUp ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 2),
          Text(
            '${change.abs()}',
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

  // 构建霓虹背景
  Widget _buildNeonBackground() {
    return Stack(
      children: [
        // 深色渐变背景
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.9),
                AppTheme.backgroundColor.withOpacity(0.9),
              ],
            ),
          ),
        ),

        // 霓虹光效
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.5),
                  blurRadius: 150,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        Positioned(
          top: 150,
          right: -120,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.4),
                  blurRadius: 150,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        ),

        // 霓虹粒子效果
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height,
              ),
              painter: ParticlePainter(animation: _particleController),
            );
          },
        ),
      ],
    );
  }
}

class CrownPainter extends CustomPainter {
  final Color color;

  const CrownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
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

/// 粒子动画绘制器 - 用于创建霓虹粒子效果
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles;

  ParticlePainter({required this.animation})
    : particles = List.generate(50, (index) {
        return Particle(
          position: Offset(
            math.Random().nextDouble() * 400,
            math.Random().nextDouble() * 800,
          ),
          color:
              [
                AppTheme.neonBlue.withOpacity(0.6),
                Colors.pinkAccent.withOpacity(0.6),
                AppTheme.accentColor.withOpacity(0.6),
              ][math.Random().nextInt(3)],
          size: math.Random().nextDouble() * 6 + 1,
          speed: math.Random().nextDouble() * 2 + 0.5,
        );
      });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // 更新粒子位置，加入一些随机性和波动效果
      final yOffset =
          math.sin(animation.value * 2 * math.pi + particle.position.dx / 50) *
          5;
      final position = Offset(
        (particle.position.dx + particle.speed * animation.value * 20) %
            size.width,
        (particle.position.dy + yOffset) % size.height,
      );

      final paint =
          Paint()
            ..color = particle.color
            ..style = PaintingStyle.fill
            ..blendMode = BlendMode.srcOver;

      // 根据动画值调整粒子大小
      final particleSize =
          particle.size * (0.5 + 0.5 * math.sin(animation.value * 2 * math.pi));

      canvas.drawCircle(position, particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// 粒子模型
class Particle {
  Offset position;
  Color color;
  double size;
  double speed;

  Particle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
  });
}
