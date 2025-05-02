import 'package:intl/intl.dart';

/// 格式化日期，根据距今时间显示不同格式
String formatDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  // 如果是今天内的时间
  if (difference.inDays == 0) {
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return '刚刚';
      }
      return '${difference.inMinutes} 分钟前';
    }
    return '${difference.inHours} 小时前';
  }
  
  // 如果是昨天
  if (difference.inDays == 1) {
    return '昨天 ${DateFormat('HH:mm').format(dateTime)}';
  }
  
  // 如果是一周内
  if (difference.inDays < 7) {
    return '${difference.inDays} 天前';
  }
  
  // 如果是今年内
  if (dateTime.year == now.year) {
    return DateFormat('MM-dd HH:mm').format(dateTime);
  }
  
  // 超过一年
  return DateFormat('yyyy-MM-dd').format(dateTime);
}

/// 格式化日期范围，用于展示旅行时间段
String formatDateRange(DateTime startDate, DateTime? endDate) {
  final startStr = DateFormat('yyyy年MM月dd日').format(startDate);
  
  if (endDate == null) {
    return startStr;
  }
  
  // 如果开始和结束日期在同一年
  if (startDate.year == endDate.year) {
    // 如果开始和结束日期在同一月
    if (startDate.month == endDate.month) {
      return '${DateFormat('yyyy年MM月dd').format(startDate)}-${DateFormat('dd日').format(endDate)}';
    } else {
      return '${DateFormat('yyyy年MM月dd日').format(startDate)}-${DateFormat('MM月dd日').format(endDate)}';
    }
  }
  
  // 不在同一年
  return '$startStr - ${DateFormat('yyyy年MM月dd日').format(endDate)}';
}

/// 格式化时长，将天数转换为易读格式
String formatDuration(int days) {
  if (days <= 0) return '未知';
  
  if (days == 1) return '1天';
  if (days < 7) return '$days天';
  
  final weeks = days ~/ 7;
  final remainingDays = days % 7;
  
  if (remainingDays == 0) {
    return '$weeks周';
  } else {
    return '$weeks周$remainingDays天';
  }
}

/// 格式化预算，根据金额大小显示不同单位
String formatBudget(double amount) {
  if (amount < 1000) {
    return '¥${amount.toStringAsFixed(0)}';
  } else if (amount < 10000) {
    return '¥${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return '¥${(amount / 10000).toStringAsFixed(1)}万';
  }
} 