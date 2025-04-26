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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['全球榜', '好友榜', '城市榜'];
  bool _isLoading = true;

  // 添加动画控制器
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 模拟排行榜数据
  final List<Map<String, dynamic>> _leaderboardData = [
    {
      'rank': 1,
      'avatar': 'assets/images/avatar.jpg',
      'name': '艾米丽',
      'points': 12580,
      'level': 28,
      'isCurrentUser': true,
      'change': 0, // 0表示位置不变，1表示上升，-1表示下降
    },
    {
      'rank': 2,
      'avatar': 'assets/images/avatar2.jpg',
      'name': '李明',
      'points': 11024,
      'level': 26,
      'isCurrentUser': false,
      'change': 1,
    },
    {
      'rank': 3,
      'avatar': 'assets/images/avatar3.jpg',
      'name': '王小明',
      'points': 10895,
      'level': 25,
      'isCurrentUser': false,
      'change': -1,
    },
    {
      'rank': 4,
      'avatar': 'assets/images/avatar4.jpg',
      'name': '张三',
      'points': 9876,
      'level': 22,
      'isCurrentUser': false,
      'change': 2,
    },
    {
      'rank': 5,
      'avatar': 'assets/images/avatar5.jpg',
      'name': '李四',
      'points': 8654,
      'level': 20,
      'isCurrentUser': false,
      'change': 0,
    },
    {
      'rank': 6,
      'avatar': 'assets/images/avatar6.jpg',
      'name': '王五',
      'points': 7935,
      'level': 18,
      'isCurrentUser': false,
      'change': 1,
    },
    {
      'rank': 7,
      'avatar': 'assets/images/avatar7.jpg',
      'name': '赵六',
      'points': 7256,
      'level': 17,
      'isCurrentUser': false,
      'change': -3,
    },
    {
      'rank': 8,
      'avatar': 'assets/images/avatar8.jpg',
      'name': '钱七',
      'points': 6842,
      'level': 16,
      'isCurrentUser': false,
      'change': 1,
    },
    {
      'rank': 9,
      'avatar': 'assets/images/avatar9.jpg',
      'name': '孙八',
      'points': 6218,
      'level': 15,
      'isCurrentUser': false,
      'change': 2,
    },
    {
      'rank': 10,
      'avatar': 'assets/images/avatar10.jpg',
      'name': '周九',
      'points': 5982,
      'level': 14,
      'isCurrentUser': false,
      'change': -1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 模拟加载数据
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          // 添加动态渐变背景
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
          ),
        ),
        child: Stack(
          children: [
            // 动态光晕效果
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // 动态光晕效果1
                    Positioned(
                      left:
                          MediaQuery.of(context).size.width *
                          (0.3 +
                              0.3 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      top:
                          MediaQuery.of(context).size.height *
                          (0.3 +
                              0.2 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.neonGreen.withOpacity(0.4),
                              AppTheme.neonGreen.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // 动态光晕效果2
                    Positioned(
                      right:
                          MediaQuery.of(context).size.width *
                          (0.2 +
                              0.2 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi + 1,
                                  )),
                      bottom:
                          MediaQuery.of(context).size.height *
                          (0.2 +
                              0.2 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi + 1,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.neonBlue.withOpacity(0.3),
                              AppTheme.neonBlue.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // 主内容
            SafeArea(
              child: Column(
                children: [
                  // 自定义AppBar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 返回按钮
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: AppTheme.cardColor.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppTheme.primaryTextColor,
                              size: 20.0,
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                        ),

                        // 标题
                        Text(
                          "旅行排行榜",
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),

                        // 保持对称的空白区域
                        SizedBox(width: 48.0),
                      ],
                    ),
                  ),

                  // 自定义标签选择器
                  Container(
                    margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242539),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      labelColor: AppTheme.neonGreen,
                      unselectedLabelColor: AppTheme.secondaryTextColor,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 14.0,
                      ),
                      tabs:
                          _tabs
                              .map(
                                (tab) => Tab(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(tab),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // 主内容区域
                  Expanded(
                    child:
                        _isLoading
                            ? _buildLoadingState()
                            : TabBarView(
                              controller: _tabController,
                              children:
                                  _tabs
                                      .map(
                                        (tab) => _buildLeaderboardContent(tab),
                                      )
                                      .toList(),
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
          ),
          const SizedBox(height: 16),
          Text(
            "正在加载排行榜数据...",
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(String tabName) {
    return Column(
      children: [
        // 前三名特殊显示
        _buildTopThreeSection(),

        // 分割线
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppTheme.cardColor,
                  AppTheme.cardColor,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),

        // 排行榜列表
        Expanded(child: _buildLeaderboardList()),
      ],
    );
  }

  Widget _buildTopThreeSection() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 第二名
          _buildTopRanker(_leaderboardData[1], 2),

          // 第一名 (居中且最高)
          _buildTopRanker(_leaderboardData[0], 1),

          // 第三名
          _buildTopRanker(_leaderboardData[2], 3),
        ],
      ),
    );
  }

  Widget _buildTopRanker(Map<String, dynamic> userData, int position) {
    // 根据名次调整显示高度和样式
    double height = position == 1 ? 130.0 : (position == 2 ? 110.0 : 90.0);
    Color podiumColor =
        position == 1
            ? AppTheme.neonYellow
            : (position == 2 ? AppTheme.neonTeal : AppTheme.neonOrange);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 用户头像
        Stack(
          alignment: Alignment.center,
          children: [
            // 荣耀光环
            Container(
              width: position == 1 ? 90.0 : 75.0,
              height: position == 1 ? 90.0 : 75.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    podiumColor.withOpacity(0.7),
                    podiumColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.7, 0.9, 1.0],
                ),
              ),
            ),

            // 头像容器
            Container(
              width: position == 1 ? 80.0 : 65.0,
              height: position == 1 ? 80.0 : 65.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: podiumColor, width: 3.0),
                boxShadow: [
                  BoxShadow(
                    color: podiumColor.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(userData['avatar'], fit: BoxFit.cover),
              ),
            ),

            // 排名标记
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: podiumColor,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: podiumColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  "$position",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8.0),

        // 用户名
        Text(
          userData['name'],
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: position == 1 ? FontWeight.bold : FontWeight.w500,
            fontSize: position == 1 ? 16.0 : 14.0,
          ),
        ),

        // 积分
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
          decoration: BoxDecoration(
            color: podiumColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: podiumColor, size: 14.0),
              const SizedBox(width: 4.0),
              Text(
                "${userData['points']}",
                style: TextStyle(
                  color: podiumColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ),

        // 等级
        Container(
          margin: const EdgeInsets.only(top: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            "Lv.${userData['level']}",
            style: TextStyle(
              color: AppTheme.primaryTextColor.withOpacity(0.8),
              fontSize: 10.0,
            ),
          ),
        ),

        // 底座
        const SizedBox(height: 8.0),
        Container(
          width: position == 1 ? 80.0 : 65.0,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [podiumColor, podiumColor.withOpacity(0.6)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
            ),
            boxShadow: [
              BoxShadow(
                color: podiumColor.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.emoji_events,
              color: Colors.white.withOpacity(0.8),
              size: position == 1 ? 30.0 : 20.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _leaderboardData.length - 3, // 除去前三名
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final userData = _leaderboardData[index + 3]; // 从第4名开始
        return _buildLeaderboardItem(userData);
      },
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> userData) {
    // 排名变化指示器颜色
    Color changeColor =
        userData['change'] > 0
            ? AppTheme.successColor
            : (userData['change'] < 0
                ? AppTheme.errorColor
                : AppTheme.secondaryTextColor);

    // 排名变化图标
    IconData changeIcon =
        userData['change'] > 0
            ? Icons.arrow_upward_rounded
            : (userData['change'] < 0
                ? Icons.arrow_downward_rounded
                : Icons.remove);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              userData['isCurrentUser']
                  ? [
                    AppTheme.neonGreen.withOpacity(0.2),
                    AppTheme.cardColor.withOpacity(0.5),
                  ]
                  : [
                    AppTheme.cardColor.withOpacity(0.3),
                    AppTheme.cardColor.withOpacity(0.1),
                  ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        border:
            userData['isCurrentUser']
                ? Border.all(
                  color: AppTheme.neonGreen.withOpacity(0.8),
                  width: 1.5,
                )
                : null,
        boxShadow:
            userData['isCurrentUser']
                ? [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
                : null,
      ),
      child: Row(
        children: [
          // 排名
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  userData['isCurrentUser']
                      ? AppTheme.neonGreen.withOpacity(0.2)
                      : AppTheme.cardColor.withOpacity(0.5),
            ),
            child: Center(
              child: Text(
                "${userData['rank']}",
                style: TextStyle(
                  color:
                      userData['isCurrentUser']
                          ? AppTheme.neonGreen
                          : AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),

          // 头像
          Container(
            width: 45.0,
            height: 45.0,
            margin: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    userData['isCurrentUser']
                        ? AppTheme.neonGreen
                        : AppTheme.accentColor.withOpacity(0.5),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (userData['isCurrentUser']
                          ? AppTheme.neonGreen
                          : AppTheme.accentColor)
                      .withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(userData['avatar'], fit: BoxFit.cover),
            ),
          ),

          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userData['name'],
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                      ),
                    ),
                    if (userData['isCurrentUser'])
                      Container(
                        margin: const EdgeInsets.only(left: 8.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          "我",
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "Lv.${userData['level']}",
                        style: const TextStyle(
                          color: AppTheme.neonPurple,
                          fontSize: 10.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      Icons.star_rounded,
                      color: AppTheme.neonYellow,
                      size: 14.0,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      "${userData['points']}",
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 排名变化
          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: changeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(changeIcon, color: changeColor, size: 16.0),
                Text(
                  userData['change'] != 0 ? "${userData['change'].abs()}" : "-",
                  style: TextStyle(
                    color: changeColor,
                    fontWeight: FontWeight.bold,
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
}
