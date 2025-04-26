import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppTabBar extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final Function(String) onTabSelected;
  final double height;
  final double horizontalPadding;

  const AppTabBar({
    Key? key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    this.height = 42,
    this.horizontalPadding = 16,
  }) : super(key: key);

  // 预先定义好渐变颜色组合，避免重复计算
  static const List<List<Color>> _gradients = [
    [Color(0xFF4D79FF), Color(0xFF4D8AFF)], // 蓝色
    [Color(0xFF00B4D8), Color(0xFF9D4EDD)], // 蓝紫色
    [Color(0xFF9D4EDD), Color(0xFFEE52BC)], // 紫粉色
    [Color(0xFF00B4D8), Color(0xFF2EC4B6)], // 蓝青色
    [Color(0xFFFF9E00), Color(0xFFFF48C4)], // 橙粉色
    [Color(0xFF4D79FF), Color(0xFF7E6CCA)], // 蓝紫色
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.35),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        padding: const EdgeInsets.all(4),
        child: Row(
          children:
              tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final isSelected = tab == selectedTab;

                // 使用预定义的渐变色
                final gradientIndex = index % _gradients.length;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabSelected(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200), // 降低动画时间
                      curve: Curves.fastOutSlowIn, // 更高效的动画曲线
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected
                                ? LinearGradient(
                                  colors: _gradients[gradientIndex],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        color: isSelected ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: _gradients[gradientIndex][0]
                                        .withOpacity(0.25),
                                    blurRadius: 4, // 减少阴影模糊半径
                                    spreadRadius: 0,
                                    offset: const Offset(0, 1), // 减小阴影偏移
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              letterSpacing: isSelected ? 0.2 : 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
