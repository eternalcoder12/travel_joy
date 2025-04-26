import 'package:flutter/material.dart';

class ExchangeRecord {
  final String id;
  final String itemName; // 兑换商品名称
  final String itemImagePath; // 商品图片路径
  final int pointsSpent; // 消耗的积分
  final DateTime exchangeDate; // 兑换日期
  final String exchangeCode; // 兑换码
  final ExchangeStatus status; // 兑换状态
  final String? remarks; // 备注信息

  ExchangeRecord({
    required this.id,
    required this.itemName,
    required this.itemImagePath,
    required this.pointsSpent,
    required this.exchangeDate,
    required this.exchangeCode,
    required this.status,
    this.remarks,
  });
}

// 兑换状态枚举
enum ExchangeStatus {
  success(value: '兑换成功', color: Colors.green),
  pending(value: '处理中', color: Colors.orange),
  expired(value: '已过期', color: Colors.grey),
  used(value: '已使用', color: Colors.blue);

  final String value;
  final Color color;

  const ExchangeStatus({required this.value, required this.color});
}
