import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'package:flutter/rendering.dart'; // 必须添加这个导入

void main() {
    // 启用布局调试绘制（显示 widget 边界和尺寸）
  debugPaintSizeEnabled = false;
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}