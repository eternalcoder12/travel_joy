import 'package:flutter/material.dart';
import '../app_theme.dart';

/// 渐变按钮组件 - 2023年流行UI趋势
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final double height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget? icon;
  final bool isLoading;
  final TextStyle? textStyle;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.height = 56.0,
    this.width = double.infinity,
    this.borderRadius = 24.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.icon,
    this.isLoading = false,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppTheme.primaryGradient;
    final bool isDisabled = onPressed == null || isLoading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.white.withOpacity(0.1),
        child: Ink(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient:
                isDisabled
                    ? LinearGradient(
                      colors: [
                        effectiveGradient.colors[0].withOpacity(0.5),
                        effectiveGradient.colors[1].withOpacity(0.5),
                      ],
                      begin: effectiveGradient.begin,
                      end: effectiveGradient.end,
                    )
                    : effectiveGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: effectiveGradient.colors[1].withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                else if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 12),
                ],
                Text(
                  text,
                  style:
                      textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                ),
              ],
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
/// GradientButton(
///   text: '现在开始',
///   gradient: AppTheme.accentGradient,
///   onPressed: () {
///     print('开始按钮被点击');
///   },
///   icon: Icon(Icons.flight, color: Colors.white),
/// )
/// ```
