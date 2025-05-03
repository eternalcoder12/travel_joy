import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/circle_button.dart';
import 'dart:math' as math;

class ChecklistItem {
  final String id;
  final String name;
  final String category;
  final bool isEssential;
  final String description;
  bool isChecked;

  ChecklistItem({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.isEssential = false,
    this.isChecked = false,
  });
}

class ChecklistCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  ChecklistCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({Key? key}) : super(key: key);

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  // 当前选中的分类
  String _selectedCategory = '全部';

  // 分类数据
  final List<ChecklistCategory> _categories = [
    ChecklistCategory(
      id: 'all',
      name: '全部',
      icon: Icons.apps,
      color: AppTheme.neonBlue,
    ),
    ChecklistCategory(
      id: 'clothing',
      name: '衣物',
      icon: Icons.checkroom,
      color: AppTheme.neonPink,
    ),
    ChecklistCategory(
      id: 'toiletries',
      name: '洗漱用品',
      icon: Icons.wash,
      color: AppTheme.neonGreen,
    ),
    ChecklistCategory(
      id: 'electronics',
      name: '电子设备',
      icon: Icons.power,
      color: AppTheme.neonPurple,
    ),
    ChecklistCategory(
      id: 'documents',
      name: '证件文件',
      icon: Icons.description,
      color: AppTheme.neonYellow,
    ),
    ChecklistCategory(
      id: 'medicine',
      name: '药品',
      icon: Icons.medical_services,
      color: AppTheme.neonRed,
    ),
    ChecklistCategory(
      id: 'others',
      name: '其他',
      icon: Icons.more_horiz,
      color: AppTheme.neonTeal,
    ),
  ];

  // 行李清单数据
  List<ChecklistItem> _checklistItems = [];
  List<ChecklistItem> _filteredItems = [];

  // 文本控制器
  final TextEditingController _newItemController = TextEditingController();
  final TextEditingController _newItemDescController = TextEditingController();

  // 新添加的项目分类
  String _newItemCategory = 'clothing';
  bool _newItemIsEssential = false;

  // 进度数据
  int _totalItems = 0;
  int _checkedItems = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 背景动画控制器
    _backgroundAnimController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _backgroundAnimation = CurvedAnimation(
      parent: _backgroundAnimController,
      curve: Curves.easeInOut,
    );

    // 启动背景动画循环
    _backgroundAnimController.repeat(reverse: true);

    // 启动入场动画
    _animationController.forward();

    // 加载示例行李清单数据
    _loadChecklistItems();
  }

  void _loadChecklistItems() {
    _checklistItems = [
      ChecklistItem(
        id: '1',
        name: 'T恤',
        category: 'clothing',
        description: '舒适透气的短袖T恤',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '2',
        name: '裤子',
        category: 'clothing',
        description: '适合旅行的休闲裤',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '3',
        name: '袜子',
        category: 'clothing',
        description: '每天至少一双干净袜子',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '4',
        name: '内衣',
        category: 'clothing',
        description: '每天至少一套干净内衣',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '5',
        name: '外套',
        category: 'clothing',
        description: '根据目的地气候选择合适的外套',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '6',
        name: '牙刷',
        category: 'toiletries',
        description: '保持口腔卫生必备',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '7',
        name: '牙膏',
        category: 'toiletries',
        description: '旅行装牙膏',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '8',
        name: '洗发水',
        category: 'toiletries',
        description: '旅行装洗发水或干洗喷雾',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '9',
        name: '护肤品',
        category: 'toiletries',
        description: '基础护肤品套装',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '10',
        name: '手机充电器',
        category: 'electronics',
        description: '与手机匹配的充电器和数据线',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '11',
        name: '相机',
        category: 'electronics',
        description: '记录美好时刻',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '12',
        name: '身份证',
        category: 'documents',
        description: '重要身份证明文件',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '13',
        name: '护照',
        category: 'documents',
        description: '国际旅行必备证件',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '14',
        name: '银行卡',
        category: 'documents',
        description: '支付手段，建议带备用卡',
        isEssential: true,
        isChecked: false,
      ),
      ChecklistItem(
        id: '15',
        name: '感冒药',
        category: 'medicine',
        description: '常用药物以防不适',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '16',
        name: '创可贴',
        category: 'medicine',
        description: '处理小伤口',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '17',
        name: '太阳镜',
        category: 'others',
        description: '保护眼睛，增添造型',
        isEssential: false,
        isChecked: false,
      ),
      ChecklistItem(
        id: '18',
        name: '防晒霜',
        category: 'others',
        description: '防止紫外线伤害',
        isEssential: true,
        isChecked: false,
      ),
    ];

    _updateFilteredItems();
    _updateProgress();
  }

  void _updateFilteredItems() {
    if (_selectedCategory == '全部') {
      _filteredItems = List.from(_checklistItems);
    } else {
      String categoryId =
          _categories
              .firstWhere((category) => category.name == _selectedCategory)
              .id;
      _filteredItems =
          _checklistItems.where((item) => item.category == categoryId).toList();
    }
  }

  void _updateProgress() {
    _totalItems = _checklistItems.length;
    _checkedItems = _checklistItems.where((item) => item.isChecked).length;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundAnimController.dispose();
    _newItemController.dispose();
    _newItemDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.buttonColor,
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          // 背景动画
          _buildAnimatedBackground(),

          // 主内容
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildCategorySelector(),
                _buildProgressBar(),
                Expanded(child: _buildChecklistItems()),
              ],
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
                  (0.3 + 0.2 * math.sin(_backgroundAnimation.value * math.pi)),
              top:
                  MediaQuery.of(context).size.height *
                  (0.2 + 0.1 * math.cos(_backgroundAnimation.value * math.pi)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonTeal.withOpacity(0.2),
                      AppTheme.neonTeal.withOpacity(0.1),
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
                      0.1 * math.sin(_backgroundAnimation.value * math.pi + 1)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.neonGreen.withOpacity(0.2),
                      AppTheme.neonGreen.withOpacity(0.1),
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
            size: 36,
            iconSize: 18,
          ),

          // 标题
          const Text(
            '行李清单',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),

          // 清除已完成项按钮
          CircleButton(
            icon: Icons.cleaning_services_outlined,
            onPressed: _clearCompletedItems,
            size: 36,
            iconSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.name == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category.name;
                _updateFilteredItems();
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? category.color.withOpacity(0.2)
                        : AppTheme.cardColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color:
                      isSelected
                          ? category.color
                          : AppTheme.cardColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    color:
                        isSelected ? category.color : AppTheme.primaryTextColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: TextStyle(
                      color:
                          isSelected
                              ? category.color
                              : AppTheme.primaryTextColor,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = _totalItems > 0 ? _checkedItems / _totalItems : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '进度: $_checkedItems / $_totalItems 项',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 14,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              // 底部进度条
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.cardColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // 当前进度
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 6,
                width: MediaQuery.of(context).size.width * progress - 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonGreen, AppTheme.neonTeal],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItems() {
    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.primaryTextColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedCategory == '全部' ? '行李清单为空' : '该分类下没有物品',
              style: TextStyle(color: AppTheme.primaryTextColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '点击"+"按钮添加物品',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final category = _categories.firstWhere(
          (cat) => cat.id == item.category,
          orElse: () => _categories.first,
        );

        return Dismissible(
          key: Key(item.id),
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: AppTheme.neonRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(Icons.delete_outline, color: AppTheme.neonRed),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: AppTheme.neonRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Icon(Icons.delete_outline, color: AppTheme.neonRed),
          ),
          onDismissed: (direction) {
            _deleteItem(item.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: category.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: category.color, size: 20),
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                  decorationColor: AppTheme.primaryTextColor,
                  decorationThickness: 2,
                  fontWeight:
                      item.isEssential ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.description.isNotEmpty)
                    Text(
                      item.description,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  Text(
                    item.isEssential ? '必备物品' : category.name,
                    style: TextStyle(
                      color:
                          item.isEssential
                              ? AppTheme.neonYellow
                              : AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Checkbox(
                value: item.isChecked,
                onChanged: (value) {
                  setState(() {
                    item.isChecked = value ?? false;
                    _updateProgress();
                  });
                },
                activeColor: category.color,
                checkColor: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏带图标
                    Row(
                      children: [
                        Icon(
                          Icons.luggage_outlined,
                          color: AppTheme.neonGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          '添加行李物品',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 物品名称输入框
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _newItemController,
                        decoration: const InputDecoration(
                          hintText: '物品名称',
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 物品描述
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _newItemDescController,
                        decoration: const InputDecoration(
                          hintText: '物品描述',
                          hintStyle: TextStyle(
                            color: AppTheme.secondaryTextColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                        ),
                        style: const TextStyle(
                          color: AppTheme.primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 物品分类
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 8, bottom: 4),
                            child: Text(
                              '物品分类',
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length - 1, // 排除"全部"选项
                              itemBuilder: (context, index) {
                                final category =
                                    _categories[index + 1]; // 跳过"全部"
                                final isSelected =
                                    category.id == _newItemCategory;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _newItemCategory = category.id;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      right: 10,
                                      bottom: 8,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? category.color.withOpacity(0.2)
                                              : AppTheme.backgroundColor
                                                  .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? category.color
                                                : Colors.transparent,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          category.icon,
                                          color:
                                              isSelected
                                                  ? category.color
                                                  : AppTheme.primaryTextColor,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            color:
                                                isSelected
                                                    ? category.color
                                                    : AppTheme.primaryTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 推荐选项
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _newItemIsEssential,
                            onChanged: (value) {
                              setState(() {
                                _newItemIsEssential = value ?? false;
                              });
                            },
                            activeColor: AppTheme.neonBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '我向其他用户推荐这个物品',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 奖励提示
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.neonYellow.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.neonYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '提供真实有效的行李物品信息将获得5积分奖励!',
                              style: TextStyle(
                                color: AppTheme.neonYellow,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 提交按钮
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _addNewItem();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.neonGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '提交行李物品',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addNewItem() {
    final name = _newItemController.text.trim();
    if (name.isEmpty) return;

    final desc = _newItemDescController.text.trim();

    final newItem = ChecklistItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _newItemCategory,
      description: desc,
      isEssential: _newItemIsEssential,
      isChecked: false,
    );

    setState(() {
      _checklistItems.add(newItem);
      _updateFilteredItems();
      _updateProgress();
      _newItemController.clear();
      _newItemDescController.clear();
      _newItemIsEssential = false;
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item.id == id);
      _updateFilteredItems();
      _updateProgress();
    });
  }

  void _clearCompletedItems() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            '清除已完成项目',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            '确定要清除所有已勾选的物品吗？此操作无法撤销。',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '取消',
                style: TextStyle(color: AppTheme.primaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _checklistItems.removeWhere((item) => item.isChecked);
                  _updateFilteredItems();
                  _updateProgress();
                });
                Navigator.pop(context);
              },
              child: Text('确定', style: TextStyle(color: AppTheme.neonRed)),
            ),
          ],
        );
      },
    );
  }
}
