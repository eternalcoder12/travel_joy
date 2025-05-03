import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../app_theme.dart';
import '../../models/travel_note.dart';
import '../../widgets/glass_card.dart';
import 'travel_note_detail_screen.dart';

// 添加简单的MockDataGenerator代替缺失的工具类
class MockDataGenerator {
  static List<TravelNote> generateTravelNotes(int count) {
    List<TravelNote> notes = [];

    for (int i = 0; i < count; i++) {
      final id = 'note_${DateTime.now().millisecondsSinceEpoch}_$i';
      notes.add(
        TravelNote(
          id: id,
          title: '精彩旅行记录 #$i',
          summary: '这是一段关于旅行的精彩回忆和见闻分享，记录了沿途的风景和感受...',
          location: '杭州西湖',
          coverImage: 'https://picsum.photos/seed/$i/600/400',
          authorId: 'user_1',
          authorName: '旅行者',
          authorAvatar:
              'https://randomuser.me/api/portraits/men/${i % 100}.jpg',
          createdAt: DateTime.now().subtract(Duration(days: i)),
          updatedAt: DateTime.now(),
          status: TravelStatus.completed,
          type: TravelNoteType.public,
          isPrivate: false,
          tags: [
            TravelTag(name: '风景', color: Colors.blue),
            TravelTag(name: '美食', color: Colors.orange),
          ],
          likeCount: 50 - i,
          commentCount: 20 - i,
          favoriteCount: 10 - i,
          isLiked: false,
          isFavorited: false,
          contentItems: [],
          comments: [],
        ),
      );
    }

    return notes;
  }
}

class TravelNoteListScreen extends StatefulWidget {
  final String title;
  final String source; // 来源标识（如：收藏、足迹等）
  final List<TravelNote>? initialNotes; // 可选初始数据

  const TravelNoteListScreen({
    Key? key,
    required this.title,
    required this.source,
    this.initialNotes,
  }) : super(key: key);

  @override
  _TravelNoteListScreenState createState() => _TravelNoteListScreenState();
}

class _TravelNoteListScreenState extends State<TravelNoteListScreen>
    with TickerProviderStateMixin {
  late List<TravelNote> _travelNotes;
  late ScrollController _scrollController;
  late AnimationController _fadeAnimController;

  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _filterTag;
  String _sortBy = 'newest'; // newest, popular, oldest

  @override
  void initState() {
    super.initState();

    // 初始化数据
    _travelNotes = widget.initialNotes ?? [];
    if (_travelNotes.isEmpty) {
      _loadInitialData();
    }

    // 初始化滚动控制器
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // 初始化动画控制器
    _fadeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimController.forward();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeAnimController.dispose();
    super.dispose();
  }

  // 初始加载数据
  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // TODO: 实际的API调用
      // 这里使用模拟数据
      final mockNotes = MockDataGenerator.generateTravelNotes(10);

      setState(() {
        _travelNotes = mockNotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载失败: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 加载更多数据
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));

      // TODO: 实际的API调用
      // 这里使用模拟数据
      final mockNotes = MockDataGenerator.generateTravelNotes(5);

      // 模拟没有更多数据的情况
      final hasMore = _travelNotes.length < 30;

      setState(() {
        if (mockNotes.isNotEmpty && hasMore) {
          _travelNotes.addAll(mockNotes);
        } else {
          _hasMoreData = false;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载失败: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 刷新数据
  Future<void> _refreshData() async {
    setState(() {
      _hasMoreData = true;
    });

    await _loadInitialData();
    return Future.value();
  }

  // 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  // 设置筛选标签
  void _setFilterTag(String? tag) {
    setState(() {
      if (_filterTag == tag) {
        _filterTag = null; // 再次点击相同标签时取消筛选
      } else {
        _filterTag = tag;
      }
    });

    // 重新加载数据
    _refreshData();
  }

  // 设置排序方式
  void _setSortBy(String sortBy) {
    if (_sortBy == sortBy) return;

    setState(() {
      _sortBy = sortBy;

      // 排序当前列表
      switch (sortBy) {
        case 'newest':
          _travelNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case 'oldest':
          _travelNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'popular':
          _travelNotes.sort((a, b) => b.likeCount.compareTo(a.likeCount));
          break;
      }
    });
  }

  // 修改TravelNoteDetailScreen的导航方法
  void _navigateToDetailScreen(TravelNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                TravelNoteDetailScreen(noteId: note.id, initialData: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: AppTheme.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // 搜索按钮
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.primaryTextColor),
            onPressed: () {
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('搜索功能开发中...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          // 筛选按钮
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppTheme.primaryTextColor),
            onSelected: _setSortBy,
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'newest',
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color:
                              _sortBy == 'newest'
                                  ? AppTheme.buttonColor
                                  : AppTheme.secondaryTextColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '最新发布',
                          style: TextStyle(
                            color:
                                _sortBy == 'newest'
                                    ? AppTheme.buttonColor
                                    : AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'popular',
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color:
                              _sortBy == 'popular'
                                  ? AppTheme.buttonColor
                                  : AppTheme.secondaryTextColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '热门优先',
                          style: TextStyle(
                            color:
                                _sortBy == 'popular'
                                    ? AppTheme.buttonColor
                                    : AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'oldest',
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color:
                              _sortBy == 'oldest'
                                  ? AppTheme.buttonColor
                                  : AppTheme.secondaryTextColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '最早发布',
                          style: TextStyle(
                            color:
                                _sortBy == 'oldest'
                                    ? AppTheme.buttonColor
                                    : AppTheme.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 标签筛选栏
          _buildTagFilterBar(),

          // 游记列表
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: AppTheme.buttonColor,
              child:
                  _isLoading && _travelNotes.isEmpty
                      ? _buildLoadingIndicator()
                      : _buildNoteList(),
            ),
          ),
        ],
      ),
    );
  }

  // 构建标签筛选栏
  Widget _buildTagFilterBar() {
    // 获取所有标签
    final allTags = <String>[];
    for (var note in _travelNotes) {
      for (var tag in note.tags) {
        if (!allTags.contains(tag.name)) {
          allTags.add(tag.name);
        }
      }
    }

    // 热门标签（取前10个）
    final popularTags = allTags.take(10).toList();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularTags.length + 1, // +1 是因为有"全部"选项
        itemBuilder: (context, index) {
          if (index == 0) {
            // "全部"选项
            return _buildTagChip(
              label: '全部',
              isSelected: _filterTag == null,
              onTap: () => _setFilterTag(null),
            );
          } else {
            final tag = popularTags[index - 1];
            return _buildTagChip(
              label: tag,
              isSelected: _filterTag == tag,
              onTap: () => _setFilterTag(tag),
            );
          }
        },
      ),
    );
  }

  // 构建标签Chip
  Widget _buildTagChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.buttonColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryTextColor,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 构建游记列表
  Widget _buildNoteList() {
    if (_travelNotes.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _travelNotes.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _travelNotes.length) {
          return _buildLoadingIndicator();
        }

        final note = _travelNotes[index];
        return _buildNoteCard(note, index);
      },
    );
  }

  // 构建游记卡片
  Widget _buildNoteCard(TravelNote note, int index) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _fadeAnimController,
        curve: Interval(
          index < 10 ? (index / 10) : 0.0,
          index < 10 ? ((index + 1) / 10) : 1.0,
          curve: Curves.easeOut,
        ),
      ),
      child: GestureDetector(
        onTap: () => _navigateToDetailScreen(note),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12), // 减小底部边距
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12), // 减小圆角
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // 减小阴影
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图 - 减小高度
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    // 图片
                    CachedNetworkImage(
                      imageUrl: note.coverImage!,
                      height: 160, // 减小高度
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                            color: AppTheme.cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.buttonColor,
                              ),
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => Container(
                            color: AppTheme.cardColor,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: AppTheme.secondaryTextColor,
                                size: 40, // 减小图标大小
                              ),
                            ),
                          ),
                    ),

                    // 半透明渐变
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50, // 减小高度
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 地点和日期
                    Positioned(
                      bottom: 8, // 减小底部边距
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 12, // 减小图标大小
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              note.location,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11, // 减小字体大小
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy年MM月dd日').format(note.createdAt),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10, // 减小字体大小
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 内容区域 - 减小内边距
              Padding(
                padding: const EdgeInsets.all(10), // 减小内边距
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      note.title,
                      style: TextStyle(
                        color: AppTheme.primaryTextColor,
                        fontSize: 16, // 减小字体大小
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6), // 减小间距
                    // 摘要
                    Text(
                      note.summary,
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 13, // 减小字体大小
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10), // 减小间距
                    // 作者信息和互动数据
                    Row(
                      children: [
                        // 作者头像
                        CircleAvatar(
                          radius: 12, // 减小头像大小
                          backgroundImage:
                              note.authorAvatar != null
                                  ? NetworkImage(note.authorAvatar!)
                                  : null,
                          child:
                              note.authorAvatar == null
                                  ? Icon(
                                    Icons.person,
                                    color: AppTheme.primaryTextColor,
                                    size: 12,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 6), // 减小间距
                        // 作者名称
                        Text(
                          note.authorName,
                          style: TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 11, // 减小字体大小
                          ),
                        ),
                        const Spacer(),

                        // 使用Flex布局确保图标区域合理布局
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 点赞数
                            _buildStat(
                              Icons.thumb_up_outlined,
                              note.likeCount.toString(),
                            ),
                            const SizedBox(width: 10), // 减小间距
                            // 评论数
                            _buildStat(
                              Icons.comment_outlined,
                              note.commentCount.toString(),
                            ),
                            const SizedBox(width: 10), // 减小间距
                            // 收藏数
                            _buildStat(
                              Icons.bookmark_outline,
                              note.favoriteCount.toString(),
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
      ),
    );
  }

  // 构建统计数据 - 减小尺寸
  Widget _buildStat(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.secondaryTextColor,
          size: 12, // 减小图标大小
        ),
        const SizedBox(width: 2), // 减小间距
        Text(
          count,
          style: TextStyle(
            color: AppTheme.secondaryTextColor,
            fontSize: 10, // 减小字体大小
          ),
        ),
      ],
    );
  }

  // 构建加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: AppTheme.buttonColor),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            color: AppTheme.secondaryTextColor,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无游记',
            style: TextStyle(
              color: AppTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '去发现更多精彩旅程吧',
            style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('刷新'),
          ),
        ],
      ),
    );
  }
}
