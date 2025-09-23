import 'package:flutter/material.dart';

/// 应用级导航服务，用于纯 PageView 导航方案
class AppNavigationService {
  static AppNavigationService? _instance;
  static AppNavigationService get instance {
    _instance ??= AppNavigationService._();
    return _instance!;
  }
  
  AppNavigationService._();

  /// MainScreen 实例的引用
  GlobalKey<State>? _mainScreenKey;
  
  /// 注册 MainScreen 实例
  void registerMainScreen(GlobalKey<State> key) {
    _mainScreenKey = key;
  }
  
  /// 注销 MainScreen 实例
  void unregisterMainScreen() {
    _mainScreenKey = null;
  }
  
  /// 跳转到底部导航页面
  void jumpToTab(int index, {bool animate = true}) {
    (_mainScreenKey?.currentState as dynamic)?.jumpToPage(index, animate: animate);
  }
  
  /// 跳转到其他页面（非底部导航）
  void navigateToPage(Widget page) {
    (_mainScreenKey?.currentState as dynamic)?.navigateToPage(page);
  }
  
  /// 跳转到记录页面
  void navigateToRecords() {
    (_mainScreenKey?.currentState as dynamic)?.navigateToRecords();
  }
  
  /// 跳转到登录页面
  void navigateToLogin() {
    (_mainScreenKey?.currentState as dynamic)?.navigateToLogin();
  }
  
  /// 返回上一页
  bool popPage() {
    return (_mainScreenKey?.currentState as dynamic)?._popPage() ?? false;
  }
  
  /// 快捷方法
  void jumpToHome({bool animate = true}) => jumpToTab(0, animate: animate);
  void jumpToSearch({bool animate = true}) => jumpToTab(1, animate: animate);
  void jumpToSettings({bool animate = true}) => jumpToTab(2, animate: animate);
}

/// Provider 扩展，方便在组件中使用
extension AppNavigationExtension on BuildContext {
  AppNavigationService get navigator => AppNavigationService.instance;
}