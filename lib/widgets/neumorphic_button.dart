import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 新拟态按钮组件 - 2023年流行UI趋势
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final Color? color;
  final Color? shadowDarkColor;
  final Color? shadowLightColor;
  final double height;
  final double width;
  final EdgeInsetsGeometry? padding;
  final bool isActive;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.borderRadius = 15.0,
    this.color,
    this.shadowDarkColor,
    this.shadowLightColor,
    this.height = 56.0,
    this.width = double.infinity,
    this.padding,
    this.isActive = false,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.color ?? AppTheme.cardColor;
    final shadowDarkColor = widget.shadowDarkColor ?? Colors.black;
    final shadowLightColor = widget.shadowLightColor ?? Colors.white;

    // 根据按钮状态调整阴影偏移
    final bool effectivePressed = _isPressed || widget.isActive;
    final Offset offset =
        effectivePressed ? const Offset(0, 0) : const Offset(3, 3);

    return GestureDetector(
      onTapDown:
          widget.onPressed == null
              ? null
              : (_) {
                setState(() {
                  _isPressed = true;
                });
              },
      onTapUp:
          widget.onPressed == null
              ? null
              : (_) {
                setState(() {
                  _isPressed = false;
                });
                widget.onPressed!();
              },
      onTapCancel:
          widget.onPressed == null
              ? null
              : () {
                setState(() {
                  _isPressed = false;
                });
              },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        width: widget.width,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow:
              effectivePressed
                  ? [
                    // 按下状态的阴影 - 内陷效果
                    BoxShadow(
                      color: shadowDarkColor.withOpacity(0.3),
                      offset: const Offset(1, 1),
                      blurRadius: 5,
                      spreadRadius: -1,
                    ),
                    BoxShadow(
                      color: shadowLightColor.withOpacity(0.3),
                      offset: const Offset(-1, -1),
                      blurRadius: 5,
                      spreadRadius: -1,
                    ),
                  ]
                  : [
                    // 未按下状态的阴影 - 凸起效果
                    BoxShadow(
                      color: shadowDarkColor.withOpacity(0.6),
                      offset: offset,
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: shadowLightColor.withOpacity(0.6),
                      offset: -offset,
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

/// 显示案例:
///
/// ```dart
/// NeumorphicButton(
///   onPressed: () {
///     print('按钮被点击');
///   },
///   borderRadius: 16,
///   color: AppTheme.cardColor,
///   child: Text(
///     '探索目的地',
///     style: TextStyle(
///       color: AppTheme.primaryTextColor,
///       fontWeight: FontWeight.bold,
///     ),
///   ),
/// )
/// ```
