import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../ui/core/providers/app_providers.dart';
import '../ui/core/providers/auth_provider.dart';
import '../ui/core/screens/main_screen.dart';
import '../ui/login/widgets/login_screen.dart';
import '../ui/core/services/notification_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  // 使用静态实例确保只初始化一次
  static final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    // 初始化通知服务（使用then确保不会阻塞UI构建）
    _notificationService.initialize().then((_) {
      print('通知服务初始化完成');
    });
    
    return Consumer(
      builder: (context, ref, child) {
        final language = ref.watch(languageProvider);
        final authState = ref.watch(authProvider);
        
        return MaterialApp(
          home: _getHomeWidget(authState),
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: ref.watch(themeModeProvider),
          // 配置国际化
          locale: Locale(language),
          supportedLocales: const [
            Locale('zh'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
  
  /// 根据认证状态决定显示的页面
  Widget _getHomeWidget(AuthState authState) {
    // 如果需要登录或者未登录，显示登录页面
    if (authState.needsLogin || !authState.isLoggedIn) {
      return const LoginScreen();
    }
    
    // 否则显示主页面
    return const MainScreen();
  }
}