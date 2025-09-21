import 'package:flutter/material.dart';

/// 全局导航服务类，用于集中管理导航状态和操作
class NavigationService {
  // 创建全局导航键
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// 获取当前导航上下文
  static BuildContext? get context => navigatorKey.currentContext;
  
  /// 获取导航状态
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  /// 检查上下文是否可用且已挂载
  static bool get isContextAvailable => context != null && context!.mounted;
}