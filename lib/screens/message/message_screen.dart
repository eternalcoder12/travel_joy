import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'message_detail_screen.dart';
import 'notification_detail_screen.dart';
import 'system_message_detail_screen.dart';
import '../../utils/navigation_utils.dart';
import '../chat/chat_detail_screen.dart';
import 'dart:math' as math;

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

  // 置顶消息数据
  late Map<String, dynamic> _pinnedMessage;

  // 背景动画控制器
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 动画控制器
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 标签切换动画控制器
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;

  // 搜索框动画控制器
  late AnimationController _searchAnimController;
  late Animation<double> _searchAnimation = const AlwaysStoppedAnimation(0.0);

  // 图片加载错误标志
  bool _hasImageLoadError = false;

  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  bool _isSearchFocused = false;
  List<Map<String, dynamic>> _searchResults = [];

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
      // 添加状态更新，确保选中指示器更新
      setState(() {});
    });

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化动画控制器 - 减少动画时间确保内容更快显示
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // 增加动画时间使效果更明显
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // 初始化标签切换动画控制器
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabAnimation = CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeOutCubic,
    );

    // 初始化搜索框动画控制器 - 确保在使用前完成初始化
    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 重新初始化 _searchAnimation 以防止 LateInitializationError
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeOutCubic,
    );

    // 监听搜索框焦点变化
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        _searchAnimController.forward();
      } else if (!_isSearching) {
        _searchAnimController.reverse();
      }
    });

    // 启动动画
    _animationController.forward();
    // 预先启动一次标签动画，确保初始内容显示
    _tabAnimationController.forward();
  }

  // 初始化消息数据
  void _initMessageData() {
    // 置顶消息
    _pinnedMessage = {
      'id': 0,
      'sender': '旅行规划助手',
      'avatar': 'assets/images/avatar_pin.png',
      'lastMessage': '您的行程计划已生成，查看详情并确认行程安排',
      'time': '09:45',
      'unread': 1,
      'isOfficial': true,
      'isPinned': true,
    };

    _chatMessages = [
      {
        'id': 1,
        'sender': '旅行助手',
        'avatar': 'assets/images/avatar1.png',
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
      {
        'id': 5,
        'sender': '旅游社区',
        'avatar': 'assets/images/avatar5.png',
        'lastMessage': '您分享的摄影作品获得了52个赞',
        'time': '3天前',
        'unread': 1,
        'isOfficial': true,
      },
      {
        'id': 6,
        'sender': '酒店预订',
        'avatar': 'assets/images/avatar6.png',
        'lastMessage': '您预订的房间已确认，入住日期为7月15日',
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
      {
        'id': 5,
        'title': '好友动态',
        'content': '您的好友张三刚刚分享了一条旅行动态',
        'time': '今天 11:30',
        'icon': Icons.people,
        'iconColor': AppTheme.neonBlue,
        'isRead': false,
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
      {
        'id': 4,
        'title': '新功能上线',
        'content': '我们上线了景点实时人流量查询功能，出行前先看看',
        'time': '06-05 10:15',
        'icon': Icons.new_releases,
        'iconColor': AppTheme.neonOrange,
        'isRead': false,
      },
    ];
  }

  // 执行搜索
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // 搜索聊天消息
      _searchResults = [];

      // 搜索聊天记录
      for (var message in _chatMessages) {
        if (message['sender'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            message['lastMessage'].toString().toLowerCase().contains(
              query.toLowerCase(),
            )) {
          _searchResults.add({...message, 'type': 'chat'});
        }
      }

      // 搜索通知
      for (var notification in _notifications) {
        if (notification['title'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            notification['content'].toString().toLowerCase().contains(
              query.toLowerCase(),
            )) {
          _searchResults.add({...notification, 'type': 'notification'});
        }
      }

      // 搜索系统消息
      for (var sysMsg in _systemMessages) {
        if (sysMsg['title'].toString().toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            sysMsg['content'].toString().toLowerCase().contains(
              query.toLowerCase(),
            )) {
          _searchResults.add({...sysMsg, 'type': 'system'});
        }
      }
    });
  }

  // 获取未读消息总数
  int get _unreadCount {
    int count = 0;

    // 计算聊天未读数
    for (var msg in _chatMessages) {
      count += msg['unread'] as int;
    }
    if (_pinnedMessage['unread'] != null) {
      count += _pinnedMessage['unread'] as int;
    }

    // 计算通知未读数
    for (var note in _notifications) {
      if (note['isRead'] == false) count++;
    }

    // 计算系统消息未读数
    for (var sys in _systemMessages) {
      if (sys['isRead'] == false) count++;
    }

    return count;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _tabAnimationController.dispose();
    _backgroundAnimController.dispose();
    _searchAnimController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 设置透明背景，避免白色边框
      body: Stack(
        children: [
          // 动态渐变背景
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
                  ),
                ),
                child: Stack(
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
                              AppTheme.neonBlue.withOpacity(0.4),
                              AppTheme.neonBlue.withOpacity(0.1),
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
                              AppTheme.neonPurple.withOpacity(0.3),
                              AppTheme.neonPurple.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (_isSearching)
                  _buildSearchResults()
                else ...[
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildChatMessagesList(),
                        _buildNotificationsList(),
                        _buildSystemMessagesList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 更美观的顶部设计
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 页面标题
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSearching ? '搜索结果' : '消息',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // 未读消息统计 - 只在有未读消息且不在搜索时显示
              if (_unreadCount > 0 && !_isSearching)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.neonBlue.withOpacity(0.8),
                        AppTheme.neonPurple.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.neonBlue.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.mark_chat_unread_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // 副标题
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '管理你的所有通讯与系统信息',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建搜索栏
  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.fromLTRB(
        16.0,
        _isSearchFocused ? 8.0 : 16.0,
        16.0,
        _isSearchFocused ? 8.0 : 16.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _isSearchFocused
                ? AppTheme.neonBlue.withOpacity(0.3)
                : AppTheme.cardColor.withOpacity(0.4),
            _isSearchFocused
                ? AppTheme.neonPurple.withOpacity(0.3)
                : AppTheme.cardColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color:
                _isSearchFocused
                    ? AppTheme.neonBlue.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(color: AppTheme.primaryTextColor),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          hintText: '搜索聊天、通知和系统消息',
          hintStyle: TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 15,
          ),
          prefixIcon: AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.search,
                  color: Color.lerp(
                    AppTheme.secondaryTextColor,
                    AppTheme.neonBlue,
                    _searchAnimation.value,
                  ),
                  size: 22 + (2 * _searchAnimation.value),
                ),
              );
            },
          ),
          border: InputBorder.none,
          suffixIcon:
              _isSearching || _searchController.text.isNotEmpty
                  ? AnimatedOpacity(
                    opacity:
                        _isSearching || _searchController.text.isNotEmpty
                            ? 1.0
                            : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.secondaryTextColor,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _isSearching = false;
                            _searchResults = [];
                          });
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  )
                  : null,
        ),
        onChanged: (value) {
          _performSearch(value);
        },
        onSubmitted: (value) {
          _performSearch(value);
          if (value.isNotEmpty) {
            _searchFocusNode.requestFocus();
          }
        },
      ),
    );
  }

  // 构建搜索结果
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 70,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '没有找到相关内容',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '尝试使用其他关键词',
              style: TextStyle(
                color: AppTheme.secondaryTextColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];

          switch (result['type']) {
            case 'chat':
              return _buildSearchChatItem(result, index);
            case 'notification':
              return _buildSearchNotificationItem(result, index);
            case 'system':
              return _buildSearchSystemItem(result, index);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  // 构建搜索结果中的聊天项
  Widget _buildSearchChatItem(Map<String, dynamic> message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neonBlue.withOpacity(0.1),
            AppTheme.cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonBlue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.neonBlue.withOpacity(0.1),
          highlightColor: AppTheme.neonBlue.withOpacity(0.05),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MessageDetailScreen(messageData: message),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.neonBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chat_outlined,
                    color: AppTheme.neonBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            message['sender'],
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            message['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message['lastMessage'],
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // 构建搜索结果中的通知项
  Widget _buildSearchNotificationItem(
    Map<String, dynamic> notification,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            notification['iconColor'].withOpacity(0.1),
            AppTheme.cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: notification['iconColor'].withOpacity(0.1),
            blurRadius: 8,
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
            // 导航到通知详情页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => NotificationDetailScreen(
                      notificationData: notification,
                    ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: notification['iconColor'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['iconColor'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight:
                                    notification['isRead']
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            notification['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
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
                                  : AppTheme.primaryTextColor.withOpacity(0.85),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // 构建搜索结果中的系统消息项
  Widget _buildSearchSystemItem(Map<String, dynamic> message, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            message['iconColor'].withOpacity(0.1),
            AppTheme.cardColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: message['iconColor'].withOpacity(0.1),
            blurRadius: 8,
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
            // 导航到系统消息详情页
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        SystemMessageDetailScreen(messageData: message),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: message['iconColor'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    message['icon'],
                    color: message['iconColor'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message['title'],
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight:
                                    message['isRead']
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            message['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
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
                                  : AppTheme.primaryTextColor.withOpacity(0.85),
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  // 构建标签栏
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          // 半透明背景
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24.0),
            ),
          ),
          // 标签栏
          TabBar(
            controller: _tabController,
            // 完全去除指示器
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.neonBlue.withOpacity(0.8),
                  AppTheme.neonPurple.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelPadding: EdgeInsets.zero,
            padding: const EdgeInsets.all(4.0),
            // 去除分割线
            dividerColor: Colors.transparent,
            // 去除点击效果
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            // 设置标签宽度填充满
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade400,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
            tabs: [Tab(text: '聊天'), Tab(text: '通知'), Tab(text: '系统')],
          ),
        ],
      ),
    );
  }

  // 构建聊天列表
  Widget _buildChatMessagesList() {
    if (_chatMessages.isEmpty) {
      return _buildEmptyState('暂无聊天消息', Icons.chat_bubble_outline);
    }

    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Opacity(opacity: _tabAnimation.value, child: child);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
        itemCount: _chatMessages.length + 2, // +1 for pinned, +1 for bottom tip
        itemBuilder: (context, index) {
          if (index == 0) {
            // 置顶消息
            return _buildPinnedChatItem(_pinnedMessage);
          } else if (index <= _chatMessages.length) {
            final message = _chatMessages[index - 1];
            return _buildChatItem(message, index - 1);
          } else {
            // 底部提示
            return _buildBottomTip('打开与 旅行助手 的对话');
          }
        },
      ),
    );
  }

  // 构建置顶消息
  Widget _buildPinnedChatItem(Map<String, dynamic> message) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.3, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF5F6D).withOpacity(0.8),
              const Color(0xFFFFC371).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5F6D).withOpacity(0.4),
              blurRadius: 12.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20.0),
            onTap: () {
              // 导航到详情页
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MessageDetailScreen(messageData: message),
                ),
              );
            },
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 置顶标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin,
                              color: Colors.white,
                              size: 12.0,
                            ),
                            SizedBox(width: 4.0),
                            Text(
                              '置顶',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // 时间
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          message['time'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头像
                      Hero(
                        tag: 'pinned_avatar',
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8.0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              message['sender'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      // 消息内容
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['sender'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6.0),
                            Text(
                              message['lastMessage'],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15.0,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建底部提示
  Widget _buildBottomTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.neonBlue.withOpacity(0.3),
                AppTheme.neonPurple.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonBlue.withOpacity(0.2),
                blurRadius: 8.0,
                spreadRadius: 1.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppTheme.neonBlue.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: AppTheme.primaryTextColor.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardColor.withOpacity(0.7),
                AppTheme.cardColor.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              splashColor: AppTheme.buttonColor.withOpacity(0.1),
              highlightColor: AppTheme.buttonColor.withOpacity(0.05),
              onTap: () => _navigateToChatDetail(message),
              onHover: (isHovering) {
                // 实现悬浮效果逻辑
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 头像
                    Hero(
                      tag: 'avatar_${message['id']}',
                      child: Stack(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.neonBlue.withOpacity(0.7),
                                  AppTheme.neonPurple.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.3),
                                  blurRadius: 10.0,
                                  spreadRadius: 1.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: AppTheme.cardColor.withOpacity(0.7),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                message['sender'][0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (message['isOfficial'])
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppTheme.buttonColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.backgroundColor,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.buttonColor.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 6.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  size: 10,
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
                                  style: TextStyle(
                                    color: AppTheme.primaryTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  message['time'],
                                  style: TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 12,
                                  ),
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
                                                .withOpacity(0.9)
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
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.buttonColor,
                                        AppTheme.neonBlue,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.buttonColor.withOpacity(
                                          0.4,
                                        ),
                                        blurRadius: 6.0,
                                        spreadRadius: 1.0,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      message['unread'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.7),
              AppTheme.cardColor.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: notification['iconColor'].withOpacity(0.1),
            highlightColor: notification['iconColor'].withOpacity(0.05),
            onTap: () => _navigateToNotificationDetail(notification),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          notification['iconColor'].withOpacity(0.7),
                          notification['iconColor'].withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: notification['iconColor'].withOpacity(0.3),
                          blurRadius: 8.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.cardColor.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      notification['icon'],
                      color: Colors.white,
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
                                          ? FontWeight.w500
                                          : FontWeight.w600,
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
                                      blurRadius: 4.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
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
                                    : AppTheme.primaryTextColor.withOpacity(
                                      0.85,
                                    ),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            notification['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
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
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
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
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.cardColor.withOpacity(0.7),
              AppTheme.cardColor.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: message['iconColor'].withOpacity(0.1),
            highlightColor: message['iconColor'].withOpacity(0.05),
            onTap: () => _navigateToSystemMessageDetail(message),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          message['iconColor'].withOpacity(0.7),
                          message['iconColor'].withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: message['iconColor'].withOpacity(0.3),
                          blurRadius: 8.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.cardColor.withOpacity(0.7),
                        width: 2,
                      ),
                    ),
                    child: Icon(message['icon'], color: Colors.white, size: 24),
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
                                          ? FontWeight.w500
                                          : FontWeight.w600,
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
                                      blurRadius: 4.0,
                                      spreadRadius: 1.0,
                                    ),
                                  ],
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
                                    : AppTheme.primaryTextColor.withOpacity(
                                      0.85,
                                    ),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            message['time'],
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                            ),
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.2),
                    AppTheme.neonPurple.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.2),
                    blurRadius: 15.0,
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '暂时没有内容可显示',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.8),
                    AppTheme.buttonColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.3),
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '刷新',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
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

  void _navigateToNotificationDetail(Map<String, dynamic> notificationData) {
    NavigationUtils.glowingNavigateTo(
      context: context,
      page: NotificationDetailScreen(notificationData: notificationData),
    );
  }

  void _navigateToSystemMessageDetail(Map<String, dynamic> messageData) {
    NavigationUtils.glowingNavigateTo(
      context: context,
      page: SystemMessageDetailScreen(messageData: messageData),
    );
  }

  void _navigateToChatDetail(Map<String, dynamic> chatMessage) {
    NavigationUtils.slideAndFadeNavigateTo(
      context: context,
      page: ChatDetailScreen(chatMessage: chatMessage),
    );
  }
}
