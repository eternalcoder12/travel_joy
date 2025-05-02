import 'package:flutter/material.dart';

/// 通用加载指示器
class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.size = 36.0,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor,
            ),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16.0),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 全屏加载指示器，可添加背景
class FullScreenLoadingIndicator extends StatelessWidget {
  final String? message;
  final bool hasBackground;
  
  const FullScreenLoadingIndicator({
    Key? key,
    this.message,
    this.hasBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: hasBackground ? Colors.black.withOpacity(0.3) : Colors.transparent,
      child: Center(
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: LoadingIndicator(message: message),
          ),
        ),
      ),
    );
  }
} 