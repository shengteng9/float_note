import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:float_note/data/services/secure_storage_service.dart';
import 'package:float_note/domain/models/user.dart';
import 'package:float_note/data/services/dio_service.dart';
import 'package:flutter/foundation.dart'; // 添加这个导入以使用debugPrint

// 创建SecureStorageService的Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// 认证状态类
class AuthState {
  final User? user;
  final bool isLoggedIn;
  final String? errorMessage;
  final bool needsLogin; // 新增：标识是否需要跳转到登录页面

  const AuthState({
    this.user,
    this.isLoggedIn = false,
    this.errorMessage,
    this.needsLogin = false,
  });

  AuthState copyWith({
    User? Function()? user,
    bool? isLoggedIn,
    String? errorMessage,
    bool? needsLogin,
  }) {
    return AuthState(
      user: user != null ? user() : this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: errorMessage,
      needsLogin: needsLogin ?? this.needsLogin,
    );
  }
}

// 认证Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    // 初始化时检查登录状态
    checkLoginStatus();
  }

  // 检查登录状态
  Future<void> checkLoginStatus() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final isLoggedIn = await secureStorage.isLoggedIn();
      final token = await secureStorage.getToken();

      if (isLoggedIn && token != null) {
        // 从存储中恢复用户信息
        final userId = await secureStorage.getUserId();
        final userName = await secureStorage.getUserName();
        final refreshToken = await secureStorage.getRefreshToken();
        final avator = await secureStorage.getAvator();

        if (userId != null && userName != null && refreshToken != null) {
          state = state.copyWith(
            user: () => User(
              userId: userId,
              userName: userName,
              accessToken: token,
              refreshToken: refreshToken,
              avator: avator,
            ),
            isLoggedIn: true,
            needsLogin: false,
          );
        } else {
          // 用户信息不完整，需要重新登录
          state = state.copyWith(
            isLoggedIn: false,
            needsLogin: true,
          );
        }
      } else {
        // Token为null或未登录，需要跳转到登录页面
        state = state.copyWith(
          isLoggedIn: false,
          needsLogin: true,
        );
      }
    } catch (e) {
      debugPrint('Error checking login status: $e');
      state = state.copyWith(
        errorMessage: '检查登录状态失败',
        isLoggedIn: false,
        needsLogin: true,
      );
    }
  }

  // 登录方法
  Future<void> login( String accessToken, String refreshToken, {String? avator, String?userId, String?userName,}) async {
    try {
      state = state.copyWith(errorMessage: null);
      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.saveUserAuthData(
        token: accessToken,
        refreshToken: refreshToken,
        userId: userId ?? '',
        userName: userName ?? '',
        avator: avator,
      );

      state = state.copyWith(
        user: () => User(
          userId: userId ?? '',
          userName: userName ?? '',
          accessToken: accessToken,
          refreshToken: refreshToken,
          avator: avator,
        ),
        isLoggedIn: true,
        needsLogin: false, // 登录成功后清除需要登录的标志
      );
    } catch (e) {
      debugPrint('Login error: $e');
      state = state.copyWith(
        errorMessage: '登录失败：${e.toString()}',
        needsLogin: true,
      );
    }
  }

  // 登出方法
  Future<void> logout() async {
    try {
      state = state.copyWith(errorMessage: null);

      final secureStorage = ref.read(secureStorageProvider);
      await secureStorage.clearAuthData();
      // todo 刷新token
      state = const AuthState(isLoggedIn: false, needsLogin: true);
    } catch (e) {
      debugPrint('Logout error: $e');
      state = state.copyWith(
        errorMessage: 'Logout failed',
        needsLogin: true,
      );
    }
  }

  // 刷新Token
  Future<bool> refreshToken() async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final refreshToken = await secureStorage.getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      // 调用刷新Token的API
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}), // 不使用现有token
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;

        // 保存新的Token
        await secureStorage.saveToken(newAccessToken);
        await secureStorage.saveRefreshToken(newRefreshToken);

        // 更新用户信息
        if (state.user != null) {
          state = state.copyWith(
            user: () => state.user!.copyWith(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            ),
          );
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }
}

// 认证Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// 认证拦截器，用于处理Token的添加和刷新
class AuthInterceptor extends Interceptor {
  final Ref ref;
  final Dio dio;

  AuthInterceptor(this.ref, this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 检查是否需要认证
    if (!_shouldSkipAuth(options.path)) {
      final secureStorage = ref.read(secureStorageProvider);
      final token = await secureStorage.getToken();
      print('current token: $token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        // Token为null，触发需要登录的状态
        final authNotifier = ref.read(authProvider.notifier);
        authNotifier.logout();
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理401错误
    if (err.response?.statusCode == 401) {
      print('是否是401的异常');
      final authNotifier = ref.read(authProvider.notifier);
      final originalRequest = err.requestOptions;

      // 尝试刷新Token
      final refreshSuccess = await authNotifier.refreshToken();

      if (refreshSuccess) {
        // 刷新成功后，获取新的Token并重试请求
        final secureStorage = ref.read(secureStorageProvider);
        final newToken = await secureStorage.getToken();

        if (newToken != null) {
          // 克隆原始请求并更新Token
          final retryOptions = originalRequest.copyWith(
            headers: {...originalRequest.headers, 'Authorization': 'Bearer $newToken'},
          );

          try {
            // 重试请求
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          } catch (retryError) {
            // 重试失败，将错误传递给下一个拦截器
            return handler.next(err);
          }
        }
      }

      // 刷新失败，跳转到登录页面
      await authNotifier.logout();
    }

    return handler.next(err);
  }

  // 判断是否需要跳过认证（例如登录、注册等接口）
  bool _shouldSkipAuth(String path) {
    final noAuthPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/token',
      // 可以添加其他不需要认证的路径
    ];

    return noAuthPaths.any((noAuthPath) => path.contains(noAuthPath));
  }


}