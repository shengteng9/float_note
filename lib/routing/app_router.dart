import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../ui/search/widgets/search_screen.dart';
import '../ui/profile/widgets/settings_screen.dart';
import '../../ui/core/screens/main_screen.dart';
import '../../ui/login/widgets/login_screen.dart';
import 'package:float_note/ui/record/widgets/record_screen.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref, GlobalKey<NavigatorState> navigatorKey) {
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: [
            GoRoute(
              path: '/records', 
              builder: (_, _) => const RecordScreen(),
              // 移除页面级的Scaffold（如果有）
              pageBuilder: (_, state) => NoTransitionPage(
                child: RecordScreen(),
              ),
            ),
        
            GoRoute(
              path: '/', 
              builder: (_, _) => const MainScreen(),
              pageBuilder: (_, state) => NoTransitionPage(
                child: MainScreen(),
              ),
            ),
            // 单独页面路由（不使用底部导航）
            GoRoute(
              path: '/search_standalone', 
              builder: (_, _) => const SearchScreen(),
              pageBuilder: (_, state) => NoTransitionPage(
                child: SearchScreen(),
              ),
            ),
            GoRoute(
              path: '/settings_standalone', 
              builder: (_, _) => const SettingsScreen(),
              pageBuilder: (_, state) => NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
            // 其他路由同理...
            
        // 独立路由保持不变
        GoRoute(
          path: '/login',
          pageBuilder: (_, _) => const MaterialPage(child: LoginScreen()),
        ),
      ],
    );
  }
}
