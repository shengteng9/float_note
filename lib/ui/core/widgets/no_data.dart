import 'package:flutter/material.dart';

class NoDataWidget extends StatelessWidget {
  final VoidCallback? onAddTap;
  final String? message;

  const NoDataWidget({
    super.key,
    this.onAddTap,
    this.message = '暂无数据',
  });

  @override
  Widget build(BuildContext context) {
    return Column(   
        children: [
          // 无数据图标
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          // 提示文本
          Text(
            message ?? '暂无数据', 
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      
    );
  }
}