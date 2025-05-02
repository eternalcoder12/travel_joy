import 'package:flutter/material.dart';

/// 内容类型枚举
enum ContentType {
  text,    // 文本内容
  image,   // 图片内容
  video,   // 视频内容
  location, // 位置内容
  mixed,   // 混合内容
}

/// 内容项
class ContentItem {
  final String id;
  final ContentType type;
  final String content; // 文本内容或媒体URL
  final String? caption; // 媒体说明文字

  ContentItem({
    required this.id,
    required this.type,
    required this.content,
    this.caption,
  });

  // 从JSON创建内容项
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? UniqueKey().toString(),
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
      'id': id,
      'type': type.toString().split('.').last,
      'content': content,
      'caption': caption,
    };
  }
} 