import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class SystemMessageDetailScreen extends StatefulWidget {
  final Map<String, dynamic> messageData;

  const SystemMessageDetailScreen({Key? key, required this.messageData})
    : super(key: key);

  @override
  State<SystemMessageDetailScreen> createState() =>
      _SystemMessageDetailScreenState();
}

class _SystemMessageDetailScreenState extends State<SystemMessageDetailScreen>
    with TickerProviderStateMixin {
  // 动画控制器
  late AnimationController _fadeInController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // 模拟系统消息操作状态
  bool _isActionTaken = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // 初始化淡入动画控制器
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    // 背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 脉冲动画控制器
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 如果系统消息未读，标记为已读
    if (widget.messageData['isRead'] == false) {
      // 实际应用中，这里应该调用API更新消息状态
      widget.messageData['isRead'] = true;
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _backgroundAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
                  ),
                ),
                child: Stack(
                  children: [
                    // 动态光晕效果 - 使用系统消息图标颜色
                    Positioned(
                      right:
                          MediaQuery.of(context).size.width *
                          (0.2 +
                              0.2 *
                                  math.cos(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      top:
                          MediaQuery.of(context).size.height *
                          (0.2 +
                              0.1 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.messageData['iconColor'].withOpacity(0.3),
                              widget.messageData['iconColor'].withOpacity(0.1),
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
                _buildAppBar(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInController,
                    child: _buildMessageContent(),
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建应用栏
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.4),
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
          // 标题
          Expanded(
            child: Text(
              '系统消息',
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          // 更多选项
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_vert,
                color: AppTheme.primaryTextColor,
                size: 20,
              ),
            ),
            onPressed: () {
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

  // 构建消息内容
  Widget _buildMessageContent() {
    final Color iconColor = widget.messageData['iconColor'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 系统图标和标题区域
          Center(
            child: Column(
              children: [
                // 图标容器
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              iconColor.withOpacity(0.9),
                              iconColor.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.messageData['icon'],
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // 标题
                Text(
                  widget.messageData['title'],
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // 时间
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.messageData['time'],
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // 消息内容
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.cardColor.withOpacity(0.8),
                  AppTheme.cardColor.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 消息主体
                Text(
                  widget.messageData['content'],
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                // 扩展内容
                if (_isExpanded) ...[
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 20),

                  // 获取详细内容（根据消息类型不同）
                  ..._getDetailedContent(),
                ],

                // 展开/收起按钮
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: iconColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isExpanded ? '收起' : '展开',
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: iconColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 状态徽章 - 显示系统消息处理状态
          if (_getStatusBadge() != null) _getStatusBadge()!,

          const SizedBox(height: 30),

          // 相关系统消息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '相关系统消息',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildRelatedMessages(),
            ],
          ),
        ],
      ),
    );
  }

  // 构建底部操作按钮
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child:
          _isActionTaken ? _buildActionTakenButton() : _buildActionButtons2(),
    );
  }

  // 操作按钮 - 未执行操作时
  Widget _buildActionButtons2() {
    return Row(
      children: [
        // 次要操作按钮
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: widget.messageData['iconColor'],
              side: BorderSide(
                color: widget.messageData['iconColor'].withOpacity(0.5),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              // 忽略/稍后提醒逻辑
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已忽略此消息')));
              Navigator.pop(context);
            },
            child: const Text(
              '忽略',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 主操作按钮
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(
                widget.messageData['iconColor'].withOpacity(0.9),
              ),
              overlayColor: MaterialStateProperty.all(
                Colors.white.withOpacity(0.1),
              ),
            ),
            onPressed: () {
              // 主操作逻辑
              setState(() {
                _isActionTaken = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已确认: ${widget.messageData['title']}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              _getPrimaryActionText(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // 操作按钮 - 已执行操作后
  Widget _buildActionTakenButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ).copyWith(
        backgroundColor: MaterialStateProperty.all(
          Colors.green.shade500.withOpacity(0.8),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 20),
          const SizedBox(width: 8),
          const Text(
            '已确认',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            icon: Icons.delete_outline,
            title: '删除此消息',
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // 返回上一页
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('系统消息已删除')));
            },
          ),
          _buildOptionItem(
            icon: Icons.archive_outlined,
            title: '归档',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已归档')));
            },
          ),
          _buildOptionItem(
            icon: Icons.help_outline,
            title: '联系客服',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('正在连接客服...')));
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

  // 构建相关系统消息
  Widget _buildRelatedMessages() {
    // 这里可以从API获取相关系统消息，现在使用模拟数据
    final List<Map<String, dynamic>> relatedMessages = [
      {
        'title': '相关${widget.messageData['title'].split(' ')[0]}提醒',
        'content': '了解更多关于${widget.messageData['title'].split(' ')[0]}的内容',
        'time': '3天前',
        'icon': widget.messageData['icon'],
        'iconColor': widget.messageData['iconColor'],
      },
    ];

    return Column(
      children:
          relatedMessages.map((message) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    message['iconColor'].withOpacity(0.1),
                    AppTheme.cardColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: message['iconColor'].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('查看相关消息: ${message['title']}')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
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
                              Text(
                                message['title'],
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message['content'],
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.cardColor.withOpacity(0.3),
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
                ),
              ),
            );
          }).toList(),
    );
  }

  // 获取详细内容
  List<Widget> _getDetailedContent() {
    final widgets = <Widget>[];
    final title = widget.messageData['title'];

    if (title.contains('系统升级')) {
      widgets.addAll([
        const Text(
          '升级详情：',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailItem('升级时间', '今晚22:00-23:00'),
        _buildDetailItem('影响范围', '订单支付、行程预订、消息推送'),
        _buildDetailItem('预计恢复', '23:00左右'),
        _buildDetailItem('升级内容', '系统性能优化，新增虚拟导游功能'),
        const SizedBox(height: 16),
        const Text(
          '* 如有任何问题，请联系客服中心',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ]);
    } else if (title.contains('隐私政策')) {
      widgets.addAll([
        const Text(
          '主要更新内容：',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailItem('更新时间', '2024年5月15日'),
        _buildDetailItem('数据收集', '新增位置数据收集说明'),
        _buildDetailItem('第三方共享', '更新了共享数据的合作伙伴列表'),
        _buildDetailItem('数据安全', '增强了数据加密和保护措施'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.messageData['iconColor'],
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '请在继续使用我们的服务前阅读并同意新的隐私政策',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ]);
    } else if (title.contains('账号安全')) {
      widgets.addAll([
        const Text(
          '账号安全建议：',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildSecurityTip('定期更换密码，建议至少3个月一次'),
        _buildSecurityTip('使用包含字母、数字和特殊字符的复杂密码'),
        _buildSecurityTip('不要在多个平台使用相同的密码'),
        _buildSecurityTip('开启两步验证，提高账号安全性'),
        _buildSecurityTip('不要在不安全的网络环境下登录账号'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.buttonColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.buttonColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.security, color: AppTheme.buttonColor, size: 28),
              const SizedBox(height: 12),
              const Text(
                '立即前往安全中心修改密码',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ]);
    } else if (title.contains('新功能')) {
      widgets.addAll([
        const Text(
          '新功能介绍：',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 160,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.messageData['iconColor'].withOpacity(0.3),
                widget.messageData['iconColor'].withOpacity(0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo,
                color: widget.messageData['iconColor'],
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                '功能演示图片',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        _buildFeatureItem('景点实时人流量', '帮助您合理安排旅游行程，避开人流高峰', Icons.groups),
        _buildFeatureItem('最佳游览时间推荐', '根据历史数据和天气预测推荐最佳游览时间', Icons.access_time),
        _buildFeatureItem('智能排队预测', '预测热门景点的排队等待时间', Icons.av_timer),
      ]);
    } else {
      widgets.add(
        Text(
          '详细内容：\n\n${widget.messageData['content']}\n\n感谢您的关注，如有疑问请联系客服。',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      );
    }

    return widgets;
  }

  // 构建详情项
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建安全提示项
  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: widget.messageData['iconColor'],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // 构建功能项
  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.messageData['iconColor'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.messageData['iconColor'].withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: widget.messageData['iconColor'], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 获取状态徽章
  Widget? _getStatusBadge() {
    final title = widget.messageData['title'];

    if (title.contains('系统升级')) {
      return _buildStatusBadge(
        '计划中',
        AppTheme.neonBlue,
        Icons.pending_outlined,
      );
    } else if (title.contains('隐私政策')) {
      return _buildStatusBadge(
        '需要确认',
        AppTheme.buttonColor,
        Icons.privacy_tip_outlined,
      );
    } else if (title.contains('新功能')) {
      return _buildStatusBadge('已上线', Colors.green, Icons.check_circle_outline);
    }

    return null;
  }

  // 构建状态徽章
  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // 获取主操作按钮文本
  String _getPrimaryActionText() {
    final title = widget.messageData['title'];

    if (title.contains('系统升级')) {
      return '知道了';
    } else if (title.contains('隐私政策')) {
      return '查看并同意';
    } else if (title.contains('账号安全')) {
      return '前往修改';
    } else if (title.contains('新功能')) {
      return '立即体验';
    }

    return '确认';
  }
}
