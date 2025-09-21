// auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import './dio_service.dart';

part 'auth_service.g.dart'; // 生成文件的引用

@riverpod
class AuthService extends _$AuthService {

  late final DioService _dioService;

  @override
  AuthService build() {
    // 获取依赖：dioService
    _dioService = ref.watch(dioProvider);
    return this;
  }

  // 你的业务方法
  Future<Map<String, dynamic>> login({required Map<String, dynamic> data}) async {
    try {
      final response = await _dioService.post('/token/', data: data);
      
      // 打印完整响应数据，以便更好地理解服务器返回的结构
      debugPrint('完整响应状态码: ${response.statusCode}');
      debugPrint('完整响应数据: ${response.data}');
      
      // 尝试不同的数据提取方式
      Map<String, dynamic> result;
      if (response.data is Map && response.data.containsKey('data')) {
        result = response.data['data'];
        debugPrint('从data字段提取结果: $result');
      } else if (response.data is Map) {
        result = response.data;
        debugPrint('直接使用响应数据作为结果: $result');
      } else {
        // 如果响应不是Map类型，创建一个包含原始数据的Map
        result = {'raw_data': response.data.toString()};
        debugPrint('响应数据不是Map类型: ${response.data.runtimeType}');
      }
      
      return result;
    } on DioException catch (e) {
      // 打印详细的错误信息
      debugPrint('登录请求失败: ${e.type}');
      debugPrint('错误响应状态码: ${e.response?.statusCode}');
      debugPrint('错误响应数据: ${e.response?.data}');
      
      throw AuthServiceException(
        message: e.message ?? 'Failed to login',
        statusCode: e.response?.statusCode,
      );
    }
  }
}

class AuthServiceException implements Exception {
  final String message;
  final int? statusCode;
  AuthServiceException({required this.message, this.statusCode});
}