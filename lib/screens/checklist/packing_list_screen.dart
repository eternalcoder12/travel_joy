import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';
import 'package:travel_joy/widgets/circle_button.dart';

class PackingItem {
  final String id;
  final String name;
  final String category;
  final IconData icon;
  bool isPacked;
  int priority; // 1-低 2-中 3-高
  bool isEasilyForgotten; // 新增：常被遗忘标记
  double weight; // 保留但弱化重量属性

  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.isPacked = false,
    this.priority = 2, // 默认中优先级
    this.isEasilyForgotten = false, // 默认非易忘物品
    this.weight = 0, // 默认重量为0
  });
}

class PackingListScreen extends StatefulWidget {
  const PackingListScreen({Key? key}) : super(key: key);

  @override
  _PackingListScreenState createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '必备物品';
  int _selectedPriority = 2;
  double _selectedWeight = 0;

  bool _showSearchBar = false;
  String _searchQuery = '';
  String _filterCategory = '全部';
  bool _showOnlyUnpacked = false;
  String _sortBy = '类别';

  // 预定义类别
  final List<String> _categories = [
    '必备物品',
    '衣物',
    '洗漱用品',
    '电子设备',
    '药品',
    '证件',
    '其他',
  ];

  // 每个类别对应图标
  final Map<String, IconData> _categoryIcons = {
    '必备物品': Icons.check_circle_outline,
    '衣物': Icons.checkroom,
    '洗漱用品': Icons.soap,
    '电子设备': Icons.devices,
    '药品': Icons.medication,
    '证件': Icons.badge,
    '其他': Icons.more_horiz,
  };

  // 旅行模板
  final Map<String, List<Map<String, dynamic>>> _templates = {
    '商务旅行': [
      {
        'name': '手提电脑',
        'category': '电子设备',
        'priority': 3,
        'isEasilyForgotten': false,
        'weight': 1500,
      },
      {
        'name': '充电器',
        'category': '电子设备',
        'priority': 3,
        'isEasilyForgotten': true,
        'weight': 200,
      },
      {
        'name': '名片',
        'category': '必备物品',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 50,
      },
      {
        'name': '移动电源',
        'category': '电子设备',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 300,
      },
      {
        'name': '转接头',
        'category': '电子设备',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 100,
      },
      {
        'name': '商务文件',
        'category': '必备物品',
        'priority': 3,
        'isEasilyForgotten': false,
        'weight': 300,
      },
      {
        'name': '护照/身份证',
        'category': '证件',
        'priority': 3,
        'isEasilyForgotten': false,
        'weight': 50,
      },
    ],
    '度假旅行': [
      {
        'name': '防晒霜',
        'category': '洗漱用品',
        'priority': 3,
        'isEasilyForgotten': true,
        'weight': 150,
      },
      {
        'name': '泳衣',
        'category': '衣物',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 200,
      },
      {
        'name': '太阳镜',
        'category': '必备物品',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 100,
      },
      {
        'name': '常用药品',
        'category': '药品',
        'priority': 3,
        'isEasilyForgotten': true,
        'weight': 200,
      },
      {
        'name': '创可贴',
        'category': '药品',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 50,
      },
      {
        'name': '充电线',
        'category': '电子设备',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 50,
      },
      {
        'name': '身份证',
        'category': '证件',
        'priority': 3,
        'isEasilyForgotten': false,
        'weight': 10,
      },
    ],
    '常被遗忘物品': [
      {
        'name': '牙线/牙签',
        'category': '洗漱用品',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 20,
      },
      {
        'name': '耳塞',
        'category': '必备物品',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 10,
      },
      {
        'name': '眼罩',
        'category': '必备物品',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 30,
      },
      {
        'name': '转换插头',
        'category': '电子设备',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 100,
      },
      {
        'name': '雨伞/雨衣',
        'category': '必备物品',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 300,
      },
      {
        'name': '备用眼镜',
        'category': '必备物品',
        'priority': 2,
        'isEasilyForgotten': true,
        'weight': 150,
      },
      {
        'name': '湿纸巾',
        'category': '洗漱用品',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 100,
      },
      {
        'name': '指甲刀',
        'category': '洗漱用品',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 30,
      },
      {
        'name': '备用内存卡',
        'category': '电子设备',
        'priority': 1,
        'isEasilyForgotten': true,
        'weight': 10,
      },
    ],
  };

  // 示例数据
  final List<PackingItem> _items = [
    PackingItem(
      id: '1',
      name: '护照',
      category: '证件',
      icon: Icons.badge,
      priority: 3,
      weight: 50,
    ),
    PackingItem(
      id: '2',
      name: '手机充电器',
      category: '电子设备',
      icon: Icons.battery_charging_full,
      priority: 3,
      isEasilyForgotten: true,
      weight: 150,
    ),
    PackingItem(
      id: '3',
      name: '牙刷',
      category: '洗漱用品',
      icon: Icons.brush,
      priority: 2,
      weight: 50,
    ),
    PackingItem(
      id: '4',
      name: 'T恤',
      category: '衣物',
      icon: Icons.checkroom,
      priority: 2,
      weight: 200,
    ),
    PackingItem(
      id: '5',
      name: '常用药品',
      category: '药品',
      icon: Icons.medication,
      priority: 2,
      isEasilyForgotten: true,
      weight: 100,
    ),
    PackingItem(
      id: '6',
      name: '转换插头',
      category: '电子设备',
      icon: Icons.power,
      priority: 2,
      isEasilyForgotten: true,
      weight: 100,
    ),
  ];

  // 应用模板
  void _applyTemplate(String templateName) {
    if (_templates.containsKey(templateName)) {
      final templateItems = _templates[templateName]!;

      // 检查已有物品，避免重复添加
      List<String> existingItemNames =
          _items.map((item) => item.name.toLowerCase()).toList();

      // 筛选出不重复的物品
      final newItems =
          templateItems
              .where(
                (item) =>
                    !existingItemNames.contains(
                      (item['name'] as String).toLowerCase(),
                    ),
              )
              .toList();

      setState(() {
        for (var item in newItems) {
          _items.add(
            PackingItem(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  item['name'],
              name: item['name'],
              category: item['category'],
              icon: _categoryIcons[item['category']] ?? Icons.more_horiz,
              priority: item['priority'],
              isEasilyForgotten: item['isEasilyForgotten'],
              weight: item['weight'].toDouble(),
            ),
          );
        }
      });

      // 显示添加成功的提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已应用"$templateName"模板，添加了${newItems.length}个物品'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 当添加了易忘记物品时，显示特别提示
      int forgottenItemsAdded =
          newItems.where((item) => item['isEasilyForgotten'] == true).length;
      if (forgottenItemsAdded > 0) {
        Future.delayed(Duration(seconds: 1), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('包含$forgottenItemsAdded件易被忘记的物品，请特别留意！'),
              backgroundColor: AppTheme.neonOrange,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
              action: SnackBarAction(
                label: '知道了',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        });
      }
    }
  }

  // 获取过滤后的物品列表
  List<PackingItem> get _filteredItems {
    return _items.where((item) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // 分类过滤
      if (_filterCategory != '全部' && item.category != _filterCategory) {
        return false;
      }

      // 打包状态过滤
      if (_showOnlyUnpacked && item.isPacked) {
        return false;
      }

      return true;
    }).toList();
  }

  // 获取排序后的物品列表
  List<PackingItem> get _sortedAndFilteredItems {
    final filtered = _filteredItems;

    switch (_sortBy) {
      case '优先级':
        filtered.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case '名称':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case '重量':
        filtered.sort((a, b) => b.weight.compareTo(a.weight));
        break;
      default: // 类别
        // 保持按类别分组
        break;
    }

    return filtered;
  }

  // 计算总重量
  double get _totalWeight {
    return _items.fold(0, (sum, item) => sum + item.weight);
  }

  // 计算已打包重量
  double get _packedWeight {
    return _items
        .where((item) => item.isPacked)
        .fold(0, (sum, item) => sum + item.weight);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _itemNameController.dispose();
    _searchController.dispose(); // 释放搜索控制器
    super.dispose();
  }

  void _addItem() {
    if (_itemNameController.text.trim().isNotEmpty) {
      setState(() {
        _items.add(
          PackingItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _itemNameController.text.trim(),
            category: _selectedCategory,
            icon: _categoryIcons[_selectedCategory] ?? Icons.more_horiz,
            priority: _selectedPriority,
            weight: _selectedWeight,
          ),
        );
        _itemNameController.clear();
      });

      // 显示添加成功的提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已添加到行李清单'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleItemStatus(int index) {
    setState(() {
      _items[index].isPacked = !_items[index].isPacked;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _showAddItemDialog() {
    _selectedPriority = 2; // 重置为中优先级
    _selectedWeight = 0; // 重置重量
    bool _isEasilyForgotten = false; // 初始化易忘记标志

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '添加行李物品',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: '物品名称',
                        hintText: '例如：护照、充电器、相机...',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '选择类别',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                              backgroundColor: AppTheme.cardColor,
                              selectedColor: AppTheme.buttonColor,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? AppTheme.primaryTextColor
                                        : AppTheme.secondaryTextColor,
                              ),
                              avatar: Icon(
                                _categoryIcons[category],
                                size: 18,
                                color:
                                    isSelected
                                        ? AppTheme.primaryTextColor
                                        : AppTheme.secondaryTextColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 15),
                    Text(
                      '重要程度',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPriorityOption(
                          1,
                          '低',
                          AppTheme.neonGreen,
                          setState,
                        ),
                        _buildPriorityOption(
                          2,
                          '中',
                          AppTheme.neonBlue,
                          setState,
                        ),
                        _buildPriorityOption(
                          3,
                          '高',
                          AppTheme.neonPink,
                          setState,
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // 添加"易忘记"标记选项
                    Row(
                      children: [
                        Switch(
                          value: _isEasilyForgotten,
                          onChanged: (value) {
                            setState(() {
                              _isEasilyForgotten = value;
                            });
                          },
                          activeColor: AppTheme.neonOrange,
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color:
                                  _isEasilyForgotten
                                      ? AppTheme.neonOrange
                                      : AppTheme.secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '容易被忘记的物品',
                              style: TextStyle(
                                color:
                                    _isEasilyForgotten
                                        ? AppTheme.neonOrange
                                        : AppTheme.primaryTextColor,
                                fontWeight:
                                    _isEasilyForgotten
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 将重量滑块放在折叠面板中，减少视觉强调
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '估计重量（可选）',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _selectedWeight,
                                min: 0,
                                max: 5000, // 5千克
                                divisions: 50,
                                activeColor: AppTheme.secondaryTextColor,
                                label:
                                    '${_selectedWeight.toStringAsFixed(0)} 克',
                                onChanged: (value) {
                                  setState(() {
                                    _selectedWeight = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${_selectedWeight.toStringAsFixed(0)} 克',
                              style: TextStyle(
                                color: AppTheme.secondaryTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // 修改添加物品方法，包含易忘记标记
                          if (_itemNameController.text.trim().isNotEmpty) {
                            setState(() {
                              _items.add(
                                PackingItem(
                                  id:
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  name: _itemNameController.text.trim(),
                                  category: _selectedCategory,
                                  icon:
                                      _categoryIcons[_selectedCategory] ??
                                      Icons.more_horiz,
                                  priority: _selectedPriority,
                                  isEasilyForgotten: _isEasilyForgotten,
                                  weight: _selectedWeight,
                                ),
                              );
                              _itemNameController.clear();
                            });

                            // 显示添加成功的提示
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已添加到行李清单'),
                                backgroundColor: AppTheme.successColor,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: AppTheme.buttonColor,
                        ),
                        child: Text(
                          '添加到行李清单',
                          style: TextStyle(
                            color: AppTheme.primaryTextColor,
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

  // 构建优先级选项
  Widget _buildPriorityOption(
    int priority,
    String label,
    Color color,
    StateSetter setState,
  ) {
    final isSelected = _selectedPriority == priority;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              priority == 1
                  ? Icons.low_priority
                  : priority == 2
                  ? Icons.push_pin_outlined
                  : Icons.priority_high,
              color: isSelected ? color : AppTheme.secondaryTextColor,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppTheme.secondaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [_buildAppBar(), Expanded(child: _buildPackingList())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.buttonColor,
        child: const Icon(Icons.add, color: Colors.white),
        mini: true,
        elevation: 4,
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
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
              Text(
                '行李清单',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1,
                ),
              ),

              // 更多选项按钮
              CircleButton(
                icon: Icons.more_vert,
                onPressed: _showMoreOptions,
                size: 38,
                iconSize: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 显示更多选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.secondaryTextColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '更多选项',
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppTheme.secondaryTextColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                  ],
                ),
              ),

              // 选项列表
              _buildOptionItem(
                icon: Icons.format_list_bulleted,
                title: '应用清单模板',
                iconColor: AppTheme.neonBlue,
                onTap: () {
                  Navigator.pop(context);
                  _showTemplatesDialog();
                },
              ),
              _buildOptionItem(
                icon: Icons.share,
                title: '分享行李清单',
                iconColor: AppTheme.neonPurple,
                onTap: () {
                  Navigator.pop(context);
                  _sharePackingList();
                },
              ),
              _buildOptionItem(
                icon: Icons.delete_outline,
                title: '清空行李清单',
                iconColor: AppTheme.errorColor,
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmationDialog();
                },
              ),

              SizedBox(
                height: MediaQuery.of(context).padding.bottom > 0 ? 16 : 8,
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建选项项目
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // 图标容器
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            SizedBox(width: 16),
            // 标题
            Text(
              title,
              style: TextStyle(
                color: AppTheme.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            // 箭头
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  // 显示模板对话框
  void _showTemplatesDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '选择模板',
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '根据旅行类型快速添加常用物品',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),

              // 模板列表
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final templateName = _templates.keys.elementAt(index);
                    final templateItems = _templates[templateName]!;

                    // 计算模板物品总数和易忘记物品数量
                    final itemCount = templateItems.length;
                    final forgottenCount =
                        templateItems
                            .where((item) => item['isEasilyForgotten'] == true)
                            .length;

                    return Card(
                      margin: EdgeInsets.only(bottom: 10),
                      color: AppTheme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          _applyTemplate(templateName);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    templateName == '商务旅行'
                                        ? Icons.business
                                        : templateName == '度假旅行'
                                        ? Icons.beach_access
                                        : Icons.notifications_active,
                                    color:
                                        templateName == '常被遗忘物品'
                                            ? AppTheme.neonOrange
                                            : AppTheme.buttonColor,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    templateName,
                                    style: TextStyle(
                                      color: AppTheme.primaryTextColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (templateName == '常被遗忘物品')
                                    Container(
                                      margin: EdgeInsets.only(left: 8),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonOrange.withOpacity(
                                          0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '推荐',
                                        style: TextStyle(
                                          color: AppTheme.neonOrange,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 14,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '$itemCount 件物品',
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 15),

                                  Icon(
                                    Icons.notifications_active,
                                    size: 14,
                                    color: AppTheme.secondaryTextColor,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '包含 $forgottenCount 件易忘记物品',
                                    style: TextStyle(
                                      color: AppTheme.secondaryTextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              // 为常被遗忘物品模板添加预览
                              if (templateName == '常被遗忘物品')
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundColor.withOpacity(
                                      0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '常见易忘物品包括：',
                                        style: TextStyle(
                                          color: AppTheme.secondaryTextColor,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (var item in templateItems.take(
                                            5,
                                          ))
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.neonOrange
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                item['name'] as String,
                                                style: TextStyle(
                                                  color:
                                                      AppTheme
                                                          .secondaryTextColor,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.neonOrange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '更多...',
                                              style: TextStyle(
                                                color:
                                                    AppTheme.secondaryTextColor,
                                                fontSize: 10,
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
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 清空确认对话框
  void _showClearConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            '清空行李清单',
            style: TextStyle(color: AppTheme.primaryTextColor),
          ),
          content: Text(
            '确定要清空所有行李物品吗？此操作无法撤销。',
            style: TextStyle(color: AppTheme.secondaryTextColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _items.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已清空行李清单'),
                    backgroundColor: AppTheme.buttonColor,
                  ),
                );
              },
              child: Text('确定', style: TextStyle(color: AppTheme.errorColor)),
            ),
          ],
        );
      },
    );
  }

  // 分享行李清单
  void _sharePackingList() {
    // 在实际应用中，这里可以使用分享插件实现分享功能
    // 例如：Share.share(_generatePackingListText());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享功能开发中，敬请期待！'),
        backgroundColor: AppTheme.secondaryTextColor,
      ),
    );
  }

  Widget _buildPackingList() {
    // 获取已过滤和排序的物品列表
    List<PackingItem> displayItems = _sortedAndFilteredItems;

    // 按类别对物品进行分组（仅当排序方式为"类别"时）
    Map<String, List<PackingItem>> groupedItems = {};

    if (_sortBy == '类别') {
      for (var item in displayItems) {
        if (!groupedItems.containsKey(item.category)) {
          groupedItems[item.category] = [];
        }
        groupedItems[item.category]!.add(item);
      }
    }

    // 获取已打包的物品数量和总数
    int packedCount = _items.where((item) => item.isPacked).length;
    int totalCount = _items.length;

    // 计算易忘记物品的数量
    int forgottenItemsCount =
        _items.where((item) => item.isEasilyForgotten).length;
    int unpackedForgottenItemsCount =
        _items.where((item) => item.isEasilyForgotten && !item.isPacked).length;

    // 计算总重量和已打包重量
    double totalWeight = _totalWeight;
    double packedWeight = _packedWeight;

    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 进度指示器和统计信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 打包进度
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '打包进度',
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$packedCount / $totalCount',
                        style: TextStyle(
                          color: AppTheme.buttonColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: totalCount > 0 ? packedCount / totalCount : 0,
                    backgroundColor: AppTheme.cardColor.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.buttonColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),

                  // 易忘记物品提醒
                  if (unpackedForgottenItemsCount > 0)
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.neonOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.neonOrange.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: AppTheme.neonOrange,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '注意：易被遗忘的物品',
                                  style: TextStyle(
                                    color: AppTheme.neonOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  '您有 $unpackedForgottenItemsCount 件容易忘记的物品尚未打包',
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

                  // 用ExpansionTile包装重量信息，减弱视觉重要性
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '重量信息',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                      childrenPadding: EdgeInsets.zero,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildWeightInfo(
                                '总重量',
                                '${(totalWeight / 1000).toStringAsFixed(2)} 千克',
                                AppTheme.secondaryTextColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildWeightInfo(
                                '已打包',
                                '${(packedWeight / 1000).toStringAsFixed(2)} 千克',
                                AppTheme.secondaryTextColor,
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

            // 计数和过滤器指示器
            if (_searchQuery.isNotEmpty ||
                _filterCategory != '全部' ||
                _showOnlyUnpacked)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '显示 ${displayItems.length} 个物品',
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    Spacer(),
                    if (_searchQuery.isNotEmpty ||
                        _filterCategory != '全部' ||
                        _showOnlyUnpacked)
                      TextButton.icon(
                        icon: Icon(Icons.filter_list_off, size: 16),
                        label: Text('清除筛选'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.buttonColor,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                            _filterCategory = '全部';
                            _showOnlyUnpacked = false;
                            _showSearchBar = false;
                          });
                        },
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // 物品列表
            Expanded(
              child:
                  displayItems.isEmpty
                      ? _buildEmptyState()
                      : _sortBy == '类别'
                      ? ListView.builder(
                        itemCount: groupedItems.length,
                        itemBuilder: (context, index) {
                          String category = groupedItems.keys.elementAt(index);
                          List<PackingItem> items = groupedItems[category]!;

                          // 计算类别中易忘记的物品数量
                          int categoryForgottenCount =
                              items
                                  .where(
                                    (item) =>
                                        item.isEasilyForgotten &&
                                        !item.isPacked,
                                  )
                                  .length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _categoryIcons[category] ??
                                          Icons.more_horiz,
                                      color: AppTheme.buttonColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: AppTheme.primaryTextColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${items.length})',
                                      style: TextStyle(
                                        color: AppTheme.secondaryTextColor,
                                        fontSize: 14,
                                      ),
                                    ),

                                    // 显示类别中易忘记物品的数量
                                    if (categoryForgottenCount > 0)
                                      Container(
                                        margin: EdgeInsets.only(left: 8),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.neonOrange
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.notifications_active,
                                              color: AppTheme.neonOrange,
                                              size: 12,
                                            ),
                                            SizedBox(width: 3),
                                            Text(
                                              '$categoryForgottenCount',
                                              style: TextStyle(
                                                color: AppTheme.neonOrange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: items.length,
                                itemBuilder: (context, itemIndex) {
                                  final item = items[itemIndex];
                                  final globalIndex = _items.indexOf(item);

                                  return _buildPackingItem(globalIndex);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      )
                      : ListView.builder(
                        itemCount: displayItems.length,
                        itemBuilder: (context, index) {
                          final globalIndex = _items.indexOf(
                            displayItems[index],
                          );
                          return _buildPackingItem(globalIndex);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建重量信息卡片
  Widget _buildWeightInfo(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.luggage,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '您的行李清单为空',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方的加号按钮添加物品',
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPackingItem(int index) {
    final item = _items[index];

    // 根据优先级决定颜色
    Color priorityColor;
    switch (item.priority) {
      case 1:
        priorityColor = AppTheme.neonGreen;
        break;
      case 3:
        priorityColor = AppTheme.neonPink;
        break;
      case 2:
      default:
        priorityColor = AppTheme.neonBlue;
    }

    return Dismissible(
      key: Key(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _deleteItem(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                item.priority == 3
                    ? priorityColor.withOpacity(0.3)
                    : Colors.transparent,
            width: item.priority == 3 ? 1.5 : 0,
          ),
        ),
        child: Stack(
          children: [
            // 优先级指示器
            if (item.priority > 1)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.priority == 3
                            ? Icons.priority_high
                            : Icons.push_pin_outlined,
                        color: priorityColor,
                        size: 12,
                      ),
                      SizedBox(width: 3),
                      Text(
                        item.priority == 3 ? '高' : '中',
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 主要内容
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      item.isPacked
                          ? AppTheme.successColor.withOpacity(0.2)
                          : item.isEasilyForgotten
                          ? AppTheme.neonOrange.withOpacity(0.15)
                          : AppTheme.secondaryTextColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color:
                      item.isPacked
                          ? AppTheme.successColor
                          : item.isEasilyForgotten
                          ? AppTheme.neonOrange
                          : AppTheme.secondaryTextColor,
                  size: 20,
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: AppTheme.primaryTextColor,
                                fontSize: 16,
                                decoration:
                                    item.isPacked
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            if (item.weight > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.buttonColor.withOpacity(
                                      0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppTheme.buttonColor.withOpacity(
                                        0.3,
                                      ),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    item.weight < 1000
                                        ? '${item.weight.toInt()}克'
                                        : '${(item.weight / 1000).toStringAsFixed(1)}千克',
                                    style: TextStyle(
                                      color: AppTheme.buttonColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // 易忘记标签改为一个小图标
                      if (item.isEasilyForgotten)
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Tooltip(
                            message: '易被忘记的物品',
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppTheme.neonOrange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active,
                                color: AppTheme.neonOrange,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    item.category,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Checkbox(
                value: item.isPacked,
                onChanged: (value) => _toggleItemStatus(index),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  return item.isPacked ? AppTheme.successColor : null;
                }),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              onTap: () => _toggleItemStatus(index),
            ),
          ],
        ),
      ),
    );
  }
}
