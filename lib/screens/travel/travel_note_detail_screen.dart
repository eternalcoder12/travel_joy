import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import '../../models/travel_note.dart';
import '../../app_theme.dart';
import '../../widgets/glass_card.dart';

// 添加缺失的ContentType枚举
enum ContentType { text, image, video, location }

// 添加缺失的Comment类
class Comment {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final List<CommentReply> replies;

  Comment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
    this.replies = const [],
  });
}

// 添加缺失的CommentReply类
class CommentReply {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;

  CommentReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
  });
}

// 添加缺失的ContentItem类
class ContentItem {
  final ContentType type;
  final String content;
  final String? caption;

  ContentItem({required this.type, required this.content, this.caption});
}

// 添加缺失的LoadingIndicator组件
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.buttonColor),
    );
  }
}

// 添加缺失的CustomIconButton组件
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final int? count;
  final bool isActive;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.count,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isActive
                      ? AppTheme.buttonColor
                      : (color ?? AppTheme.secondaryTextColor),
              size: 18,
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TravelNoteDetailScreen extends StatefulWidget {
  final String noteId;
  final TravelNote initialData;

  const TravelNoteDetailScreen({
    Key? key,
    required this.noteId,
    required this.initialData,
  }) : super(key: key);

  @override
  State<TravelNoteDetailScreen> createState() => _TravelNoteDetailScreenState();
}

class _TravelNoteDetailScreenState extends State<TravelNoteDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _commentController = TextEditingController();
  late TravelNote travelNote;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    travelNote = widget.initialData;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  // 显示提示信息的辅助方法
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // 格式化日期的辅助方法
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildAppBar(context, travelNote),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: '内容'),
                    Tab(text: '图片'),
                    Tab(text: '评论'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContentTab(context, travelNote),
            _buildGalleryTab(context, travelNote),
            _buildCommentsTab(context, travelNote),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, travelNote),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, TravelNote travelNote) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          travelNote.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // 封面图片
            CachedNetworkImage(
              imageUrl:
                  travelNote.coverImage ??
                  'https://via.placeholder.com/800x600?text=暂无封面图',
              fit: BoxFit.cover,
              placeholder:
                  (context, url) =>
                      const Center(child: CircularProgressIndicator()),
              errorWidget:
                  (context, url, error) =>
                      const Center(child: Icon(Icons.error)),
            ),
            // 渐变遮罩
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            // 底部信息
            Positioned(
              left: 16,
              right: 16,
              bottom: 48,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      travelNote.location,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _getTravelStatusIcon(travelNote.status),
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStatusText(travelNote.status),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _shareNote(travelNote),
        ),
        IconButton(
          icon: Icon(
            travelNote.isFavorited ? Icons.bookmark : Icons.bookmark_border,
          ),
          onPressed: () => _toggleFavorite(travelNote),
        ),
      ],
    );
  }

  Widget _buildContentTab(BuildContext context, TravelNote travelNote) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 作者信息
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          travelNote.authorAvatar != null
                              ? NetworkImage(travelNote.authorAvatar!)
                              : null,
                      child:
                          travelNote.authorAvatar == null
                              ? Text(travelNote.authorName[0])
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            travelNote.authorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '发布于 ${formatDate(travelNote.createdAt)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () => _followAuthor(travelNote.authorId),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: const Text('关注'),
                    ),
                  ],
                ),
              ),

              // 标签栏
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children:
                      travelNote.tags.map((tag) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6.0,
                          ),
                          decoration: BoxDecoration(
                            color:
                                tag.color?.withOpacity(0.1) ??
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            '#${tag.name}',
                            style: TextStyle(
                              color:
                                  tag.color ?? Theme.of(context).primaryColor,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              // 游记摘要
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  travelNote.summary,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),

              // 游记内容项
              ...travelNote.contentItems.map((item) {
                return _buildContentItem(context, item);
              }).toList(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentItem(BuildContext context, ContentItem item) {
    switch (item.type) {
      case ContentType.text:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            item.content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.primaryTextColor,
            ),
          ),
        );

      case ContentType.image:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _openGalleryViewer(context, [item.content], 0),
                child: CachedNetworkImage(
                  imageUrl: item.content,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                  errorWidget:
                      (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                ),
              ),
              if (item.caption != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.caption!,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
            ],
          ),
        );

      case ContentType.video:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 视频缩略图
                      CachedNetworkImage(
                        imageUrl: '${item.content}_thumbnail.jpg',
                        fit: BoxFit.cover,
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.videocam,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                      ),
                      // 播放按钮
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_fill,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // 播放视频的逻辑
                          showSnackBar(context, '播放视频: ${item.content}');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (item.caption != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item.caption!,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        );

      case ContentType.location:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () => _openMap(item.content),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.content,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (item.caption != null)
                          Text(
                            item.caption!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGalleryTab(BuildContext context, TravelNote travelNote) {
    // 提取所有图片
    final images =
        travelNote.contentItems
            .where((item) => item.type == ContentType.image)
            .map((item) => item.content)
            .toList();

    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_library, size: 60, color: Colors.grey),
            const SizedBox(height: 16.0),
            const Text(
              '暂无图片',
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openGalleryViewer(context, images, index),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsTab(BuildContext context, TravelNote travelNote) {
    if (travelNote.comments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.comment, size: 60, color: Colors.grey),
            const SizedBox(height: 16.0),
            const Text(
              '还没有评论',
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _focusCommentField(),
              child: const Text('写下第一条评论'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: travelNote.comments.length,
      itemBuilder: (context, index) {
        final comment = travelNote.comments[index];
        return CommentItem(
          comment: comment,
          onLike: () => _likeComment(comment.id),
          onReply: () => _replyToComment(comment),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, TravelNote travelNote) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5.0,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '发表评论...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            CustomIconButton(
              icon: Icons.send,
              onPressed: () => _submitComment(travelNote.id),
            ),
            const SizedBox(width: 8.0),
            CustomIconButton(
              icon: travelNote.isLiked ? Icons.favorite : Icons.favorite_border,
              color: travelNote.isLiked ? Colors.red : null,
              count: travelNote.likeCount,
              onPressed: () => _toggleLike(travelNote),
            ),
            const SizedBox(width: 8.0),
            CustomIconButton(
              icon: Icons.bookmark,
              count: travelNote.favoriteCount,
              isActive: travelNote.isFavorited,
              onPressed: () => _toggleFavorite(travelNote),
            ),
          ],
        ),
      ),
    );
  }

  // 辅助方法
  void _shareNote(TravelNote note) {
    Share.share(
      '查看这篇精彩的游记：${note.title} 👉 https://traveljoy.app/note/${note.id}',
    );
  }

  void _toggleFavorite(TravelNote note) {
    setState(() {
      // 直接在本地修改状态，实际应用中应该调用API
      note.isFavorited = !note.isFavorited;
      if (note.isFavorited) {
        note.favoriteCount += 1;
      } else if (note.favoriteCount > 0) {
        note.favoriteCount -= 1;
      }
    });

    showSnackBar(context, note.isFavorited ? '已添加到收藏' : '已从收藏中移除');
  }

  void _toggleLike(TravelNote note) {
    setState(() {
      // 直接在本地修改状态，实际应用中应该调用API
      note.isLiked = !note.isLiked;
      if (note.isLiked) {
        note.likeCount += 1;
      } else if (note.likeCount > 0) {
        note.likeCount -= 1;
      }
    });

    showSnackBar(context, note.isLiked ? '已点赞' : '已取消点赞');
  }

  void _followAuthor(String authorId) {
    // 调用服务关注作者
    // 这里可以添加关注作者的逻辑
    showSnackBar(context, '已关注作者');
  }

  void _openMap(String location) {
    // 打开地图
    showSnackBar(context, '打开地图: $location');
  }

  void _openGalleryViewer(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    // 打开图片查看器
    // 这里可以导航到单独的图片查看页面
    showSnackBar(context, '查看图片 ${initialIndex + 1} / ${images.length}');
  }

  void _likeComment(String commentId) {
    // 点赞评论
    showSnackBar(context, '已点赞评论');
  }

  void _replyToComment(Comment comment) {
    // 回复评论
    _commentController.text = '@${comment.authorName} ';
    _focusCommentField();
  }

  void _focusCommentField() {
    // 跳转到评论输入框
    _tabController.animateTo(2); // 切换到评论选项卡
    // 在下一帧聚焦评论框
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(FocusNode());
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: _commentController.text.length),
      );
    });
  }

  void _submitComment(String noteId) {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      showSnackBar(context, '评论内容不能为空');
      return;
    }

    // 提交评论 - 这里只是模拟添加评论
    setState(() {
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: 'current_user_id',
        authorName: '当前用户',
        content: content,
        createdAt: DateTime.now(),
      );

      travelNote.comments.add(newComment);
      travelNote.commentCount += 1;
    });

    _commentController.clear();
    showSnackBar(context, '评论已发布');
  }

  IconData _getTravelStatusIcon(TravelStatus status) {
    switch (status) {
      case TravelStatus.planning:
        return Icons.event_note;
      case TravelStatus.ongoing:
        return Icons.directions_walk;
      case TravelStatus.completed:
        return Icons.check_circle_outline;
      case TravelStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(TravelStatus status) {
    switch (status) {
      case TravelStatus.planning:
        return '计划中';
      case TravelStatus.ongoing:
        return '进行中';
      case TravelStatus.completed:
        return '已完成';
      case TravelStatus.cancelled:
        return '已取消';
      default:
        return '未知状态';
    }
  }
}

// 持久化标签页委托
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

// 评论项组件
class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.onLike,
    required this.onReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                comment.authorAvatar != null
                    ? NetworkImage(comment.authorAvatar!)
                    : null,
            child:
                comment.authorAvatar == null
                    ? Text(comment.authorName[0])
                    : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onLike,
                      child: Row(
                        children: [
                          Icon(
                            Icons.thumb_up,
                            size: 16,
                            color:
                                comment.isLiked
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onReply,
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '回复',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 回复列表
                if (comment.replies.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          comment.replies.map((reply) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        reply.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        _formatDate(reply.createdAt),
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reply.content,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 日期格式化辅助方法
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
