import 'dart:math';
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class MessageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> messageData;

  const MessageDetailScreen({Key? key, required this.messageData})
    : super(key: key);

  @override
  State<MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<MessageDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // 动画控制器
  late AnimationController _fadeInController;
  late AnimationController _typingController;

  // 假消息列表
  late List<Map<String, dynamic>> _messages;

  // 是否显示"对方正在输入"的状态
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // 生成示例消息
    _initMessages();

    // 启动入场动画
    _fadeInController.forward();

    // 500ms后滚动到底部
    Future.delayed(const Duration(milliseconds: 500), () {
      _scrollToBottom();
    });

    // 模拟"对方正在输入"状态
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = true;
      });

      // 3秒后添加一条新消息
      Future.delayed(const Duration(seconds: 3), () {
        final String title =
            widget.messageData['title'] ?? widget.messageData['sender'] ?? '对话';
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': '好的，我们约${title.contains('导游') ? '明天上午10点' : '周末'}见面吧！',
            'sender': 'other',
            'time': '现在',
            'isRead': true,
          });
        });

        // 滚动到底部
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      });
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _typingController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 初始化消息列表
  void _initMessages() {
    final Random random = Random();
    String greeting;
    String question;

    // 添加null检查和默认值
    final String title =
        widget.messageData['title'] ?? widget.messageData['sender'] ?? '对话';

    if (title.contains('导游')) {
      greeting = '您好！我是您的专属导游小李。';
      question = '您计划什么时候出发呢？我可以为您安排行程。';
    } else if (title.contains('酒店')) {
      greeting = '您好！感谢您选择我们的酒店。';
      question = '您有任何特殊需求吗？我们很乐意为您服务。';
    } else {
      greeting = '您好！很高兴认识您。';
      question = '有什么我可以帮到您的吗？';
    }

    _messages = [
      {
        'id': '1',
        'content': greeting,
        'sender': 'other',
        'time': '昨天 14:30',
        'isRead': true,
      },
      {
        'id': '2',
        'content': '你好！很高兴认识你！',
        'sender': 'me',
        'time': '昨天 14:35',
        'isRead': true,
      },
      {
        'id': '3',
        'content': question,
        'sender': 'other',
        'time': '昨天 14:40',
        'isRead': true,
      },
      {
        'id': '4',
        'content': '我想了解一下${title.contains('导游') ? '行程安排' : '详细信息'}',
        'sender': 'me',
        'time': '昨天 14:45',
        'isRead': true,
      },
    ];
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

  // 发送消息
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'content': _messageController.text,
        'sender': 'me',
        'time': '现在',
        'isRead': true,
      });
      _messageController.clear();
    });

    // 滚动到底部
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    // 模拟对方正在输入
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = true;
      });

      // 随机2-4秒后添加一条回复
      Future.delayed(Duration(seconds: 2 + Random().nextInt(3)), () {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': _getRandomResponse(),
            'sender': 'other',
            'time': '现在',
            'isRead': true,
          });
        });

        // 滚动到底部
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      });
    });
  }

  // 获取随机回复
  String _getRandomResponse() {
    final List<String> responses = [
      '好的，没问题！',
      '我明白了，我会尽快为您安排。',
      '您的要求已收到，请稍等片刻。',
      '感谢您的信息，我们会妥善处理。',
      '收到，我们很乐意为您提供帮助。',
      '我了解了，有任何其他需求请随时告诉我。',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  // 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    final Color avatarColor = widget.messageData['avatarColor'] ?? Colors.blue;
    final String title =
        widget.messageData['title'] ?? widget.messageData['sender'] ?? '对话';
    final IconData icon = widget.messageData['icon'] ?? Icons.person;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppTheme.primaryTextColor,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [avatarColor, avatarColor.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: avatarColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child:
                widget.messageData['avatar'] != null
                    ? ClipOval(
                      child: Image.asset(
                        widget.messageData['avatar'],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(icon, color: Colors.white, size: 20);
                        },
                      ),
                    )
                    : Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _isTyping ? '对方正在输入...' : '在线',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _isTyping
                            ? AppTheme.accentColor
                            : AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('语音通话功能即将上线'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('更多选项'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  // 构建主体内容
  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.backgroundColor.withOpacity(0.8),
            AppTheme.backgroundColor,
          ],
        ),
      ),
      child: Column(
        children: [
          // 消息列表
          Expanded(
            child: FadeTransition(
              opacity: _fadeInController,
              child:
                  _messages.isEmpty
                      ? Center(
                        child: Text(
                          '暂无消息',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            // 对方正在输入的提示
                            return _buildTypingIndicator();
                          }
                          final message = _messages[index];
                          return _buildMessageItem(message, index);
                        },
                      ),
            ),
          ),

          // 输入框
          _buildInputArea(),
        ],
      ),
    );
  }

  // 构建消息项
  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final bool isFromMe = message['sender'] == 'me';
    final bool showAvatar =
        index == 0 || _messages[index - 1]['sender'] != message['sender'];
    final Color avatarColor = widget.messageData['avatarColor'] ?? Colors.blue;
    final IconData icon = widget.messageData['icon'] ?? Icons.person;

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
              child:
                  widget.messageData['avatar'] != null
                      ? ClipOval(
                        child: Image.asset(
                          widget.messageData['avatar'],
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(icon, color: Colors.white, size: 16);
                          },
                        ),
                      )
                      : Icon(icon, color: Colors.white, size: 16),
            )
          else if (!isFromMe)
            const SizedBox(width: 44),

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
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
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      isFromMe
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                  bottomRight:
                      isFromMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                color: Colors.blueGrey,
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: AssetImage('assets/images/avatar.jpg'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            )
          else if (isFromMe)
            const SizedBox(width: 44),
        ],
      ),
    );
  }

  // 构建"对方正在输入"的提示
  Widget _buildTypingIndicator() {
    final Color avatarColor = widget.messageData['avatarColor'] ?? Colors.blue;
    final IconData icon = widget.messageData['icon'] ?? Icons.person;

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
            child:
                widget.messageData['avatar'] != null
                    ? ClipOval(
                      child: Image.asset(
                        widget.messageData['avatar'],
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(icon, color: Colors.white, size: 16);
                        },
                      ),
                    )
                    : Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(
                              0.4 + (0.6 * _getTypingOpacity(i)),
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取打字动画的不透明度
  double _getTypingOpacity(int dotIndex) {
    final double offset = dotIndex * 0.2;
    final double t = (_typingController.value + offset) % 1.0;

    if (t < 0.5) {
      return t * 2;
    } else {
      return (1.0 - t) * 2;
    }
  }

  // 构建输入区域
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppTheme.accentColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('附件功能即将上线'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.secondaryTextColor.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _messageController,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '输入消息...',
                    hintStyle: TextStyle(
                      color: AppTheme.secondaryTextColor.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
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
      ),
    );
  }
}
