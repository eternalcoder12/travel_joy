import 'package:flutter/material.dart';

/// MCP设计系统尺寸常量
/// 用于统一整个应用程序的间距、边距、圆角等尺寸
class MCPDimension {
  // 圆角常量
  static const double radiusXXSmall = 2.0;
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircular = 50.0; // 圆形或胶囊形状

  // 间距常量 - 用于元素之间的间距
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingXXXLarge = 32.0;
  static const double spacingHuge = 48.0;

  // 内边距 - 用于容器内部的填充
  static const EdgeInsets paddingXSmall = EdgeInsets.all(4.0);
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(12.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(16.0);
  static const EdgeInsets paddingXLarge = EdgeInsets.all(20.0);
  static const EdgeInsets paddingXXLarge = EdgeInsets.all(24.0);
  
  // 水平内边距
  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets paddingHorizontalXLarge = EdgeInsets.symmetric(horizontal: 20.0);
  static const EdgeInsets paddingHorizontalXXLarge = EdgeInsets.symmetric(horizontal: 24.0);
  
  // 垂直内边距
  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets paddingVerticalXLarge = EdgeInsets.symmetric(vertical: 20.0);
  
  // 边距 - 用于容器外部的间距
  static const EdgeInsets marginXSmall = EdgeInsets.all(4.0);
  static const EdgeInsets marginSmall = EdgeInsets.all(8.0);
  static const EdgeInsets marginMedium = EdgeInsets.all(12.0);
  static const EdgeInsets marginLarge = EdgeInsets.all(16.0);
  static const EdgeInsets marginXLarge = EdgeInsets.all(20.0);
  
  // 水平边距
  static const EdgeInsets marginHorizontalSmall = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets marginHorizontalMedium = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsets marginHorizontalLarge = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets marginHorizontalXLarge = EdgeInsets.symmetric(horizontal: 20.0);
  
  // 垂直边距
  static const EdgeInsets marginVerticalSmall = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets marginVerticalMedium = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsets marginVerticalLarge = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets marginVerticalXLarge = EdgeInsets.symmetric(vertical: 20.0);
  
  // 常用组合边距
  static const EdgeInsets marginCardLarge = EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0);
  static const EdgeInsets marginCardMedium = EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0);
  
  // 阴影常量
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  static const double elevationXLarge = 12.0;
  
  // 图标尺寸常量
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 28.0;
  static const double iconSizeXXLarge = 32.0;
  
  // 图片高度
  static const double imageHeightSmall = 100.0;
  static const double imageHeightMedium = 180.0;
  static const double imageHeightLarge = 240.0;
  static const double imageHeightXLarge = 300.0;
  static const double imageHeightHero = 380.0;
  
  // 卡片内容尺寸
  static const double cardHeightSmall = 80.0;
  static const double cardHeightMedium = 120.0;
  static const double cardHeightLarge = 180.0;
  
  // 圆形容器尺寸
  static const double circleContainerSmall = 32.0;
  static const double circleContainerMedium = 40.0;
  static const double circleContainerLarge = 48.0;
  static const double circleContainerXLarge = 60.0;

  // 字体尺寸 (已经在AppTheme的textTheme中定义，此处仅为参考)
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeTitle = 22.0;
  static const double fontSizeHeadline = 26.0;
} 