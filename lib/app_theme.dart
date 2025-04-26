import 'package:flutter/material.dart';

class AppTheme {
  // 颜色常量 - 添加2023年流行的颜色方案
  static const Color backgroundColor = Color(0xFF1A1A2E); // 深蓝黑色背景
  static const Color cardColor = Color(0xFF262645); // 深蓝紫卡片
  static const Color primaryTextColor = Color(0xFFFFFFFF); // 白色文字
  static const Color secondaryTextColor = Color(0xFFB8B8D0); // 淡紫色次要文字
  static const Color buttonColor = Color(0xFF4D79FF); // 蓝色按钮
  static const Color accentColor = Color(0xFF7E6CCA); // 紫色强调色
  static const Color iconColor = Color(0xFFFFFFFF); // 白色图标
  static const Color hintTextColor = Color(0xFF9494B8); // 淡紫色提示文字
  static const Color errorColor = Color(0xFFFF5252); // 错误颜色
  static const Color successColor = Color(0xFF4CAF50); // 成功颜色

  // 为与现有代码兼容添加的颜色常量
  static const Color darkText = primaryTextColor; // 与primaryTextColor保持一致
  static const Color grey = secondaryTextColor; // 与secondaryTextColor保持一致
  static const Color nearlyWhite = Color(0xFFFAFAFA); // 接近白色
  static const Color nearlyBlue = buttonColor; // 与buttonColor保持一致
  static const Color nearlyDarkBlue = Color(0xFF2633C5); // 深蓝色
  static const Color background = backgroundColor; // 与backgroundColor保持一致

  // 2023流行趋势: 鲜艳色彩和渐变
  static const Color neonPurple = Color(0xFF9D4EDD); // 霓虹紫色
  static const Color neonBlue = Color(0xFF00B4D8); // 霓虹蓝色
  static const Color neonPink = Color(0xFFFF48C4); // 霓虹粉色
  static const Color neonTeal = Color(0xFF2EC4B6); // 霓虹青色
  static const Color neonOrange = Color(0xFFFF9E00); // 霓虹橙色
  static const Color neonGreen = Color(0xFF39D353); // 霓虹绿色
  static const Color neonYellow = Color(0xFFFFD700); // 霓虹黄色

  // 设施与服务类型颜色
  static const Color facilityCommunication = Color(0xFF4D79FF); // 通信设施 - 蓝色
  static const Color facilityDining = Color(0xFFFF9E00); // 餐饮设施 - 橙色
  static const Color facilityTransport = Color(0xFF2EC4B6); // 交通设施 - 青色
  static const Color facilityAccessibility = Color(0xFF9D4EDD); // 无障碍设施 - 紫色
  static const Color facilitySightseeing = Color(0xFFFF48C4); // 观光设施 - 粉色
  static const Color facilityShopping = Color(0xFF4CAF50); // 购物设施 - 绿色
  static const Color facilityDefault = Color(0xFFB8B8D0); // 默认设施颜色

  // 2023流行趋势: 暗色主题渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [buttonColor, accentColor],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonOrange, neonPink],
  );

  // 获取应用主题
  static ThemeData getTheme() {
    return ThemeData(
      // 基础颜色配置
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        primary: buttonColor,
        secondary: accentColor,
        background: backgroundColor,
        surface: cardColor,
        error: errorColor,
      ),

      // 卡片主题 - 2023流行趋势: 增强阴影和圆角效果
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 10.0, // 增大阴影
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24.0)), // 增大圆角
        ),
        shadowColor: Color(0x80000000), // 加深阴影
      ),

      // 文字主题 - 2023流行趋势: 大胆的排版
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        // 标题文字 - 加大字号，增强对比
        headlineLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 36.0, // 增大字号
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5, // 更紧凑的字间距
        ),
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 28.0, // 增大字号
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 22.0, // 增大字号
          fontWeight: FontWeight.w600,
        ),
        // 描述性文字
        bodyLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2, // 增加字间距提高可读性
        ),
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
        ),
        // 按钮文字 - 更大胆
        labelLarge: TextStyle(
          color: primaryTextColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5, // 增加字间距提高可读性
        ),
      ),

      // 输入框主题 - 2023流行趋势: 柔和的Neumorphism风格
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(18.0)), // 增大圆角
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accentColor, width: 1.5), // 加粗边框
          borderRadius: BorderRadius.all(Radius.circular(18.0)),
        ),
        hintStyle: TextStyle(color: hintTextColor),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20.0,
        ), // 增大内边距
        // 2023流行趋势: 阴影效果增强
        isDense: true,
        errorStyle: TextStyle(color: errorColor, fontSize: 12.0),
      ),

      // 下拉框主题 - 现代化风格
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(18.0)), // 增大圆角
          ),
        ),
        textStyle: TextStyle(color: primaryTextColor),
      ),

      // 开关主题 - 2023流行趋势: 更现代的开关样式
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryTextColor;
          }
          return hintTextColor;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return buttonColor;
          }
          return cardColor;
        }),
        // 增加轨道高度和宽度
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),

      // 按钮主题 - 2023流行趋势: 大胆的按钮设计
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return buttonColor.withOpacity(0.5);
            }
            return buttonColor;
          }),
          foregroundColor: MaterialStateProperty.all(primaryTextColor),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(
              vertical: 18.0,
              horizontal: 30.0,
            ), // 增大内边距
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ), // 更大的圆角
          ),
          elevation: MaterialStateProperty.resolveWith((states) {
            // 2023流行趋势: 交互状态下的悬浮效果
            if (states.contains(MaterialState.pressed)) {
              return 0;
            } else if (states.contains(MaterialState.hovered)) {
              return 8;
            }
            return 4;
          }),
          shadowColor: MaterialStateProperty.all(buttonColor.withOpacity(0.4)),
          // 2023流行趋势: 按钮过渡动画
          animationDuration: Duration(milliseconds: 200),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white.withOpacity(0.1);
            }
            return Colors.transparent;
          }),
        ),
      ),

      // 文本按钮主题 - 更现代的风格
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(accentColor),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
          overlayColor: MaterialStateProperty.all(accentColor.withOpacity(0.1)),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),

      // 图标主题 - 2023流行趋势: 更大、更明显的图标
      iconTheme: const IconThemeData(color: iconColor, size: 28.0), // 增大图标尺寸
      // 页面过渡动画 - 2023流行趋势: 流畅过渡
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(), // 缩放过渡效果
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Snackbar主题 - 2023流行趋势: 更圆润的提示
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: cardColor,
        contentTextStyle: TextStyle(color: primaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18.0)), // 增大圆角
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6, // 增加阴影
      ),

      // 底部导航栏主题 - 2023流行趋势: 更现代的导航
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: buttonColor,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 16.0, // 增加阴影
        selectedIconTheme: IconThemeData(size: 28.0), // 增大选中图标
        unselectedIconTheme: IconThemeData(size: 24.0),
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      ),

      // 检查框主题 - 2023流行趋势: 现代化的复选框
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return buttonColor;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(primaryTextColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ), // 更圆润
        side: const BorderSide(color: secondaryTextColor, width: 1.5),
      ),

      // 2023流行趋势: 滑动刷新指示器主题
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: buttonColor,
        circularTrackColor: cardColor,
        linearTrackColor: cardColor,
      ),

      // 2023流行趋势: 滚动物理效果 - 更平滑
      scrollbarTheme: ScrollbarThemeData(
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(6.0),
        thumbColor: MaterialStateProperty.all(accentColor.withOpacity(0.5)),
      ),
    );
  }

  // 2023流行趋势: 获取Neumorphism效果的装饰
  static BoxDecoration getNeumorphicDecoration({
    Color? color,
    double borderRadius = 15.0,
    Offset? offset,
    double blur = 20.0,
    double intensity = 0.15,
  }) {
    color ??= cardColor;
    offset ??= const Offset(5, 5);

    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        // 暗阴影
        BoxShadow(
          color: Colors.black.withOpacity(intensity),
          offset: offset,
          blurRadius: blur,
        ),
        // 亮阴影
        BoxShadow(
          color: Colors.white.withOpacity(intensity / 2),
          offset: Offset(-offset.dx, -offset.dy),
          blurRadius: blur,
        ),
      ],
    );
  }

  // 2023流行趋势: 获取玻璃态效果的装饰 (Glassmorphism)
  static BoxDecoration getGlassDecoration({
    double opacity = 0.2,
    double borderRadius = 24.0,
    Color? borderColor,
    double borderWidth = 1.5,
    Color? gradientColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? Colors.white.withOpacity(0.2),
        width: borderWidth,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (gradientColor ?? Colors.white).withOpacity(opacity * 1.5),
          (gradientColor ?? Colors.white).withOpacity(opacity),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // 2023流行趋势: 获取用于动画波浪效果的装饰
  static BoxDecoration getWaveDecoration({
    required Color baseColor,
    double borderRadius = 24.0,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [baseColor.withOpacity(0.8), baseColor.withOpacity(0.2)],
      ),
    );
  }
}
