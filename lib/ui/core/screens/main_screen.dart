import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_scaffold.dart';
import '../services/page_navigation_service.dart';
import '../../home/widgets/home_screen.dart';
import '../../home/widgets/app_bar_title.dart';
import '../../record/widgets/record_add/add_record_button.dart';
import '../../search/widgets/search_screen.dart';
import '../../profile/widgets/settings_screen.dart';
import '../../record/widgets/record_screen.dart';
import '../../login/widgets/login_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  
  // 页面栈管理，用于支持跳转到其他页面
  final List<Widget> _pageStack = [];
  bool _isInSubPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    
    // 注册全局导航回调
    PageViewNavigationService.instance.registerJumpCallback(jumpToPage);
  }

  @override
  void dispose() {
    // 注销全局导航回调
    PageViewNavigationService.instance.unregisterJumpCallback();
    _pageController.dispose();
    super.dispose();
  }

  /// 编程式跳转到指定页面（带动画）
  void jumpToPage(int index, {bool animate = true}) {
    if (index < 0 || index >= 3) return; // 防止越界
    
    // 如果当前在子页面，先返回主页面
    if (_isInSubPage) {
      _popToMainPages();
    }
    
    setState(() => _currentIndex = index);
    
    // 同步更新状态管理
    ref.read(pageViewNavigationProvider.notifier).setCurrentIndex(index);
    
    if (animate) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.jumpToPage(index);
    }
  }
  
  /// 跳转到其他页面（非底部导航页面）
  void navigateToPage(Widget page) {
    setState(() {
      _pageStack.add(page);
      _isInSubPage = true;
    });
  }
  
  /// 返回到主页面
  void _popToMainPages() {
    setState(() {
      _pageStack.clear();
      _isInSubPage = false;
    });
  }
  
  /// 返回上一个页面
  bool _popPage() {
    if (_pageStack.isNotEmpty) {
      setState(() {
        _pageStack.removeLast();
        if (_pageStack.isEmpty) {
          _isInSubPage = false;
        }
      });
      return true;
    }
    return false;
  }

  /// 跳转到首页
  void jumpToHome({bool animate = true}) => jumpToPage(0, animate: animate);
  
  void jumpToSearch({bool animate = true}) => jumpToPage(1, animate: animate);
  
  /// 跳转到设置页面
  void jumpToSettings({bool animate = true}) => jumpToPage(2, animate: animate);

  /// 底部导航点击事件
  void _onItemTapped(int index) {
    jumpToPage(index, animate: true);
  }

  /// 首页长按刷新事件
  void _onHomeRefresh() {
    // 只有在首页时才刷新
    if (_currentIndex == 0) {
      // 这里可以添加首页特有的刷新逻辑
      // 例如，如果首页有特定的刷新需求
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 处理物理返回键
        return !_popPage();
      },
      child: AppScaffold(
        showBottomNav: !_isInSubPage, // 在子页面隐藏底部导航
        appBar: _buildAppBar(),
        floatingActionButton: (!_isInSubPage && _currentIndex == 0) ? const AddRecordButton() : null,
        bottomNavIndex: _currentIndex,
        onBottomNavTapped: _onItemTapped,
        onHomeLongPress: _onHomeRefresh,
        child: _isInSubPage 
            ? _pageStack.last // 显示当前子页面
            : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: const [
                  HomeScreen(),
                  SearchScreen(),
                  SettingsScreen(),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_isInSubPage) {
      return AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _popPage,
        ),
        title: const Text('详情页面'), // 可以根据具体页面动态设置
      );
    }
    
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: _getAppBarTitle(),
    );
  }
  
  Widget _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return const AppBarTitle(); // 使用首页的原有标题
      case 1:
        return const Text('搜索');
      case 2:
        return const Text('设置');
      default:
        return const AppBarTitle();
    }
  }
  
  // 提供全局导航方法，供其他组件使用
  void navigateToRecords() {
    navigateToPage(const RecordScreen());
  }
  
  void navigateToLogin() {
    navigateToPage(const LoginScreen());
  }
}