import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chatMessage;

  const ChatDetailScreen({Key? key, required this.chatMessage})
    : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 动画控制器
  late AnimationController _fadeInController;
  late AnimationController _typingController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 假消息列表
  late List<Map<String, dynamic>> _messages;

  // 是否显示"对方正在输入"的状态
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // 背景动画
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 初始化消息列表（聊天历史）
    _initMessages();

    // 模拟2.5秒后收到回复
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });

        // 模拟1.5秒后收到消息
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _receiveMessage(
                '感谢您的咨询！我会尽快为您解答关于${widget.chatMessage['title']}的问题。',
              );
            });
            // 自动滚动到底部
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollToBottom();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _typingController.dispose();
    _backgroundAnimController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 初始化消息列表
  void _initMessages() {
    final String topic = widget.chatMessage['title'] ?? '旅行计划';
    final String time = widget.chatMessage['time'] ?? '刚刚';

    _messages = [
      {
        'content': '您好，我想咨询一下关于$topic的问题',
        'time': time,
        'sender': 'me',
        'isRead': true,
      },
    ];
  }

  // 发送消息
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'content': text,
        'time': '刚刚',
        'sender': 'me',
        'isRead': false,
      });
    });

    _messageController.clear();
    _scrollToBottom();

    // 模拟对方输入中的状态
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isTyping = true;
        });

        // 模拟延迟接收消息
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _isTyping = false;
              _receiveMessage(_getAutoReplyMessage(text));
            });
            _scrollToBottom();
          }
        });
      }
    });
  }

  // 接收消息
  void _receiveMessage(String text) {
    setState(() {
      _messages.add({
        'content': text,
        'time': '刚刚',
        'sender': 'other',
        'isRead': true,
      });
    });
  }

  // 获取自动回复消息
  String _getAutoReplyMessage(String message) {
    final String topic = widget.chatMessage['title'] ?? '旅行';

    if (message.contains('价格') ||
        message.contains('多少钱') ||
        message.contains('费用')) {
      return '关于$topic的价格，目前我们有多种套餐可选，经济型约¥2000起，舒适型约¥3500起，豪华型约¥5800起。具体价格会根据出行日期、人数等因素调整。';
    } else if (message.contains('时间') ||
        message.contains('几月') ||
        message.contains('什么时候')) {
      return '$topic的最佳游览时间是4-6月和9-10月，此时气候宜人，景色最美。暑假和节假日期间游客较多，建议错峰出行。';
    } else if (message.contains('攻略') ||
        message.contains('建议') ||
        message.contains('推荐')) {
      return '我推荐$topic的行程安排为3-5天，可以充分体验当地特色。必去景点包括XXX、YYY和ZZZ，建议预订官方门票避免排队。当地美食不可错过AAA和BBB。';
    } else {
      return '感谢您对$topic的关注！请问您还有什么具体的问题需要了解的吗？例如行程安排、价格、最佳出游时间等，我都可以为您提供详细信息。';
    }
  }

  // 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.chatMessage['iconColor'] ?? Colors.blue;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 动态背景
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.backgroundColor, const Color(0xFF1E1E30)],
                  ),
                ),
                child: Stack(
                  children: [
                    // 动态光晕效果
                    Positioned(
                      right:
                          MediaQuery.of(context).size.width *
                          (0.1 +
                              0.2 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      top:
                          MediaQuery.of(context).size.height *
                          (0.1 +
                              0.1 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // 第二个动态光晕
                    Positioned(
                      left:
                          MediaQuery.of(context).size.width *
                          (0.2 +
                              0.1 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      bottom:
                          MediaQuery.of(context).size.height *
                          (0.1 +
                              0.15 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.neonBlue.withOpacity(0.15),
                              AppTheme.neonBlue.withOpacity(0.03),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
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
                _buildAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInController,
                    child: _buildChatContent(),
                  ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建应用栏
  Widget _buildAppBar() {
    final String title = widget.chatMessage['title'] ?? '聊天';
    final Color color = widget.chatMessage['iconColor'] ?? Colors.blue;
    final IconData icon = widget.chatMessage['icon'] ?? Icons.chat;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppTheme.primaryTextColor,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '在线',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.primaryTextColor,
              size: 24,
            ),
            onPressed: () {
              // 显示更多选项菜单
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildOptionsSheet(),
              );
            },
          ),
        ],
      ),
    );
  }

  // 构建聊天内容
  Widget _buildChatContent() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _buildMessageItem(_messages[index], index);
        } else {
          return _buildTypingIndicator();
        }
      },
    );
  }

  // 构建消息项
  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final bool isFromMe = message['sender'] == 'me';
    final bool showAvatar =
        index == 0 || _messages[index - 1]['sender'] != message['sender'];
    final Color avatarColor = widget.chatMessage['iconColor'] ?? Colors.blue;
    final IconData icon = widget.chatMessage['icon'] ?? Icons.person;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromMe && showAvatar)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [avatarColor, avatarColor.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: avatarColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            )
          else if (!isFromMe)
            const SizedBox(width: 44),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isFromMe
                          ? [
                            AppTheme.accentColor.withOpacity(0.8),
                            AppTheme.accentColor,
                          ]
                          : [
                            AppTheme.cardColor.withOpacity(0.9),
                            AppTheme.cardColor.withOpacity(0.7),
                          ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      isFromMe
                          ? const Radius.circular(20)
                          : const Radius.circular(2),
                  bottomRight:
                      isFromMe
                          ? const Radius.circular(2)
                          : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        isFromMe
                            ? AppTheme.accentColor.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['content'],
                    style: TextStyle(
                      color:
                          isFromMe ? Colors.white : AppTheme.primaryTextColor,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time'],
                        style: TextStyle(
                          color:
                              isFromMe
                                  ? Colors.white.withOpacity(0.7)
                                  : AppTheme.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                      if (isFromMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 12,
                          color:
                              message['isRead']
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.white.withOpacity(0.4),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isFromMe && showAvatar)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            )
          else if (isFromMe)
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  // 构建"对方正在输入"的指示器
  Widget _buildTypingIndicator() {
    final Color avatarColor = widget.chatMessage['iconColor'] ?? Colors.blue;
    final IconData icon = widget.chatMessage['icon'] ?? Icons.person;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [avatarColor, avatarColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: avatarColor.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      final double offset = math.sin(
                        (_typingController.value * math.pi * 2) +
                            (index * math.pi / 2),
                      );
                      return Transform.translate(
                        offset: Offset(0, -3 * offset),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTextColor.withOpacity(
                              0.6 + (0.4 * ((offset + 1) / 2)),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                // 显示附加功能
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: AppTheme.primaryTextColor),
                decoration: InputDecoration(
                  hintText: '发送消息...',
                  hintStyle: TextStyle(color: AppTheme.secondaryTextColor),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentColor,
                  AppTheme.accentColor.withOpacity(0.8),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, size: 20),
              color: Colors.white,
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  // 构建选项底部菜单
  Widget _buildOptionsSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildOptionItem(
            icon: Icons.videocam_outlined,
            title: '视频通话',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('视频通话功能即将推出')));
            },
          ),
          _buildOptionItem(
            icon: Icons.call_outlined,
            title: '语音通话',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('语音通话功能即将推出')));
            },
          ),
          _buildOptionItem(
            icon: Icons.search_outlined,
            title: '搜索',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('搜索功能即将推出')));
            },
          ),
          _buildOptionItem(
            icon: Icons.notifications_off_outlined,
            title: '静音',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已静音此聊天')));
            },
          ),
        ],
      ),
    );
  }

  // 构建单个选项项
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryTextColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
