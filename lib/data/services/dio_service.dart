import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:float_note/ui/core/providers/auth_provider.dart';

// 定义 Provider
final dioProvider = Provider<DioService>((ref) {
  return DioService(ref);
});

class DioService {
  final Dio _dio = Dio();
  // 根据不同平台设置不同的基础URL
  // Android模拟器使用10.0.2.2访问主机的localhost
  // 其他平台使用127.0.0.1
  final String _baseUrl = Platform.isAndroid 
    ? 'http://10.0.2.2:8000/api' 
    : 'http://127.0.0.1:8000/api';
  final Ref _ref;

  DioService(this._ref) {
    // 全局配置
    _dio.options = BaseOptions(
      baseUrl: _baseUrl, // 设置统一的 base URL
      connectTimeout: const Duration(minutes: 15),
      receiveTimeout: const Duration(minutes: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // 添加认证拦截器
    _dio.interceptors.add(AuthInterceptor(_ref, _dio));

    // 添加其他拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 检查网络连接
          final connectivityResult = await Connectivity().checkConnectivity();
          if (connectivityResult.contains(ConnectivityResult.none)) {
            debugPrint('没有网络连接');
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'No internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
          }

          // 请求数据日志
          if (options.data != null) {
            debugPrint('📦 Request Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
          // if (response.data != null) {
          //   debugPrint('📦 Response Data: ${response.data}');
          // }
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint('❌ Error: ${error.type} - ${error.message}');
          debugPrint('❌ Error URL: ${error.requestOptions.uri}');
          debugPrint('❌ Error Status: ${error.response?.statusCode}');
          // 统一错误处理
          final processedError = _handleError(error);
          // 重试逻辑（针对非401错误）
          if (_shouldRetry(error) && error.response?.statusCode != 401) {
            await Future.delayed(const Duration(seconds: 1));
            try {
              final retryResponse = await _dio.request(
                error.requestOptions.path,
                data: error.requestOptions.data,
                queryParameters: error.requestOptions.queryParameters,
                options: Options(
                  method: error.requestOptions.method,
                  headers: error.requestOptions.headers,
                ),
              );
              return handler.resolve(retryResponse);
            } catch (retryError) {
              print('重试失败$retryError');
              return handler.reject(processedError);
            }
          }

          return handler.reject(processedError);
        },
      ),
    );
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.response?.statusCode == 502 ||
           error.response?.statusCode == 503;
  }

  // 错误处理
  DioException _handleError(DioException error) {
    String errorMessage = 'An error occurred';
    print('异常处理${error.type}');
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'No internet connection';
        break;
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          errorMessage = 'Authentication failed';
        } else if (statusCode == 403) {
          errorMessage = 'Access denied';
        } else if (statusCode == 404) {
          errorMessage = 'Resource not found';
        } else if (statusCode == 500) {
          errorMessage = 'Server error';
        } else {
          errorMessage = 'Server error: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = error.message ?? 'Unknown error';
    }

    return DioException(
      requestOptions: error.requestOptions,
      error: errorMessage,
      response: error.response,
      type: error.type,
    );
  }

  // 封装 GET 请求
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParams,
      options: options,
    );
  }

  // 封装 POST 请求
  Future<Response<T>> post<T>(
    String path,
    {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    try {
      debugPrint('准备发送POST请求到: $path');
      debugPrint('请求数据: $data');
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
      );
      
      debugPrint('POST请求成功，状态码: ${response.statusCode}');
      debugPrint('响应数据: ${response.data}');
      
      return response;
    } catch (e) {
      if (e is DioException) {
        debugPrint('POST请求失败，类型: ${e.type}');
        debugPrint('错误状态码: ${e.response?.statusCode}');
        debugPrint('错误响应数据: ${e.response?.data}');
        debugPrint('错误消息: ${e.message}');
        debugPrint('请求URL: ${e.requestOptions.uri}');
      } else {
        debugPrint('POST请求发生非Dio异常: $e');
      }
      rethrow;
    }
  }

  // 封装 PUT 请求
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  // 封装 PATCH 请求
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  // 封装 DELETE 请求
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParams,
      options: options,
    );
  }

  // 下载文件
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
  }

  // 上传文件 - 通用方法
  Future<Response<T>> upload<T>(
    String path,
    dynamic data, {
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      onSendProgress: onSendProgress,
      options: options,
    );
  }

  // multipart/form-data 上传文件
  Future<Response<T>> uploadMultipartFormData<T>(
    String path, {
    required Map<String, dynamic> data,
    List< MultipartFile>? files,
    Map<String, dynamic>? queryParams,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    // 创建 FormData
    final formData = FormData.fromMap(data);

    // 添加文件到 FormData
    if (files != null) {
      for (final file in files) {
        formData.files.add(MapEntry('files', file));
      }
    }

    // 设置请求头为 multipart/form-data
    final requestOptions = options ?? Options();
    requestOptions.headers = {
      ...requestOptions.headers ?? {},
      'Content-Type': 'multipart/form-data',
    };

    return _dio.post<T>(
      path,
      data: formData,
      queryParameters: queryParams,
      onSendProgress: onSendProgress,
      options: requestOptions,
    );
  }

  // 上传单个文件的便捷方法
  Future<Response<T>> uploadSingleFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    String? fileName,
    Map<String, dynamic>? formData,
    Map<String, dynamic>? queryParams,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    // 创建文件名
    final actualFileName = fileName ?? filePath.split('/').last;

    // 在第278行附近
    // 创建 MultipartFile
    final multipartFile = await MultipartFile.fromFile(
      filePath,
      filename: actualFileName,
      contentType: null, // 暂时不设置contentType
    );
  
    // 准备表单数据
    final formDataMap = {...?formData, fieldName: multipartFile};

    return uploadMultipartFormData<T>(
      path,
      data: formDataMap,
      queryParams: queryParams,
      onSendProgress: onSendProgress,
      options: options,
    );
  }

  // 上传多个文件的便捷方法
  Future<Response<T>> uploadMultipleFiles<T>(
    String path,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? formData,
    Map<String, dynamic>? queryParams,
    ProgressCallback? onSendProgress,
    Options? options,
  }) async {
    // 创建多个 MultipartFile
    final multipartFiles = await Future.wait(
      filePaths.map((filePath) async {
        final fileName = filePath.split('/').last;
        return MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: null, // 暂时不设置contentType
        );
      }),
    );

    // 准备表单数据
    final formDataMap = {
      ...?formData,
      fieldName: multipartFiles,
    };

    return uploadMultipartFormData<T>(
      path,
      data: formDataMap,
      queryParams: queryParams,
      onSendProgress: onSendProgress,
      options: options,
    );
  }
}