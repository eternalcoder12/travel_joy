import 'package:flutter/material.dart';

/// 显示Snackbar提示信息
void showSnackBar(BuildContext context, String message, {
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
  Color? backgroundColor,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: duration,
    action: action,
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    margin: const EdgeInsets.all(16.0),
  );
  
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// 显示成功提示
void showSuccessSnackBar(BuildContext context, String message) {
  showSnackBar(
    context, 
    message,
    backgroundColor: Colors.green[700],
  );
}

/// 显示错误提示
void showErrorSnackBar(BuildContext context, String message) {
  showSnackBar(
    context, 
    message,
    backgroundColor: Colors.red[700],
  );
}

/// 显示带确认按钮的提示
void showActionSnackBar(BuildContext context, String message, String actionLabel, VoidCallback onPressed) {
  showSnackBar(
    context, 
    message,
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: actionLabel,
      onPressed: onPressed,
    ),
  );
} 