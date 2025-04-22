import 'package:flutter/material.dart';

class AppTheme {
  // 颜色常量
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2C2C2E);
  static const Color primaryTextColor = Color(0xFFFFFFFF);
  static const Color secondaryTextColor = Color(0xFFB0B0B0);
  static const Color buttonColor = Color(0xFFD3D3D3);
  static const Color iconColor = Color(0xFFFFFFFF);
  static const Color hintTextColor = Color(0xFFAEAEAE);

  // 获取应用主题
  static ThemeData getTheme() {
    return ThemeData(
      // 基础颜色配置
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: backgroundColor,

      // 卡片主题
      cardTheme: const CardTheme(
        color: cardColor,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),

      // 文字主题
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        // 标题文字
        headlineMedium: TextStyle(
          color: primaryTextColor,
          fontSize: 24.0,
          fontWeight: FontWeight.w700,
        ),
        // 描述性文字
        bodyMedium: TextStyle(
          color: secondaryTextColor,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
        // 按钮文字
        labelLarge: TextStyle(
          color: hintTextColor,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 输入框主题
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        hintStyle: TextStyle(color: hintTextColor),
      ),

      // 下拉框主题
      dropdownMenuTheme: const DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        textStyle: TextStyle(color: primaryTextColor),
      ),

      // 开关主题
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white),
        trackColor: MaterialStateProperty.all(buttonColor),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(buttonColor),
          foregroundColor: MaterialStateProperty.all(hintTextColor),
          padding: MaterialStateProperty.all(const EdgeInsets.all(12.0)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
        ),
      ),

      // 图标主题
      iconTheme: const IconThemeData(color: iconColor),

      // 页面过渡动画
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
