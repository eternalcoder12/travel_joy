import 'package:flutter/material.dart';
import '../../app_theme.dart';

class MessageScreen extends StatefulWidget {
  final Function? onBackPressed;

  const MessageScreen({Key? key, this.onBackPressed}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with TickerProviderStateMixin {
  // 标签控制器
  late TabController _tabController;

  // 消息数据
  late List<Map<String, dynamic>> _chatMessages;
  late List<Map<String, dynamic>> _notifications;
  late List<Map<String, dynamic>> _systemMessages;

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 标签切换动画控制器
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;

  // 图片加载错误标志
  bool _hasImageLoadError = false;

  @override
  void initState() {
    super.initState();

    // 初始化消息数据
    _initMessageData();

    // 初始化标签控制器
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _tabAnimationController.forward(from: 0.0);
      }
    });

    // 初始化动画控制器 - 减少动画时间确保内容更快显示
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500), // 减少动画时间
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // 初始化标签切换动画控制器 - 也加快一点
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300), // 减少动画时间
      vsync: this,
    );

    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画
    _animationController.forward();
    // 预先启动一次标签动画，确保初始内容显示
    _tabAnimationController.forward();
  }

  // 初始化消息数据
  void _initMessageData() {
    _chatMessages = [
      {
        'id': 1,
        'sender': '旅行助手',
        'avatar': 'assets/images/avatar1.png', // 使用本地图片避免网络错误
        'lastMessage': '您的行程已更新，点击查看详情',
        'time': '10:30',
        'unread': 2,
        'isOfficial': true,
      },
      {
        'id': 2,
        'sender': '张旅游',
        'avatar': 'assets/images/avatar2.png',
        'lastMessage': '这个景点真的不错，推荐你有空去看看！',
        'time': '昨天',
        'unread': 0,
        'isOfficial': false,
      },
      {
        'id': 3,
        'sender': '李导游',
        'avatar': 'assets/images/avatar3.png',
        'lastMessage': '您预约的导游服务已确认，请准时到达集合地点',
        'time': '周二',
        'unread': 1,
        'isOfficial': false,
      },
      {
        'id': 4,
        'sender': '景区客服',
        'avatar': 'assets/images/avatar4.png',
        'lastMessage': '您的反馈我们已收到，感谢您的宝贵意见',
        'time': '上周',
        'unread': 0,
        'isOfficial': true,
      },
    ];

    _notifications = [
      {
        'id': 1,
        'title': '您的门票预订成功',
        'content': '您预订的西湖景区门票已确认，请于6月15日前往景区',
        'time': '今天 09:15',
        'icon': Icons.confirmation_number,
        'iconColor': AppTheme.successColor,
        'isRead': false,
      },
      {
        'id': 2,
        'title': '行程提醒',
        'content': '您明天有计划前往故宫博物院，请提前做好准备',
        'time': '昨天 18:30',
        'icon': Icons.event_note,
        'iconColor': AppTheme.buttonColor,
        'isRead': true,
      },
      {
        'id': 3,
        'title': '限时优惠',
        'content': '端午节期间，热门景点门票8折优惠，点击查看详情',
        'time': '06-01 14:20',
        'icon': Icons.local_offer,
        'iconColor': AppTheme.neonOrange,
        'isRead': false,
      },
      {
        'id': 4,
        'title': '天气提醒',
        'content': '您计划前往的目的地明天可能有雨，请做好防雨准备',
        'time': '05-28 20:10',
        'icon': Icons.wb_cloudy,
        'iconColor': AppTheme.neonBlue,
        'isRead': true,
      },
    ];

    _systemMessages = [
      {
        'id': 1,
        'title': '系统升级通知',
        'content': '我们的应用将于今晚22:00-23:00进行系统维护，期间部分功能可能无法使用',
        'time': '今天 15:00',
        'icon': Icons.system_update,
        'iconColor': AppTheme.neonPurple,
        'isRead': false,
      },
      {
        'id': 2,
        'title': '隐私政策更新',
        'content': '我们的隐私政策已更新，请点击查看最新内容',
        'time': '昨天 12:30',
        'icon': Icons.privacy_tip,
        'iconColor': AppTheme.buttonColor,
        'isRead': true,
      },
      {
        'id': 3,
        'title': '账号安全提醒',
        'content': '建议您定期修改密码以提高账号安全性',
        'time': '05-25 09:45',
        'icon': Icons.security,
        'iconColor': AppTheme.neonPink,
        'isRead': true,
      },
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 设置透明背景，避免白色边框
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor, Color(0xFF2E2E4A)],
          ),
          // 确保没有额外的边框
          border: null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题
              _buildHeader(context),

              // 标签栏
              _buildTabBar(context),

              // 标签内容
              Expanded(
                child: FadeTransition(
                  opacity: _animation,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 聊天消息列表
                      _buildChatList(),

                      // 通知列表
                      _buildNotificationsList(),

                      // 系统消息列表
                      _buildSystemMessagesList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // 移除所有可能的底部装饰
      bottomNavigationBar: null,
    );
  }

  // 构建顶部标题和搜索区域
  Widget _buildHeader(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.3),
        end: Offset.zero,
      ).animate(_animation),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 标题行 - 居中显示，删除设置图标，调整文字大小
            Center(
              child: Text(
                '消息',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 28, // 调整文字大小
                ),
              ),
            ),

            // 删除搜索框，添加一个间隔
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 构建标签栏
  Widget _buildTabBar(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.4),
              AppTheme.cardColor.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3D7EF8), // 更鲜艳的蓝色
                Color(0xFF8A56E8), // 更鲜艳的紫色
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3D7EF8).withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          // 移除底部线条
          indicatorPadding: const EdgeInsets.all(4),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorWeight: 0, // 设置为0移除底部线条
          dividerColor: Colors.transparent, // 设置分隔线为透明
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          tabs: const [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 16),
                  SizedBox(width: 6),
                  Text('聊天'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 16),
                  SizedBox(width: 6),
                  Text('通知'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('系统'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建聊天列表
  Widget _buildChatList() {
    if (_chatMessages.isEmpty) {
      return _buildEmptyState('暂无聊天消息', Icons.chat_bubble_outline);
    }

    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Opacity(opacity: _tabAnimation.value, child: child);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 16.0),
        itemCount: _chatMessages.length + 1, // 添加一项用于显示底部提示
        itemBuilder: (context, index) {
          if (index < _chatMessages.length) {
            final message = _chatMessages[index];
            return _buildChatItem(message, index);
          } else {
            // 底部提示
            return _buildBottomTip('打开与 旅行助手 的对话');
          }
        },
      ),
    );
  }

  // 构建底部提示
  Widget _buildBottomTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            // 移除所有边框
            border: null,
          ),
          child: Text(
            text,
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
          ),
        ),
      ),
    );
  }

  // 构建单个聊天项
  Widget _buildChatItem(Map<String, dynamic> message, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (0.05 * index),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.8),
              AppTheme.cardColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.buttonColor.withOpacity(0.1),
            highlightColor: AppTheme.buttonColor.withOpacity(0.05),
            onTap: () {
              // 打开对话详情
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('打开与 ${message['sender']} 的对话'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 头像 - 使用本地图片或占位图标替代网络图片
                  Hero(
                    tag: 'avatar_${message['id']}',
                    child: Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.neonBlue.withOpacity(0.8),
                                AppTheme.neonPurple.withOpacity(0.8),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonBlue.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(27),
                            child: Container(
                              color: AppTheme.cardColor,
                              child: Center(
                                child: Text(
                                  message['sender'][0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (message['isOfficial'])
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.buttonColor,
                                    AppTheme.accentColor,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.cardColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.buttonColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.verified,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 消息内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                message['sender'],
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              message['time'],
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                message['lastMessage'],
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      message['unread'] > 0
                                          ? AppTheme.primaryTextColor
                                          : AppTheme.secondaryTextColor,
                                  fontWeight:
                                      message['unread'] > 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            if (message['unread'] > 0)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.buttonColor,
                                      AppTheme.accentColor,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.buttonColor.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  message['unread'].toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }

  // 构建通知列表
  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState('暂无通知', Icons.notifications_none);
    }

    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Opacity(opacity: _tabAnimation.value, child: child);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return _buildNotificationItem(notification, index);
        },
      ),
    );
  }

  // 构建单个通知项
  Widget _buildNotificationItem(Map<String, dynamic> notification, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (0.05 * index),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.8),
              AppTheme.cardColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: notification['iconColor'].withOpacity(0.1),
            highlightColor: notification['iconColor'].withOpacity(0.05),
            onTap: () {
              // 查看通知详情
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('查看通知: ${notification['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          notification['iconColor'].withOpacity(0.2),
                          notification['iconColor'].withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: notification['iconColor'].withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      notification['icon'],
                      color: notification['iconColor'],
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 通知内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification['title'],
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight:
                                      notification['isRead']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification['isRead'])
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: notification['iconColor'],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: notification['iconColor']
                                          .withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          notification['content'],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                notification['isRead']
                                    ? AppTheme.secondaryTextColor
                                    : AppTheme.primaryTextColor.withOpacity(
                                      0.8,
                                    ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          notification['time'],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建系统消息列表
  Widget _buildSystemMessagesList() {
    if (_systemMessages.isEmpty) {
      return _buildEmptyState('暂无系统消息', Icons.settings);
    }

    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Opacity(opacity: _tabAnimation.value, child: child);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 16.0),
        itemCount: _systemMessages.length,
        itemBuilder: (context, index) {
          final message = _systemMessages[index];
          return _buildSystemMessageItem(message, index);
        },
      ),
    );
  }

  // 构建单个系统消息项
  Widget _buildSystemMessageItem(Map<String, dynamic> message, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + (0.05 * index),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.8),
              AppTheme.cardColor.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: message['iconColor'].withOpacity(0.1),
            highlightColor: message['iconColor'].withOpacity(0.05),
            onTap: () {
              // 查看系统消息详情
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('查看系统消息: ${message['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          message['iconColor'].withOpacity(0.2),
                          message['iconColor'].withOpacity(0.1),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: message['iconColor'].withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      message['icon'],
                      color: message['iconColor'],
                      size: 24,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // 消息内容
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                message['title'],
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTextColor,
                                  fontWeight:
                                      message['isRead']
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!message['isRead'])
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: message['iconColor'],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: message['iconColor'].withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Text(
                          message['content'],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color:
                                message['isRead']
                                    ? AppTheme.secondaryTextColor
                                    : AppTheme.primaryTextColor.withOpacity(
                                      0.8,
                                    ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          message['time'],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建空状态提示
  Widget _buildEmptyState(String message, IconData icon) {
    return FadeTransition(
      opacity: _tabAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
