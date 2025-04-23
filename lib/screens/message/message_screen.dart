import 'package:flutter/material.dart';
import '../../app_theme.dart';

class MessageScreen extends StatefulWidget {
  final Function? onBackPressed;

  const MessageScreen({Key? key, this.onBackPressed}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with SingleTickerProviderStateMixin {
  // 标签控制器
  late TabController _tabController;

  // 消息数据
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'id': 1,
      'sender': '旅行助手',
      'avatar': 'https://randomuser.me/api/portraits/women/44.jpg',
      'lastMessage': '您的行程已更新，点击查看详情',
      'time': '10:30',
      'unread': 2,
      'isOfficial': true,
    },
    {
      'id': 2,
      'sender': '张旅游',
      'avatar': 'https://randomuser.me/api/portraits/men/32.jpg',
      'lastMessage': '这个景点真的不错，推荐你有空去看看！',
      'time': '昨天',
      'unread': 0,
      'isOfficial': false,
    },
    {
      'id': 3,
      'sender': '李导游',
      'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
      'lastMessage': '您预约的导游服务已确认，请准时到达集合地点',
      'time': '周二',
      'unread': 1,
      'isOfficial': false,
    },
    {
      'id': 4,
      'sender': '景区客服',
      'avatar': 'https://randomuser.me/api/portraits/men/75.jpg',
      'lastMessage': '您的反馈我们已收到，感谢您的宝贵意见',
      'time': '上周',
      'unread': 0,
      'isOfficial': true,
    },
  ];

  // 通知数据
  final List<Map<String, dynamic>> _notifications = [
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

  // 系统消息数据
  final List<Map<String, dynamic>> _systemMessages = [
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

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 初始化标签控制器
    _tabController = TabController(length: 3, vsync: this);

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // 启动动画
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题和搜索区域
            _buildHeader(),

            // 标签栏
            _buildTabBar(),

            // 标签内容
            Expanded(
              child: FadeTransition(
                opacity: _animation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 消息列表
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
    );
  }

  // 构建顶部标题和搜索区域
  Widget _buildHeader() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(_animation),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.onBackPressed != null)
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.primaryTextColor,
                    ),
                    onPressed: () => widget.onBackPressed!(),
                  ),
                Expanded(
                  child: Text(
                    '消息中心',
                    style: TextStyle(
                      color: AppTheme.primaryTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign:
                        widget.onBackPressed == null
                            ? TextAlign.left
                            : TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: AppTheme.primaryTextColor,
                  ),
                  onPressed: () {
                    // 打开消息设置
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('消息设置功能即将推出'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 搜索框
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.secondaryTextColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: AppTheme.primaryTextColor),
                      decoration: InputDecoration(
                        hintText: '搜索消息',
                        hintStyle: TextStyle(
                          color: AppTheme.secondaryTextColor,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        // 搜索消息
                        if (value.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('搜索: $value'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
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

  // 构建标签栏
  Widget _buildTabBar() {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(_animation),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.cardColor.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.buttonColor,
          indicatorWeight: 3,
          labelColor: AppTheme.buttonColor,
          unselectedLabelColor: AppTheme.secondaryTextColor,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          tabs: [Tab(text: '聊天'), Tab(text: '通知'), Tab(text: '系统')],
        ),
      ),
    );
  }

  // 构建聊天列表
  Widget _buildChatList() {
    if (_chatMessages.isEmpty) {
      return _buildEmptyState('暂无聊天消息', Icons.chat_bubble_outline);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chatMessages.length,
      itemBuilder: (context, index) {
        final message = _chatMessages[index];
        return _buildChatItem(message);
      },
    );
  }

  // 构建单个聊天项
  Widget _buildChatItem(Map<String, dynamic> message) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + (0.2 * (message['id'] / _chatMessages.length)),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(message['avatar']),
                    ),
                    if (message['isOfficial'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.buttonColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.backgroundColor,
                              width: 2,
                            ),
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

                const SizedBox(width: 16),

                // 消息内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            message['sender'],
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            message['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
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
                              style: TextStyle(
                                color:
                                    message['unread'] > 0
                                        ? AppTheme.primaryTextColor
                                        : AppTheme.secondaryTextColor,
                                fontSize: 14,
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
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.buttonColor,
                                borderRadius: BorderRadius.circular(12),
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
    );
  }

  // 构建通知列表
  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState('暂无通知', Icons.notifications_none);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  // 构建单个通知项
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + (0.2 * (notification['id'] / _notifications.length)),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              notification['isRead']
                  ? AppTheme.cardColor.withOpacity(0.3)
                  : AppTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border:
              notification['isRead']
                  ? null
                  : Border.all(
                    color: notification['iconColor'].withOpacity(0.3),
                    width: 1,
                  ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification['iconColor'].withOpacity(0.1),
                    shape: BoxShape.circle,
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
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight:
                                    notification['isRead']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notification['iconColor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        notification['content'],
                        style: TextStyle(
                          color:
                              notification['isRead']
                                  ? AppTheme.secondaryTextColor
                                  : AppTheme.primaryTextColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        notification['time'],
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建系统消息列表
  Widget _buildSystemMessagesList() {
    if (_systemMessages.isEmpty) {
      return _buildEmptyState('暂无系统消息', Icons.info_outline);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _systemMessages.length,
      itemBuilder: (context, index) {
        final message = _systemMessages[index];
        return _buildSystemMessageItem(message);
      },
    );
  }

  // 构建单个系统消息项
  Widget _buildSystemMessageItem(Map<String, dynamic> message) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + (0.2 * (message['id'] / _systemMessages.length)),
            1.0,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              message['isRead']
                  ? AppTheme.cardColor.withOpacity(0.3)
                  : AppTheme.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border:
              message['isRead']
                  ? null
                  : Border.all(
                    color: message['iconColor'].withOpacity(0.3),
                    width: 1,
                  ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: message['iconColor'].withOpacity(0.1),
                    shape: BoxShape.circle,
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
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight:
                                    message['isRead']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!message['isRead'])
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: message['iconColor'],
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        message['content'],
                        style: TextStyle(
                          color:
                              message['isRead']
                                  ? AppTheme.secondaryTextColor
                                  : AppTheme.primaryTextColor.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        message['time'],
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
