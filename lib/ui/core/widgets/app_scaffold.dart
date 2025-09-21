import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bottom_nav.dart';
import '../../record/view_model/record_state_provider.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final bool showBottomNav;
  final Widget? drawer; // 允许传入自定义 Drawer
  final Widget? endDrawer; // 允许传入自定义 EndDrawer
  final PreferredSizeWidget? appBar; // 允许自定义 AppBar
  final Widget? floatingActionButton;
  final int? bottomNavIndex; // 新增：底部导航当前索引
  final ValueChanged<int>? onBottomNavTapped; // 新增：底部导航点击回调
  final VoidCallback? onHomeLongPress; // 新增：首页长按回调

  const AppScaffold({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.drawer,
    this.endDrawer,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavIndex,
    this.onBottomNavTapped,
    this.onHomeLongPress,
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  final PageStorageBucket _pageStorageBucket = PageStorageBucket(); // 添加页面存储

  @override
  void initState() {
    super.initState();
    // 移除路由相关的初始化代码
  }

  void _onHomeRefresh() {
    // 在首页时才刷新记录列表
    if (widget.bottomNavIndex == 0) {
      ref.read(recordsNotifierProvider.notifier).refresh();
    }
  }

  void checkFunPo () {
    debugPrint('appScaffold event listener');
  }

  // 默认 Drawer
  Widget _buildDefaultDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('默认抽屉菜单'),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('首页'),
            onTap: () {
              // 移除路由跳转，改为使用 PageView 导航
              if (widget.onBottomNavTapped != null) {
                widget.onBottomNavTapped!(0);
              }
              Navigator.pop(context);
            },
          ),
          // 更多默认菜单项...
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: _pageStorageBucket, // 使用 PageStorage 包装
      child: Scaffold(
        appBar: widget.appBar ?? AppBar(
          title: const Text('我的应用'),
          automaticallyImplyLeading: widget.drawer == null,
        ),
        // 使用页面自定义的 Drawer 或默认 Drawer
        drawer: widget.drawer ?? _buildDefaultDrawer(),
        endDrawer: widget.endDrawer,
        body: widget.child,
        floatingActionButton: widget.floatingActionButton,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: widget.showBottomNav
            ? BottomNavBar(
                currentTabIndex: widget.bottomNavIndex ?? 0,
                onItemSelected: widget.onBottomNavTapped,
                onHomeLongPress: widget.onHomeLongPress ?? _onHomeRefresh,
              )
            : null,
      ),
    );
  }
}