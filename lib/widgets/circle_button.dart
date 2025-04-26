import 'package:flutter/material.dart';
import '../app_theme.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.iconSize = 18,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.cardColor.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryTextColor,
            size: iconSize,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
