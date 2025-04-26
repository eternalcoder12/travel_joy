import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import 'exchange_history_screen.dart';
import 'dart:math' as math;

class PointsExchangeScreen extends StatefulWidget {
  const PointsExchangeScreen({Key? key}) : super(key: key);

  @override
  _PointsExchangeScreenState createState() => _PointsExchangeScreenState();
}

class _PointsExchangeScreenState extends State<PointsExchangeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late AnimationController _itemAnimationController;

  int userPoints = 8750; // 用户当前积分
  String selectedCategory = '全部'; // 当前选择的分类

  // 模拟兑换项目数据
  List<ExchangeItem> exchangeItems = [];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _itemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 模拟数据
    _loadExchangeItems();

    // 启动动画
    _animationController.forward();
    _cardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _itemAnimationController.forward();
    });
  }

  void _loadExchangeItems() {
    exchangeItems = [
      ExchangeItem(
        id: '1',
        name: '星巴克电子券',
        points: 2000,
        imagePath: 'assets/images/exchange/starbucks.png',
        category: '美食',
        discount: '8.5折',
        description: '可在全国任意星巴克门店使用，有效期3个月。',
      ),
      ExchangeItem(
        id: '2',
        name: '网易云音乐会员月卡',
        points: 1500,
        imagePath: 'assets/images/exchange/music.png',
        category: '娱乐',
        discount: null,
        description: '网易云音乐黑胶VIP会员1个月，享受无损音乐及下载特权。',
      ),
      ExchangeItem(
        id: '3',
        name: '滴滴出行优惠券',
        points: 1000,
        imagePath: 'assets/images/exchange/taxi.png',
        category: '出行',
        discount: '满30减15',
        description: '可用于滴滴快车、优享、舒适型等，有效期14天。',
      ),
      ExchangeItem(
        id: '4',
        name: '京东E卡100元',
        points: 3000,
        imagePath: 'assets/images/exchange/jd.png',
        category: '购物',
        discount: null,
        description: '可在京东平台使用，不可提现，有效期1年。',
      ),
      ExchangeItem(
        id: '5',
        name: '携程酒店优惠券',
        points: 2500,
        imagePath: 'assets/images/exchange/hotel.png',
        category: '住宿',
        discount: '满300减100',
        description: '适用于携程平台国内酒店预订，节假日可用，有效期30天。',
      ),
      ExchangeItem(
        id: '6',
        name: '美团外卖红包',
        points: 800,
        imagePath: 'assets/images/exchange/food.png',
        category: '美食',
        discount: '满20减10',
        description: '可用于美团外卖平台，有效期7天。',
      ),
      ExchangeItem(
        id: '7',
        name: '哔哩哔哩大会员月卡',
        points: 1800,
        imagePath: 'assets/images/exchange/bilibili.png',
        category: '娱乐',
        discount: null,
        description: '哔哩哔哩大会员1个月，享受1080P画质、专属活动等特权。',
      ),
      ExchangeItem(
        id: '8',
        name: '电影票优惠券',
        points: 1200,
        imagePath: 'assets/images/exchange/movie.png',
        category: '娱乐',
        discount: '满60减30',
        description: '适用于猫眼电影平台，不可用于IMAX、中国巨幕等特殊影厅，有效期30天。',
      ),
    ];
  }

  // 根据选择的分类过滤兑换项目
  List<ExchangeItem> _getFilteredItems() {
    if (selectedCategory == '全部') {
      return exchangeItems;
    } else {
      return exchangeItems
          .where((item) => item.category == selectedCategory)
          .toList();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _itemAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = ['全部', '美食', '娱乐', '出行', '购物', '住宿'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 积分卡片
          _buildPointsCard(),

          // 分类选项卡
          _buildCategoryTabs(categories),

          // 兑换项目列表
          Expanded(child: _buildExchangeItemsList()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(-20 * (1.0 - _animationController.value), 0),
            child: Opacity(
              opacity: _animationController.value,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppTheme.darkText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
      title: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _animationController.value,
            child: const Text(
              '积分兑换',
              style: TextStyle(
                color: AppTheme.darkText,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      centerTitle: true,
      actions: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(20 * (1.0 - _animationController.value), 0),
              child: Opacity(
                opacity: _animationController.value,
                child: IconButton(
                  icon: const Icon(Icons.history, color: AppTheme.darkText),
                  onPressed: () {
                    // 查看兑换历史
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExchangeHistoryScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPointsCard() {
    return AnimatedItemSlideInFromTop(
      animationController: _cardAnimationController,
      animationStart: 0.0,
      animationEnd: 1.0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.buttonColor, AppTheme.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 背景装饰
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTextColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10,
              top: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTextColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // 内容
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '我的积分',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTextColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryTextColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.primaryTextColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '获取更多积分',
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$userPoints',
                        style: const TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text(
                          '积分',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 16),
      child: AnimatedItemSlideInFromTop(
        animationController: _cardAnimationController,
        animationStart: 0.2,
        animationEnd: 1.0,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppTheme.buttonColor
                          : AppTheme.cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.buttonColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: AppTheme.cardColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
                  border:
                      isSelected
                          ? null
                          : Border.all(
                            color: AppTheme.secondaryTextColor.withOpacity(0.3),
                            width: 1,
                          ),
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color:
                        isSelected
                            ? AppTheme.primaryTextColor
                            : AppTheme.secondaryTextColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExchangeItemsList() {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          '暂无该分类兑换项目',
          style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 16),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final animationDelay = 0.2 + (index * 0.05);

        return AnimatedItemPop(
          animationController: _itemAnimationController,
          animationStart: animationDelay,
          animationEnd: math.min(animationDelay + 0.4, 1.0),
          child: _buildExchangeItemCard(item),
        );
      },
    );
  }

  Widget _buildExchangeItemCard(ExchangeItem item) {
    final bool canExchange = userPoints >= item.points;

    return GestureDetector(
      onTap: () {
        _showItemDetails(item);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.backgroundColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片区域
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.buttonColor.withOpacity(0.15),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.card_giftcard,
                        size: 60,
                        color: AppTheme.buttonColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  if (item.discount != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.neonOrange, AppTheme.neonPink],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonOrange.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          item.discount!,
                          style: const TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 信息区域
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.monetization_on,
                              color: AppTheme.neonYellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.points}',
                              style: TextStyle(
                                color:
                                    canExchange
                                        ? AppTheme.neonYellow
                                        : AppTheme.errorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                canExchange
                                    ? AppTheme.buttonColor
                                    : AppTheme.secondaryTextColor.withOpacity(
                                      0.3,
                                    ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow:
                                canExchange
                                    ? [
                                      BoxShadow(
                                        color: AppTheme.buttonColor.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Text(
                            '兑换',
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 12,
                              fontWeight:
                                  canExchange
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(ExchangeItem item) {
    final bool canExchange = userPoints >= item.points;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部关闭按钮
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, right: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.primaryTextColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // 商品图片
              Container(
                height: 180,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.buttonColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.card_giftcard,
                    size: 80,
                    color: AppTheme.buttonColor.withOpacity(0.5),
                  ),
                ),
              ),

              // 商品信息
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        if (item.discount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.neonOrange,
                                  AppTheme.neonPink,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.discount!,
                              style: const TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.neonYellow.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.monetization_on,
                            color: AppTheme.neonYellow,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${item.points}积分',
                          style: TextStyle(
                            color:
                                canExchange
                                    ? AppTheme.neonYellow
                                    : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 信息标签栏
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '商品详情',
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),
                          Divider(
                            color: AppTheme.secondaryTextColor.withOpacity(0.2),
                            height: 1,
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            '兑换须知',
                            style: TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            '1. 兑换成功后，兑换码将发送到您的账户\n'
                            '2. 兑换后积分将立即扣除，不支持退换\n'
                            '3. 如有疑问，请联系客服',
                            style: TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 底部兑换按钮
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      canExchange
                          ? () {
                            Navigator.pop(context);
                            _confirmExchange(item);
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.buttonColor,
                    foregroundColor: AppTheme.primaryTextColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppTheme.secondaryTextColor
                        .withOpacity(0.3),
                  ),
                  child: Text(
                    canExchange ? '立即兑换' : '积分不足',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmExchange(ExchangeItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '确认兑换',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '您确定要使用${item.points}积分兑换"${item.name}"吗？',
            style: const TextStyle(color: AppTheme.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '取消',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 执行兑换逻辑
                setState(() {
                  userPoints -= item.points;
                });
                _showExchangeSuccess();
              },
              child: const Text(
                '确认',
                style: TextStyle(color: AppTheme.buttonColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showExchangeSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              const SizedBox(width: 10),
              const Text(
                '兑换成功',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '兑换码已发送至您的账户',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
              SizedBox(height: 8),
              Text(
                '可在"我的-兑换记录"中查看',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '知道了',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 跳转到兑换记录页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExchangeHistoryScreen(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.buttonColor,
              ),
              child: const Text('查看记录'),
            ),
          ],
        );
      },
    );
  }
}

// 兑换项目数据模型
class ExchangeItem {
  final String id;
  final String name;
  final int points;
  final String imagePath;
  final String category;
  final String? discount; // 折扣信息，例如"8.5折"，"满300减100"
  final String description;

  ExchangeItem({
    required this.id,
    required this.name,
    required this.points,
    required this.imagePath,
    required this.category,
    this.discount,
    required this.description,
  });
}
