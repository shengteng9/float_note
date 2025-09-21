import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PageView 导航服务
class PageViewNavigationService {
  static PageViewNavigationService? _instance;
  static PageViewNavigationService get instance {
    _instance ??= PageViewNavigationService._();
    return _instance!;
  }
  
  PageViewNavigationService._();

  /// MainScreen 的跳转回调函数
  void Function(int index, {bool animate})? _jumpToPageCallback;
  
  /// 注册跳转回调（由 MainScreen 调用）
  void registerJumpCallback(void Function(int index, {bool animate}) callback) {
    _jumpToPageCallback = callback;
  }
  
  /// 注销跳转回调
  void unregisterJumpCallback() {
    _jumpToPageCallback = null;
  }
  
  /// 编程式跳转到指定页面
  void jumpToPage(int index, {bool animate = true}) {
    _jumpToPageCallback?.call(index, animate: animate);
  }
  
  /// 跳转到首页
  void jumpToHome({bool animate = true}) => jumpToPage(0, animate: animate);
  
  void jumpToSearch({bool animate = true}) => jumpToPage(1, animate: animate);
  
  /// 跳转到设置页面
  void jumpToSettings({bool animate = true}) => jumpToPage(2, animate: animate);
}

/// 页面索引枚举
enum MainPageIndex {
  home(0, '首页'),
  todo(1, '搜索'),
  settings(2, '设置');
  
  const MainPageIndex(this.value, this.title);
  
  final int value;
  final String title;
}

/// PageView 导航状态管理
class PageViewNavigationNotifier extends StateNotifier<int> {
  PageViewNavigationNotifier() : super(0);
  
  void setCurrentIndex(int index) {
    if (index >= 0 && index < 3) {
      state = index;
    }
  }
  
  int get currentIndex => state;
  MainPageIndex get currentPage => MainPageIndex.values[state];
}

/// Provider 定义
final pageViewNavigationProvider = StateNotifierProvider<PageViewNavigationNotifier, int>((ref) {
  return PageViewNavigationNotifier();
});

/// 获取导航服务的 Provider
final pageViewNavigationServiceProvider = Provider<PageViewNavigationService>((ref) {
  return PageViewNavigationService.instance;
});