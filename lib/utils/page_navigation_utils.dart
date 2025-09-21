import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/core/services/page_navigation_service.dart';

/// PageView 导航工具类
class PageViewNavigationUtils {
  
  /// 在任意页面中跳转到指定 tab
  static void jumpToPage(int index, {bool animate = true}) {
    PageViewNavigationService.instance.jumpToPage(index, animate: animate);
  }
  
  /// 快捷跳转方法
  static void jumpToHome({bool animate = true}) {
    PageViewNavigationService.instance.jumpToHome(animate: animate);
  }
  
  static void jumpToSearch({bool animate = true}) {
    PageViewNavigationService.instance.jumpToSearch(animate: animate);
  }
  
  static void jumpToSettings({bool animate = true}) {
    PageViewNavigationService.instance.jumpToSettings(animate: animate);
  }
  
  /// 使用枚举跳转
  static void jumpToPageByEnum(MainPageIndex page, {bool animate = true}) {
    PageViewNavigationService.instance.jumpToPage(page.value, animate: animate);
  }
}

/// 带导航功能的示例 Widget
class NavigationExampleWidget extends ConsumerWidget {
  const NavigationExampleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(pageViewNavigationProvider);
    final currentPage = MainPageIndex.values[currentIndex];
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PageView 导航示例',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('当前页面: ${currentPage.title}'),
            const SizedBox(height: 16),
            
            // 快捷跳转按钮
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => PageViewNavigationUtils.jumpToHome(),
                  child: const Text('跳转到首页'),
                ),
                ElevatedButton(
                  onPressed: () => PageViewNavigationUtils.jumpToSearch(),
                  child: const Text('跳转到搜索'),
                ),
                ElevatedButton(
                  onPressed: () => PageViewNavigationUtils.jumpToSettings(),
                  child: const Text('跳转到设置'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 无动画跳转
            Wrap(
              spacing: 8,
              children: [
                TextButton(
                  onPressed: () => PageViewNavigationUtils.jumpToHome(animate: false),
                  child: const Text('无动画跳转首页'),
                ),
                TextButton(
                  onPressed: () => PageViewNavigationUtils.jumpToSearch(animate: false),
                  child: const Text('无动画跳转search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 扩展方法 - 为 WidgetRef 添加导航快捷方法
extension PageViewNavigationExtension on WidgetRef {
  /// 跳转到指定页面
  void jumpToPage(int index, {bool animate = true}) {
    read(pageViewNavigationServiceProvider).jumpToPage(index, animate: animate);
  }
  
  /// 跳转到首页
  void jumpToHome({bool animate = true}) {
    read(pageViewNavigationServiceProvider).jumpToHome(animate: animate);
  }
  
  void jumpToSearch({bool animate = true}) {
    read(pageViewNavigationServiceProvider).jumpToSearch(animate: animate);
  }
  
  /// 跳转到设置页面
  void jumpToSettings({bool animate = true}) {
    read(pageViewNavigationServiceProvider).jumpToSettings(animate: animate);
  }
}