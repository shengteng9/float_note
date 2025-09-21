// lib/widgets/bottom_nav.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentTabIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onHomeLongPress;

  const BottomNavBar({
    super.key,
    required this.currentTabIndex,
    this.onItemSelected,
    this.onHomeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTabIndex,
      onTap: (index) {
        // 如果点击的是当前正在显示的首页tab，触发刷新
        if (index == 0 && currentTabIndex == 0 && onHomeLongPress != null) {
          onHomeLongPress!();
        } else if (onItemSelected != null) {
          onItemSelected!(index);
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: GestureDetector(
            onLongPress: onHomeLongPress,
            child: const Icon(Icons.home),
          ),
          label: '首页',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '搜索',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '我的',
        ),
      ],
    );
  }
}