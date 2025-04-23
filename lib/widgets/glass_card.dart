import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'dart:math' as math;

/// 玻璃态卡片组件 - 2023年流行UI趋势
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final Color? borderColor;
  final double elevation;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.blur = 10.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(16.0),
    this.opacity = 0.2,
    this.borderColor,
    this.elevation = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:
              elevation > 0
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: elevation,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: math.min(blur, 5.0),
              sigmaY: math.min(blur, 5.0),
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: (backgroundColor ?? Colors.white).withOpacity(opacity),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: borderColor ?? Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 显示案例:
///
/// ```dart
/// GlassCard(
///   borderRadius: 24,
///   blur: 10,
///   opacity: 0.2,
///   child: Padding(
///     padding: const EdgeInsets.all(20),
///     child: Column(
///       crossAxisAlignment: CrossAxisAlignment.start,
///       children: [
///         Text(
///           '旅行目的地',
///           style: TextStyle(
///             fontSize: 24,
///             fontWeight: FontWeight.bold,
///             color: Colors.white,
///           ),
///         ),
///         SizedBox(height: 10),
///         Text(
///           '探索世界最美丽的地方，发现隐藏的宝藏。',
///           style: TextStyle(color: Colors.white70),
///         ),
///       ],
///     ),
///   ),
/// )
/// ```
