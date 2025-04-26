import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/exchange_record.dart';
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';
import 'dart:math' as math;

class ExchangeHistoryScreen extends StatefulWidget {
  const ExchangeHistoryScreen({Key? key}) : super(key: key);

  @override
  _ExchangeHistoryScreenState createState() => _ExchangeHistoryScreenState();
}

class _ExchangeHistoryScreenState extends State<ExchangeHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _itemAnimationController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  List<ExchangeRecord> exchangeRecords = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _itemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // 初始化背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 初始化背景动画
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动背景动画循环
    _backgroundAnimController.repeat(reverse: true);

    // 设置滚动监听器，用于加载更多
    _scrollController.addListener(_scrollListener);

    // 加载数据
    _loadExchangeRecords();

    // 启动动画
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _itemAnimationController.forward();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      _loadMoreRecords();
    }
  }

  void _loadExchangeRecords() {
    // 模拟加载数据
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          exchangeRecords = _getMockExchangeRecords();
          isLoading = false;
        });
      }
    });
  }

  void _loadMoreRecords() {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    // 模拟加载更多数据
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          if (currentPage < 3) {
            // 模拟只有3页数据
            exchangeRecords.addAll(_getMockMoreExchangeRecords());
            currentPage++;
          } else {
            hasMoreData = false;
          }
          isLoadingMore = false;
        });
      }
    });
  }

  List<ExchangeRecord> _getMockExchangeRecords() {
    // 模拟的兑换记录数据 - 第一页数据
    return [
      ExchangeRecord(
        id: '1001',
        itemName: '京东E卡100元',
        itemImagePath: 'assets/images/exchange/jd.png',
        pointsSpent: 3000,
        exchangeDate: DateTime.now().subtract(const Duration(hours: 6)),
        exchangeCode: 'JD90123OP4',
        status: ExchangeStatus.pending,
      ),
      ExchangeRecord(
        id: '1002',
        itemName: '星巴克电子券',
        itemImagePath: 'assets/images/exchange/starbucks.png',
        pointsSpent: 2000,
        exchangeDate: DateTime.now().subtract(const Duration(days: 2)),
        exchangeCode: 'SB78932XL9',
        status: ExchangeStatus.success,
      ),
      ExchangeRecord(
        id: '1003',
        itemName: '美团外卖红包',
        itemImagePath: 'assets/images/exchange/food.png',
        pointsSpent: 800,
        exchangeDate: DateTime.now().subtract(const Duration(days: 5)),
        exchangeCode: 'MT12345QR7',
        status: ExchangeStatus.used,
      ),
      ExchangeRecord(
        id: '1004',
        itemName: '网易云音乐会员月卡',
        itemImagePath: 'assets/images/exchange/music.png',
        pointsSpent: 1500,
        exchangeDate: DateTime.now().subtract(const Duration(days: 7)),
        exchangeCode: 'NM65432TY8',
        status: ExchangeStatus.used,
      ),
      ExchangeRecord(
        id: '1005',
        itemName: '滴滴出行优惠券',
        itemImagePath: 'assets/images/exchange/taxi.png',
        pointsSpent: 1000,
        exchangeDate: DateTime.now().subtract(const Duration(days: 15)),
        exchangeCode: 'DD45678UI0',
        status: ExchangeStatus.expired,
      ),
    ];
  }

  List<ExchangeRecord> _getMockMoreExchangeRecords() {
    // 模拟的更多兑换记录数据
    int offset = exchangeRecords.length;
    return List.generate(5, (index) {
      final int days = 20 + index * 5;
      return ExchangeRecord(
        id: '10${offset + index + 1}',
        itemName: '商品${offset + index + 1}',
        itemImagePath: 'assets/images/exchange/jd.png',
        pointsSpent: 1000 + (index * 500),
        exchangeDate: DateTime.now().subtract(Duration(days: days)),
        exchangeCode: 'CODE${10000 + offset + index}',
        status:
            index % 4 == 0
                ? ExchangeStatus.success
                : index % 4 == 1
                ? ExchangeStatus.pending
                : index % 4 == 2
                ? ExchangeStatus.used
                : ExchangeStatus.expired,
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _itemAnimationController.dispose();
    _backgroundAnimController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // 背景
          _buildAnimatedBackground(),

          // 内容
          SafeArea(
            child: FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.3, 0),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: Column(
                  children: [
                    // 顶部导航栏
                    _buildAppBar(),

                    // 记录列表
                    Expanded(child: _buildRecordsList()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 基础背景
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.backgroundColor, const Color(0xFF2A2A45)],
                ),
              ),
            ),

            // 动态光晕效果1
            Positioned(
              left:
                  MediaQuery.of(context).size.width *
                  (0.3 + 0.3 * math.sin(_backgroundAnimation.value * math.pi)),
              top:
                  MediaQuery.of(context).size.height *
                  (0.3 + 0.2 * math.cos(_backgroundAnimation.value * math.pi)),
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
                      0.2 * math.cos(_backgroundAnimation.value * math.pi + 1)),
              bottom:
                  MediaQuery.of(context).size.height *
                  (0.2 +
                      0.2 * math.sin(_backgroundAnimation.value * math.pi + 1)),
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
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => Navigator.pop(context),
          ),

          // 标题
          const Text(
            '兑换记录',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1,
            ),
          ),

          // 占位，使标题居中
          SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonColor),
        ),
      );
    }

    if (exchangeRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无兑换记录',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const BouncingScrollPhysics(),
      itemCount:
          exchangeRecords.length + (isLoadingMore || hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        // 加载更多指示器
        if (index == exchangeRecords.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child:
                  isLoadingMore
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.buttonColor,
                          ),
                        ),
                      )
                      : Text(
                        hasMoreData ? '上拉加载更多' : '没有更多记录了',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
            ),
          );
        }

        final record = exchangeRecords[index];
        return AnimatedItemSlideInFromRight(
          animationController: _itemAnimationController,
          animationStart: 0.1 + (index * 0.05),
          animationEnd: math.min(0.5 + (index * 0.05), 1.0),
          child: _buildHistoryItem(record),
        );
      },
    );
  }

  Widget _buildHistoryItem(ExchangeRecord record) {
    Color statusColor;
    String statusText;

    switch (record.status) {
      case ExchangeStatus.success:
        statusColor = Colors.green;
        statusText = '兑换成功';
        break;
      case ExchangeStatus.pending:
        statusColor = Colors.orange;
        statusText = '处理中';
        break;
      case ExchangeStatus.used:
        statusColor = Colors.blue;
        statusText = '已使用';
        break;
      case ExchangeStatus.expired:
        statusColor = Colors.grey;
        statusText = '已过期';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showExchangeDetail(record),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 商品图片
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(record.itemImagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 商品信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.itemName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: AppTheme.neonBlue,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${record.pointsSpent}积分',
                                style: TextStyle(
                                  color: AppTheme.neonBlue,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 状态标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // 分隔线
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 1,
                  ),
                ),

                // 兑换时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '兑换时间: ${DateFormat('yyyy-MM-dd HH:mm').format(record.exchangeDate)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.3),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExchangeDetail(ExchangeRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标题和关闭按钮
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '兑换详情',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTextColor,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.primaryTextColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 分隔线
              Divider(color: Colors.white.withOpacity(0.1)),

              // 主要内容
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 兑换状态
                      Row(
                        children: [
                          _buildStatusTag(record.status),
                          const SizedBox(width: 10),
                          Text(
                            record.exchangeDate is DateTime
                                ? DateFormat(
                                  'yyyy-MM-dd HH:mm',
                                ).format(record.exchangeDate)
                                : record.exchangeDate.toString(),
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 商品信息
                      const Text(
                        '商品信息',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('商品名称', record.itemName),
                      _buildInfoRow('兑换积分', '${record.pointsSpent} 积分'),
                      _buildInfoRow('订单编号', record.id),

                      const SizedBox(height: 24),

                      // 兑换信息
                      const Text(
                        '兑换信息',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '兑换码',
                                  style: TextStyle(
                                    color: AppTheme.secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: record.exchangeCode),
                                    );
                                    showToast('兑换码已复制');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.neonBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          color: AppTheme.neonBlue,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '复制',
                                          style: TextStyle(
                                            color: AppTheme.neonBlue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              record.exchangeCode,
                              style: const TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 使用说明
                      const Text(
                        '使用说明',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _buildInstructionItem('复制上方兑换码'),
                          _buildInstructionItem('进入应用内【我的】-【兑换中心】'),
                          _buildInstructionItem('粘贴兑换码并点击兑换即可'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 底部按钮
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: record.exchangeCode),
                          );
                          showToast('兑换码已复制');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardColor,
                          foregroundColor: AppTheme.neonBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppTheme.neonBlue.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: const Text(
                          '复制兑换码',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            record.status != 'expired'
                                ? () {
                                  Navigator.pop(context);
                                  // 实际使用逻辑
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          record.status != 'expired' ? '立即使用' : '已过期',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusTag(ExchangeStatus status) {
    Color color;
    String text;

    switch (status) {
      case ExchangeStatus.success:
        color = Colors.green;
        text = '兑换成功';
        break;
      case ExchangeStatus.pending:
        color = Colors.orange;
        text = '处理中';
        break;
      case ExchangeStatus.used:
        color = Colors.blue;
        text = '已使用';
        break;
      case ExchangeStatus.expired:
        color = Colors.grey;
        text = '已过期';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.neonGreen,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示提示消息
  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.buttonColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
