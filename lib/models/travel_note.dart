import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:travel_joy/models/user.dart';
import 'package:travel_joy/models/comment.dart';
import 'package:travel_joy/models/location.dart';
import 'package:travel_joy/models/content_item.dart';

/// 游记内容类型枚举
enum ContentType {
  text,   // 文本内容
  image,  // 图片内容
  video,  // 视频内容
  location, // 位置内容
  mixed,  // 混合内容
}

/// 游记内容项
class TravelNoteContent {
  final ContentType type;
  final String content; // 文本内容或媒体URL
  final String? caption; // 媒体说明文字

  TravelNoteContent({
    required this.type,
    required this.content,
    this.caption,
  });

  // 从JSON创建内容项
  factory TravelNoteContent.fromJson(Map<String, dynamic> json) {
    return TravelNoteContent(
      type: ContentType.values.firstWhere(
        (e) => e.toString() == 'ContentType.${json['type']}',
        orElse: () => ContentType.text,
      ),
      content: json['content'] as String? ?? '',
      caption: json['caption'] as String?,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'content': content,
      'caption': caption,
    };
  }
}

/// 游记评论
class TravelNoteComment {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final List<String> likedBy; // 点赞用户ID列表
  final List<TravelNoteComment> replies; // 回复列表

  TravelNoteComment({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likedBy = const [],
    this.replies = const [],
  });

  // 从JSON创建评论
  factory TravelNoteComment.fromJson(Map<String, dynamic> json) {
    return TravelNoteComment(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      likedBy: (json['likedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ?? [],
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => TravelNoteComment.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

/// 旅行标签
class TravelTag {
  final String name;
  final Color? color;

  TravelTag({
    required this.name,
    this.color,
  });

  // 从JSON创建标签
  factory TravelTag.fromJson(Map<String, dynamic> json) {
    return TravelTag(
      name: json['name'] as String? ?? '',
      color: json['color'] != null 
          ? Color(json['color'] as int) 
          : null,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color?.value,
    };
  }
}

/// 旅行状态
enum TravelStatus {
  planning, // 计划中
  ongoing,  // 进行中
  completed, // 已完成
  cancelled, // 已取消
}

/// 旅行时长
class TravelDuration {
  final int days;
  final int hours;
  
  const TravelDuration({
    this.days = 0,
    this.hours = 0,
  });
  
  factory TravelDuration.fromHours(int totalHours) {
    final days = totalHours ~/ 24;
    final hours = totalHours % 24;
    return TravelDuration(days: days, hours: hours);
  }
  
  int get totalHours => days * 24 + hours;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TravelDuration &&
          runtimeType == other.runtimeType &&
          days == other.days &&
          hours == other.hours;
          
  @override
  int get hashCode => days.hashCode ^ hours.hashCode;
}

/// 游记类型
enum TravelNoteType {
  normal,
  guide,
  vlog,
}

/// 游记模型
class TravelNote extends Equatable {
  final String id;
  final String title;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String location;
  final String summary;
  final List<TravelTag> tags;
  final String? coverImage;
  final List<ContentItem> contentItems;
  final List<Comment> comments;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;
  final bool isFavorited;
  final TravelDuration? duration;
  final int? budget;
  final String? budgetCurrency;
  final TravelStatus status;
  final TravelNoteType type;
  final bool isPrivate;
  final int durationHours; // 游玩时长（小时）

  const TravelNote({
    required this.id,
    required this.title,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.location,
    required this.summary,
    required this.tags,
    this.coverImage,
    required this.contentItems,
    this.comments = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
    this.isFavorited = false,
    this.duration,
    this.budget,
    this.budgetCurrency,
    this.status = TravelStatus.completed,
    required this.type,
    required this.isPrivate,
    this.durationHours = 0,
  });

  TravelNote copyWith({
    String? id,
    String? title,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? location,
    String? summary,
    List<TravelTag>? tags,
    String? coverImage,
    List<ContentItem>? contentItems,
    List<Comment>? comments,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
    bool? isFavorited,
    TravelDuration? duration,
    int? budget,
    String? budgetCurrency,
    TravelStatus? status,
    TravelNoteType? type,
    bool? isPrivate,
    int? durationHours,
  }) {
    return TravelNote(
      id: id ?? this.id,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      coverImage: coverImage ?? this.coverImage,
      contentItems: contentItems ?? this.contentItems,
      comments: comments ?? this.comments,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      duration: duration ?? this.duration,
      budget: budget ?? this.budget,
      budgetCurrency: budgetCurrency ?? this.budgetCurrency,
      status: status ?? this.status,
      type: type ?? this.type,
      isPrivate: isPrivate ?? this.isPrivate,
      durationHours: durationHours ?? this.durationHours,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        authorId,
        authorName,
        authorAvatar,
        location,
        summary,
        tags,
        coverImage,
        contentItems,
        comments,
        viewCount,
        likeCount,
        commentCount,
        favoriteCount,
        createdAt,
        updatedAt,
        isLiked,
        isFavorited,
        duration,
        budget,
        budgetCurrency,
        status,
        type,
        isPrivate,
        durationHours,
      ];

  // 为了UI显示方便的一些辅助方法
  String get formattedDate => _formatDate(createdAt);
  
  String get formattedDuration {
    if (duration == null) return '未指定行程天数';
    
    if (duration!.days > 0) {
      return '${duration!.days}天${duration!.hours > 0 ? ' ${duration!.hours}小时' : ''}';
    } else {
      return '${duration!.hours}小时';
    }
  }
  
  String get formattedBudget {
    if (budget == null) return '未指定预算';
    
    final currency = budgetCurrency ?? '¥';
    if (budget! > 10000) {
      return '$currency ${(budget! / 10000).toStringAsFixed(1)}万';
    } else {
      return '$currency $budget';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '刚刚';
        }
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  // 获取游记的所有图片URL
  List<String> get allImages {
    List<String> images = [];
    
    // 添加封面图片
    if (coverImage != null) {
      images.add(coverImage!);
    }
    
    // 添加内容中的所有图片
    for (var content in contentItems) {
      if (content.type == ContentType.image) {
        images.add(content.content);
      }
    }
    
    return images;
  }

  // 获取游记的所有视频URL
  List<String> get allVideos {
    return contentItems
        .where((content) => content.type == ContentType.video)
        .map((content) => content.content)
        .toList();
  }

  // 创建一个示例游记
  static TravelNote createSample() {
    return TravelNote(
      id: '1',
      title: '东京樱花季之旅',
      authorId: 'user1',
      authorName: '旅行者小明',
      authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
      location: '东京',
      summary: '三月的东京，樱花盛开。这是一次充满惊喜与感动的旅行...',
      tags: [
        TravelTag(name: '樱花', color: Colors.pink),
        TravelTag(name: '东京', color: Colors.blue),
        TravelTag(name: '日本', color: Colors.red),
        TravelTag(name: '自由行', color: Colors.green),
      ],
      coverImage: 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
      contentItems: [
        TravelNoteContent(
          type: ContentType.text,
          content: '三月的东京，樱花盛开。漫步在上野公园，粉色的樱花如雪花般洒落，美不胜收。这次旅行我们计划了7天的行程，探索了东京、镰仓和横滨。',
        ),
        TravelNoteContent(
          type: ContentType.image,
          content: 'https://images.unsplash.com/photo-1542051841857-5f90071e7989?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          caption: '上野公园的樱花景观',
        ),
        TravelNoteContent(
          type: ContentType.text,
          content: '第一站是东京塔，夜幕下的东京塔格外璀璨。我们在塔下拍了很多照片，登上塔顶俯瞰整个东京城的夜景，繁华与宁静并存。',
        ),
        TravelNoteContent(
          type: ContentType.image,
          content: 'https://images.unsplash.com/photo-1536098561742-ca998e48cbcc?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
          caption: '夜晚的东京塔',
        ),
        TravelNoteContent(
          type: ContentType.video,
          content: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
          caption: '东京街头漫步',
        ),
        TravelNoteContent(
          type: ContentType.text,
          content: '第二天我们前往浅草寺，这里是东京最古老的寺庙。寺前的雷门和商店街充满了浓郁的日本传统文化气息。我们品尝了当地的传统小吃，如人形烧和抹茶冰淇淋。',
        ),
        TravelNoteContent(
          type: ContentType.image,
          content: 'https://images.unsplash.com/photo-1584611133366-f8bd14af9a3f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
          caption: '浅草寺雷门',
        ),
      ],
      comments: [
        TravelNoteComment(
          id: 'c1',
          authorId: 'user2',
          authorName: '旅游达人',
          authorAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
          content: '照片拍得很美！请问樱花季去东京最佳时间是几月份？',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          likedBy: ['user3', 'user4'],
          replies: [
            TravelNoteComment(
              id: 'r1',
              authorId: 'user1',
              authorName: '旅行者小明',
              authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
              content: '谢谢！一般是3月下旬到4月上旬，但具体看当年气候，建议出发前查看樱花预报。',
              createdAt: DateTime.now().subtract(const Duration(days: 4)),
            ),
          ],
        ),
        TravelNoteComment(
          id: 'c2',
          authorId: 'user5',
          authorName: '摄影爱好者',
          authorAvatar: 'https://randomuser.me/api/portraits/men/67.jpg',
          content: '东京塔的夜景照片构图很棒，请问用的什么相机？',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      viewCount: 10,
      likeCount: 5,
      commentCount: 2,
      favoriteCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      isLiked: true,
      isFavorited: true,
      duration: TravelDuration(days: 7, hours: 6),
      budget: 10000,
      budgetCurrency: '¥',
      status: TravelStatus.completed,
      type: TravelNoteType.normal,
      isPrivate: false,
      durationHours: 42,
    );
  }
} 