import 'package:flutter/material.dart';
import 'package:travel_joy/utils/image_provider_helper.dart';

/// 网络图片组件
/// 用于替换项目中的本地图片资源，使用在线图片服务
class NetworkImage extends StatelessWidget {
  /// 图片路径（本地资源路径或网络URL）
  final String imageUrl;
  
  /// 图片宽度
  final double? width;
  
  /// 图片高度
  final double? height;
  
  /// 图片适应方式
  final BoxFit fit;
  
  /// 加载占位Widget
  final Widget? placeholder;
  
  /// 错误占位Widget
  final Widget? errorWidget;
  
  /// 边框圆角
  final BorderRadius? borderRadius;
  
  /// 构造函数
  const NetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    final imageWidget = ImageProviderHelper.getImageWidget(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
    
    // 如果需要圆角，添加ClipRRect
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    
    return imageWidget;
  }
} 