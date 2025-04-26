import 'package:flutter/material.dart';
import '../../app_theme.dart';
import '../../widgets/animated_item.dart';
import '../../utils/navigation_utils.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  // 模拟收藏数据
  final List<Map<String, dynamic>> _collections = [
    {
      'id': '1',
      'title': '西湖美景',
      'location': '杭州, 浙江',
      'imageUrl': 'assets/images/china_map_bg.png',
      'date': '2023-05-15',
      'description':
          '西湖，位于浙江省杭州市西湖区龙井路1号，杭州市区西部，景区总面积49平方千米，汇水面积为21.22平方千米，湖面面积为6.38平方千米。',
    },
    {
      'id': '2',
      'title': '故宫红墙',
      'location': '北京',
      'imageUrl': 'assets/images/china_map_bg.png',
      'date': '2023-04-20',
      'description': '故宫又名紫禁城，是中国乃至世界上保存最完整，规模最大的木质结构古建筑群，被誉为"世界五大宫之首"。',
    },
    {
      'id': '3',
      'title': '黄山云海',
      'location': '黄山, 安徽',
      'imageUrl': 'assets/images/china_map_bg.png',
      'date': '2023-06-02',
      'description': '黄山是安徽省黄山市的一座山，中国十大名山之一，世界文化与自然双重遗产，世界地质公园，国家AAAAA级旅游景区。',
    },
    {
      'id': '4',
      'title': '漓江山水',
      'location': '桂林, 广西',
      'imageUrl': 'assets/images/china_map_bg.png',
      'date': '2023-03-12',
      'description':
          '漓江，是广西壮族自治区东北部的一条河流，源于兴安县猫儿山，流经灵川、阳朔，全长164公里，河水清澈见底，水中倒影奇妙。',
    },
    {
      'id': '5',
      'title': '长城雄姿',
      'location': '北京',
      'imageUrl': 'assets/images/china_map_bg.png',
      'date': '2023-07-08',
      'description':
          '长城（The Great Wall），又称万里长城，是中国古代的军事防御工程，是一道高大、坚固而连绵不断的长垣，用以限隔敌骑的行动。',
    },
  ];

  // 收藏分类列表
  final List<String> _categories = ['全部', '景点', '美食', '住宿', '交通', '购物', '活动'];

  // 当前选中的分类
  String _selectedCategory = '全部';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '我的收藏',
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: AppTheme.primaryTextColor),
            onPressed: () {
              // 搜索功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('搜索功能开发中')));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppTheme.primaryTextColor,
            ),
            onPressed: () {
              // 筛选功能
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('筛选功能开发中')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类选择
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.accentColor
                              : AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppTheme.accentColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : AppTheme.secondaryTextColor,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 收藏列表
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                final item = _collections[index];
                return AnimatedItem(
                  delay: 100 * index,
                  type: AnimationType.fadeSlideUp,
                  child: _buildCollectionCard(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> collection) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片部分
            Stack(
              children: [
                Image.asset(
                  collection['imageUrl'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // 收藏按钮
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                  ),
                ),
                // 底部渐变遮罩
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // 位置信息
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        collection['location'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 收藏日期
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Text(
                    collection['date'],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            // 内容部分
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    collection['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 详情按钮
                      OutlinedButton(
                        onPressed: () {
                          // 查看详情
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('查看详情功能开发中')));
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.accentColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          '查看详情',
                          style: TextStyle(color: AppTheme.accentColor),
                        ),
                      ),
                      // 快捷操作按钮
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.share_rounded,
                              color: AppTheme.secondaryTextColor,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('分享功能开发中')),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: AppTheme.secondaryTextColor,
                            ),
                            onPressed: () {
                              _showDeleteConfirmation(collection);
                            },
                          ),
                        ],
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

  // 删除确认对话框
  void _showDeleteConfirmation(Map<String, dynamic> collection) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '确认删除',
              style: TextStyle(color: AppTheme.primaryTextColor),
            ),
            content: Text(
              '确定要删除"${collection['title']}"吗？此操作不可撤销。',
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
                  Navigator.pop(context);
                  setState(() {
                    _collections.removeWhere(
                      (item) => item['id'] == collection['id'],
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已删除 ${collection['title']}')),
                  );
                },
                child: Text('删除', style: TextStyle(color: AppTheme.errorColor)),
              ),
            ],
          ),
    );
  }
}
