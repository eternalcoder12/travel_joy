import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app_theme.dart';

class NotificationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const NotificationDetailScreen({Key? key, required this.notificationData})
    : super(key: key);

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen>
    with TickerProviderStateMixin {
  // 动画控制器
  late AnimationController _fadeInController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
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

    // 如果通知未读，标记为已读
    if (widget.notificationData['isRead'] == false) {
      // 实际应用中，这里应该调用API更新通知状态
      widget.notificationData['isRead'] = true;
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _backgroundAnimController.dispose();
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
                    // 动态光晕效果 - 使用通知图标颜色
                    Positioned(
                      left:
                          MediaQuery.of(context).size.width *
                          (0.3 +
                              0.2 *
                                  math.sin(
                                    _backgroundAnimation.value * math.pi,
                                  )),
                      top:
                          MediaQuery.of(context).size.height *
                          (0.2 +
                              0.1 *
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
                              widget.notificationData['iconColor'].withOpacity(
                                0.3,
                              ),
                              widget.notificationData['iconColor'].withOpacity(
                                0.1,
                              ),
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
                    child: _buildNotificationContent(),
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
              '通知详情',
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

  // 构建通知内容
  Widget _buildNotificationContent() {
    final Color iconColor = widget.notificationData['iconColor'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 通知图标和标题
          Row(
            children: [
              // 图标容器
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withOpacity(0.8),
                      iconColor.withOpacity(0.6),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.notificationData['icon'],
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // 标题和时间
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.notificationData['title'],
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.notificationData['time'],
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

          const SizedBox(height: 32),

          // 通知内容
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
                Text(
                  widget.notificationData['content'],
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                // 模拟扩展内容（在实际应用中，这部分内容可能需要从API获取）
                if (_isExpanded) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    _getExpandedContent(),
                    style: TextStyle(
                      color: AppTheme.primaryTextColor.withOpacity(0.9),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  // 相关图片（如果有的话）
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          iconColor.withOpacity(0.2),
                          AppTheme.cardColor.withOpacity(0.3),
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getRelatedIcon(),
                          size: 50,
                          color: iconColor.withOpacity(0.7),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '相关图片',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 展开/收起按钮
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? '收起详情' : '查看更多详情',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
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
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 相关通知
          Text(
            '相关通知',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 相关通知列表
          _buildRelatedNotifications(),
        ],
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
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
                  widget.notificationData['iconColor'].withOpacity(0.8),
                ),
                overlayColor: MaterialStateProperty.all(
                  Colors.white.withOpacity(0.1),
                ),
              ),
              onPressed: () {
                // 处理主操作按钮点击
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('执行操作: ${widget.notificationData['title']}'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.cardColor.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              child: const Text(
                '查看详情',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
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
            icon: Icons.notifications_off_outlined,
            title: '关闭此类通知',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已关闭此类通知')));
            },
          ),
          _buildOptionItem(
            icon: Icons.delete_outline,
            title: '删除此通知',
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // 返回上一页
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('通知已删除')));
            },
          ),
          _buildOptionItem(
            icon: Icons.share_outlined,
            title: '分享',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('分享功能')));
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

  // 构建相关通知列表
  Widget _buildRelatedNotifications() {
    // 这里可以从API获取相关通知，现在是模拟数据
    final relatedItems = [
      {
        'title': '相关${widget.notificationData['title']}',
        'content': '查看与此通知相关的其他内容',
        'time': '3天前',
        'icon': widget.notificationData['icon'],
        'iconColor': widget.notificationData['iconColor'],
      },
    ];

    return Column(
      children:
          relatedItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item['iconColor'].withOpacity(0.1),
                    AppTheme.cardColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item['iconColor'].withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('查看相关通知: ${item['title']}')),
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
                            color: item['iconColor'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['iconColor'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: TextStyle(
                                  color: AppTheme.primaryTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['content'],
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
                            item['time'],
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

  // 获取模拟扩展内容
  String _getExpandedContent() {
    final title = widget.notificationData['title'];
    if (title.contains('门票')) {
      return '您预订的西湖景区门票\n\n预订编号: TK202406150035\n游览日期: 2024年6月15日\n门票类型: 成人票\n数量: 2张\n总价: ¥120\n\n门票已经确认，您可以在游览日携带本人身份证前往景区售票处换取纸质门票或直接验证入园。';
    } else if (title.contains('行程')) {
      return '行程提醒:\n\n您明天计划前往故宫博物院参观，以下是相关信息：\n\n参观日期：2024年5月18日\n开放时间：8:30-17:00 (16:00停止入场)\n地址：北京市东城区景山前街4号\n交通方式：地铁1号线天安门东站下车步行约10分钟\n\n温馨提示：\n- 请务必携带身份证\n- 故宫需提前预约，请确认已完成预约\n- 建议携带充足的水和防晒用品';
    } else if (title.contains('优惠')) {
      return '端午节期间优惠活动详情：\n\n活动时间：2024年6月8日-6月10日\n参与景点：西湖、千岛湖、雁荡山、天目山等热门景区\n优惠力度：门票8折优惠\n使用方式：在景区售票处出示本通知或会员码即可\n\n* 部分景区可能有额外限制条件，详情请咨询各景区官方客服';
    } else if (title.contains('天气')) {
      return '天气预报：\n\n您计划前往的目的地明天天气情况：\n城市：杭州\n天气：中雨转小雨\n温度：18°C-24°C\n风力：东北风3-4级\n降水概率：80%\n\n出行建议：\n- 携带雨伞或雨衣\n- 穿着防滑鞋履\n- 携带备用衣物\n- 注意保暖，避免受凉';
    } else {
      return '通知详情：\n\n${widget.notificationData['content']}\n\n感谢您使用我们的应用，希望您有愉快的旅行体验！';
    }
  }

  // 获取相关图标
  IconData _getRelatedIcon() {
    final title = widget.notificationData['title'];
    if (title.contains('门票')) {
      return Icons.qr_code;
    } else if (title.contains('行程')) {
      return Icons.map;
    } else if (title.contains('优惠')) {
      return Icons.card_giftcard;
    } else if (title.contains('天气')) {
      return Icons.wb_cloudy;
    } else {
      return Icons.image;
    }
  }
}
