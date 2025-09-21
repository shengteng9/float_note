import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart'; // 添加这个导入以使用debugPrint

import 'package:float_note/data/services/auth_service.dart'; // 假设 AuthService 是 @riverpod class

import 'package:float_note/ui/core/providers/auth_provider.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel {

  late final AuthService _authService;

  @override
  AsyncValue<Map<String, dynamic>?> build() {
    _authService = ref.watch(authServiceProvider);
    return const AsyncValue.data(null);
  }

  /// 登录方法
  Future<void> login(Map<String, dynamic> data) async {

    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async { 
      debugPrint('===登录请求数据:$data');
      final result = await _authService.login(data: data);
      debugPrint('===登录响应结果:$result');
      
      if (result.isNotEmpty) {
        final accessToken = result['access'];
        final refreshToken = result['refresh'];
        // 调用authProvider保存认证信息
        await ref.read(authProvider.notifier).login(accessToken, refreshToken);
      }
      return result;
    });
  }

  /// 重置状态
  void reset() {
    state = const AsyncValue.data(null);
  }
}