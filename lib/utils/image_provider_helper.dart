import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片提供工具类，用于加载可查看的图片数据
class ImageProviderHelper {
  /// Picsum Photos API基础URL
  static const String _picsumBaseUrl = 'https://picsum.photos';
  
  /// 默认图片宽度
  static const int _defaultWidth = 300;
  
  /// 默认图片高度
  static const int _defaultHeight = 200;
  
  /// 图片映射表 - 将本地资源路径映射到特定的Picsum图片ID
  static final Map<String, int> _imageMap = {
    // 城市图片
    'assets/images/tokyo.jpg': 1031,
    'assets/images/paris.jpg': 1067,
    'assets/images/bangkok.jpg': 1027,
    'assets/images/newyork.jpg': 1042,
    
    // 活动图片
    'assets/images/activities/sakura.jpg': 200,
    'assets/images/activities/food_tour.jpg': 292,
    'assets/images/activities/diving.jpg': 633,
    'assets/images/activities/city_walk.jpg': 20,
    'assets/images/activities/camping.jpg': 501,
    'assets/images/activities/craft.jpg': 453,
    'assets/images/activities/balloon.jpg': 328,
    'assets/images/activities/yoga.jpg': 447,
    'assets/images/activities/onsen.jpg': 331,
    'assets/images/activities/cycling.jpg': 146,
    
    // 兑换图片
    'assets/images/exchange/starbucks.png': 766,
    'assets/images/exchange/music.png': 360,
    'assets/images/exchange/taxi.png': 534,
    'assets/images/exchange/jd.png': 325,
    'assets/images/exchange/hotel.png': 430,
    'assets/images/exchange/food.png': 429,
    'assets/images/exchange/bilibili.png': 324,
    'assets/images/exchange/movie.png': 335,
    
    // 地图和其他
    'assets/images/china_map_bg.png': 827,
    'assets/images/map.jpg': 326,
    
    // 头像
    'assets/images/avatars/default_avatar.png': 64,
    'assets/images/avatar.jpg': 64,
    'assets/images/avatar_pin.png': 65,
    'assets/images/avatar1.png': 237,
    'assets/images/avatar2.png': 238,
    'assets/images/avatar3.png': 239,
    'assets/images/avatar4.png': 240,
    'assets/images/avatar5.png': 241,
    'assets/images/avatar6.png': 242,
  };

  /// 获取指定宽高的图片
  static String getImageUrl(int width, int height, {int? seed}) {
    if (seed != null) {
      return '$_picsumBaseUrl/seed/$seed/$width/$height';
    }
    return '$_picsumBaseUrl/$width/$height';
  }
  
  /// 根据本地资源路径获取对应的在线图片
  static String getImageUrlFromAssetPath(String assetPath, {int width = _defaultWidth, int height = _defaultHeight}) {
    final int imageId = _imageMap[assetPath] ?? 1000;
    return '$_picsumBaseUrl/id/$imageId/$width/$height';
  }
  
  /// 获取图片Widget
  static Widget getImageWidget(String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // 检查是否为asset路径
    if (assetPath.startsWith('assets/')) {
      final imageUrl = getImageUrlFromAssetPath(
        assetPath, 
        width: width?.toInt() ?? _defaultWidth,
        height: height?.toInt() ?? _defaultHeight,
      );
      
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
      );
    }
    
    // 如果已经是网络图片URL，直接使用
    if (assetPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: assetPath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
      );
    }
    
    // 默认返回一个随机图片
    return CachedNetworkImage(
      imageUrl: getImageUrl(
        width?.toInt() ?? _defaultWidth,
        height?.toInt() ?? _defaultHeight,
      ),
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => errorWidget ?? const Icon(Icons.error),
    );
  }
} 