import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../../widgets/circle_button.dart';
import '../../widgets/app_tab_bar.dart';
import 'exchange_history_screen.dart';
import 'dart:math' as math;
import 'dart:ui';

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
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _contentAnimation;

  int userPoints = 8750; // 用户当前积分
  String selectedCategory = '全部'; // 当前选择的分类

  // 模拟兑换项目数据
  List<ExchangeItem> exchangeItems = [];

  // 缓存按分类过滤后的数据，减少重复计算
  Map<String, List<ExchangeItem>> _filteredItemsCache = {};

  @override
  void initState() {
    super.initState();

    // 初始化所有动画控制器
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _cardAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _itemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 先初始化背景动画控制器
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // 再初始化背景动画
    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    );

    // 然后启动背景动画循环
    _backgroundAnimationController.repeat(reverse: true);

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

    // 初始化缓存，预先计算所有分类
    _updateFilteredItemsCache();
  }

  // 更新所有分类的缓存
  void _updateFilteredItemsCache() {
    // 清空旧缓存
    _filteredItemsCache.clear();

    // 预先缓存"全部"分类
    _filteredItemsCache['全部'] = exchangeItems;

    // 对每个分类进行预缓存
    final categories = _getCategories();
    for (final category in categories) {
      if (category != '全部') {
        _filteredItemsCache[category] =
            exchangeItems.where((item) => item.category == category).toList();
      }
    }
  }

  // 获取所有分类
  List<String> _getCategories() {
    return ['全部', '美食', '娱乐', '出行', '购物', '住宿'];
  }

  // 根据选择的分类获取兑换项目，使用缓存
  List<ExchangeItem> _getFilteredItems() {
    // 优先从缓存获取
    if (_filteredItemsCache.containsKey(selectedCategory)) {
      return _filteredItemsCache[selectedCategory]!;
    }

    // 缓存不存在时再计算（一般不会走到这一步，因为已预缓存所有分类）
    List<ExchangeItem> filteredItems;
    if (selectedCategory == '全部') {
      filteredItems = exchangeItems;
    } else {
      filteredItems =
          exchangeItems
              .where((item) => item.category == selectedCategory)
              .toList();
    }

    // 更新缓存
    _filteredItemsCache[selectedCategory] = filteredItems;
    return filteredItems;
  }

  // 切换分类，使用延迟渲染减轻UI负担
  void _changeCategory(String category) {
    if (category == selectedCategory) return;

    setState(() {
      selectedCategory = category;
    });

    // 重置项目动画，使项目有重新加载的效果
    _itemAnimationController.reset();
    Future.microtask(() {
      if (mounted) {
        _itemAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _itemAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = _getCategories();

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 背景效果
          _buildAnimatedBackground(),

          // 主界面内容
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

                    // 积分卡片 - 简化设计
                    _buildPointsCard(),

                    // 分类选项卡
                    _buildCategoryTabs(categories),

                    // 活动标签行 - 简化设计
                    _buildSimpleActivityTags(),

                    // 兑换项目列表
                    Expanded(child: _buildExchangeItemsList()),
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => Navigator.pop(context),
            size: 38,
            iconSize: 16,
          ),

          // 标题
          const Text(
            '积分兑换',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),

          // 历史记录按钮
          CircleButton(
            icon: Icons.history_rounded,
            onPressed: () {
              // 查看兑换历史
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExchangeHistoryScreen(),
                ),
              );
            },
            size: 38,
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return AnimatedItemSlideInFromTop(
      animationController: _cardAnimationController,
      animationStart: 0.0,
      animationEnd: 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 85,
        decoration: BoxDecoration(
          // 使用渐变背景，更符合旅行APP风格
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.neonPurple.withOpacity(0.4),
              AppTheme.neonBlue.withOpacity(0.4),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          // 添加玻璃态效果
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 添加背景装饰效果
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -15,
                bottom: -15,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // 内容
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧积分信息
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '我的积分',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            // 积分数值添加特效
                            Text(
                              '$userPoints',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                                height: 0.9,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.neonYellow,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '积分',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // 右侧获取积分按钮 - 调整样式更符合旅行APP
                    TextButton.icon(
                      onPressed: () {
                        // 获取更多积分的逻辑
                      },
                      icon: const Icon(
                        Icons.explore_outlined, // 改为旅行相关图标
                        size: 15,
                        color: Colors.white,
                      ),
                      label: const Text(
                        '获取更多',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        minimumSize: const Size(0, 30),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return AppTabBar(
      tabs: categories,
      selectedTab: selectedCategory,
      onTabSelected: _changeCategory,
      height: 42,
      horizontalPadding: 14,
    );
  }

  Widget _buildExchangeItemsList() {
    final filteredItems = _getFilteredItems();

    if (filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 50,
              color: AppTheme.secondaryTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              '暂无该分类兑换项目',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 简化列表视图
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.80,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        final animationDelay = 0.1 + (index * 0.05);
        final animationEnd = math.min(animationDelay + 0.3, 1.0);

        return AnimatedItemPop(
          animationController: _itemAnimationController,
          animationStart: animationDelay,
          animationEnd: animationEnd,
          child: _buildSimpleExchangeItemCard(item),
        );
      },
    );
  }

  Widget _buildSimpleExchangeItemCard(ExchangeItem item) {
    final bool canExchange = userPoints >= item.points;

    return InkWell(
      onTap: () => _showItemDetails(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          // 使用玻璃态效果，更现代化
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            Stack(
              children: [
                Container(
                  height: 105,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image: DecorationImage(
                      image: AssetImage(item.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // 添加渐变叠加层，增加视觉深度
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
                if (item.discount != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.neonOrange, AppTheme.neonPink],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.discount!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // 商品信息
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 添加简短描述填充空白区域
                    Text(
                      _getShortDescription(item.category),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // 添加评分和推荐标签
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.neonYellow, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          _getRandomRating(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        if (_shouldShowRecommended())
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '推荐',
                              style: TextStyle(
                                fontSize: 8,
                                color: AppTheme.neonGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 使用渐变色文本增加视觉吸引力
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors:
                                    canExchange
                                        ? [AppTheme.neonBlue, AppTheme.neonTeal]
                                        : [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600,
                                        ],
                              ).createShader(bounds),
                          child: Text(
                            '${item.points}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Text(
                          ' 积分',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                canExchange
                                    ? AppTheme.neonBlue
                                    : Colors.white.withOpacity(0.6),
                            height: 1.1,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                canExchange
                                    ? AppTheme.neonBlue.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            canExchange ? '兑换' : '不足',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  canExchange
                                      ? AppTheme.neonBlue
                                      : Colors.white.withOpacity(0.4),
                              fontWeight: FontWeight.w500,
                              height: 1.0,
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

  // 生成简短描述
  String _getShortDescription(String category) {
    switch (category) {
      case '美食':
        return '享受美食的乐趣，满足味蕾的旅行';
      case '娱乐':
        return '放松心情，娱乐休闲的绝佳选择';
      case '出行':
        return '便捷的出行体验，让旅途更轻松';
      case '购物':
        return '精选好礼，让旅行回忆持久留存';
      case '住宿':
        return '舒适入住，享受旅途中的休息时光';
      default:
        return '适合旅行中的各种场景，提升旅行体验';
    }
  }

  // 生成随机评分
  String _getRandomRating() {
    final ratings = ['4.8', '4.7', '4.9', '5.0', '4.6'];
    return ratings[DateTime.now().millisecond % ratings.length];
  }

  // 随机确定是否显示推荐标签
  bool _shouldShowRecommended() {
    return DateTime.now().millisecond % 3 == 0; // 约1/3的概率显示
  }

  Widget _buildExchangeButton(ExchangeItem item) {
    final bool canExchange = userPoints >= item.points;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: ElevatedButton(
        onPressed: canExchange ? () => _confirmExchange(item) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canExchange
                  ? AppTheme.buttonColor
                  : AppTheme.secondaryTextColor.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 5,
          shadowColor:
              canExchange
                  ? AppTheme.buttonColor.withOpacity(0.5)
                  : Colors.transparent,
        ),
        child: Text(
          canExchange ? '立即兑换' : '积分不足',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 商品信息头部
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    // 商品图标
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getCategoryColor(
                          item.category,
                        ).withOpacity(0.15),
                      ),
                      child: Icon(
                        _getCategoryIcon(item.category),
                        color: _getCategoryColor(item.category),
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 商品名称和状态
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              color: AppTheme.primaryTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      canExchange
                                          ? AppTheme.successColor.withOpacity(
                                            0.2,
                                          )
                                          : AppTheme.errorColor.withOpacity(
                                            0.2,
                                          ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  canExchange ? '可兑换' : '积分不足',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        canExchange
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                  ),
                                ),
                              ),
                              if (item.discount != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonOrange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.discount!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.neonOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 进度条
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '所需积分: ${item.points}',
                          style: const TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '您的积分: $userPoints',
                          style: const TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: canExchange ? 1.0 : userPoints / item.points,
                        backgroundColor: AppTheme.cardColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canExchange
                              ? AppTheme.successColor
                              : AppTheme.neonPurple,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    if (!canExchange)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '还差 ${item.points - userPoints} 积分',
                          style: TextStyle(
                            color: AppTheme.errorColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Divider(color: AppTheme.secondaryTextColor.withOpacity(0.1)),

              // 详细内容
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 商品详情卡片
                        _buildDetailInfoCard(
                          title: '商品详情',
                          icon: Icons.info_outline,
                          color: AppTheme.neonBlue,
                          content: item.description,
                        ),

                        const SizedBox(height: 16),

                        // 兑换须知卡片
                        _buildDetailInfoCard(
                          title: '兑换须知',
                          icon: Icons.assignment_outlined,
                          color: AppTheme.neonYellow,
                          content:
                              '• 兑换成功后，兑换码将发送到您的账户\n'
                              '• 兑换后积分将立即扣除，不支持退换\n'
                              '• 部分商品可能有使用期限，请及时使用\n'
                              '• 如有疑问，请联系客服',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 底部按钮
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
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
                    disabledBackgroundColor: AppTheme.secondaryTextColor
                        .withOpacity(0.3),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: AppTheme.neonYellow,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '确认兑换',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '您确定要使用${item.points}积分兑换"${item.name}"吗？',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.3,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 执行兑换逻辑
                          setState(() {
                            userPoints -= item.points;
                          });
                          _showExchangeSuccess();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: AppTheme.buttonColor.withOpacity(0.5),
                        ),
                        child: const Text(
                          '确认',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showExchangeSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 成功图标
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '兑换成功',
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '兑换码已发送至您的账户',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '可在"我的-兑换记录"中查看',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppTheme.secondaryTextColor.withOpacity(
                                0.3,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Text(
                          '知道了',
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 跳转到兑换记录页面
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const ExchangeHistoryScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: AppTheme.buttonColor.withOpacity(0.5),
                        ),
                        child: const Text(
                          '查看记录',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '美食':
        return AppTheme.neonOrange;
      case '娱乐':
        return AppTheme.neonPurple;
      case '出行':
        return AppTheme.neonBlue;
      case '购物':
        return AppTheme.neonPink;
      case '住宿':
        return AppTheme.neonTeal;
      default:
        return AppTheme.neonYellow;
    }
  }

  Widget _buildGiftIcon(String category) {
    IconData iconData;
    Color color;

    switch (category) {
      case '美食':
        iconData = Icons.restaurant_rounded;
        color = AppTheme.neonOrange;
        break;
      case '娱乐':
        iconData = Icons.movie_rounded;
        color = AppTheme.neonPurple;
        break;
      case '出行':
        iconData = Icons.directions_car_rounded;
        color = AppTheme.neonBlue;
        break;
      case '购物':
        iconData = Icons.shopping_bag_rounded;
        color = AppTheme.neonPink;
        break;
      case '住宿':
        iconData = Icons.hotel_rounded;
        color = AppTheme.neonTeal;
        break;
      default:
        iconData = Icons.card_giftcard_rounded;
        color = AppTheme.neonYellow;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
          ),
        ),
        Icon(iconData, size: 36, color: color),
      ],
    );
  }

  // 替换为简单的活动标签行
  Widget _buildSimpleActivityTags() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 1, 16, 6),
      height: 26,
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: AppTheme.neonPurple,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '热门活动:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildClickableTag('满300减100', AppTheme.neonBlue, () {
                    // 处理点击"满300减100"的逻辑 - 可筛选符合此条件的商品
                    _filterItemsByActivity('满300减100');
                  }),
                  const SizedBox(width: 10),
                  _buildClickableTag('满20减10', AppTheme.neonOrange, () {
                    // 处理点击"满20减10"的逻辑
                    _filterItemsByActivity('满20减10');
                  }),
                  const SizedBox(width: 10),
                  _buildClickableTag('积分翻倍', AppTheme.neonPurple, () {
                    // 处理点击"积分翻倍"的逻辑
                    _showActivityDetails('积分翻倍', '参与特定活动可获得双倍积分奖励，抓紧行动吧！');
                  }),
                  const SizedBox(width: 10),
                  _buildClickableTag('限时兑换', AppTheme.neonPink, () {
                    // 处理点击"限时兑换"的逻辑
                    _showActivityDetails('限时兑换', '部分商品限时特惠，先到先得，错过再等一年！');
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 可点击的标签
  Widget _buildClickableTag(String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.3), color.withOpacity(0.15)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  // 筛选商品逻辑
  void _filterItemsByActivity(String activityName) {
    // 在实际应用中，这里应该根据活动名称进行商品筛选
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在筛选: $activityName 活动商品'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.neonBlue,
      ),
    );
  }

  // 显示活动详情
  void _showActivityDetails(String title, String description) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.buttonColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('了解了'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // 新增详情卡片组件
  Widget _buildDetailInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '美食':
        return Icons.restaurant_rounded;
      case '娱乐':
        return Icons.movie_rounded;
      case '出行':
        return Icons.directions_car_rounded;
      case '购物':
        return Icons.shopping_bag_rounded;
      case '住宿':
        return Icons.hotel_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
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
