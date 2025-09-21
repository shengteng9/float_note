import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dio_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final dioService = ref.watch(dioProvider);
  return SettingsService(dioService);
});

class SettingsService {
   final DioService dioService;

  SettingsService(this.dioService);

  Future<dynamic> feedback(Map<String, dynamic> data,) async {
    try {
      final response = await dioService.post(
        '/feedback/',
        data: data,
      );
  
      return response.data['data'];
    } on DioException catch (e) {
      rethrow;
    }
  }
}