import 'package:dio/dio.dart';
import '../models/record_dto.dart';
import '../services/dio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recordServiceProvider = Provider<RecordService>((ref) {
  final dioService = ref.watch(dioProvider);
  return RecordService(dioService: dioService);
});

class RecordServiceException implements Exception {
  final String message;
  final int? statusCode;

  RecordServiceException({required this.message, this.statusCode});
}

class RecordService {
  final DioService dioService;

  RecordService({required this.dioService});

  Future<List<RecordDto>> getRecords([dynamic params]) async {
    try {
      final response = await dioService.get(
        '/records',
        queryParams: params != null ? Map<String, dynamic>.from(params) : null,
      );
      final List<dynamic> recordsData = response.data['data'];
      return recordsData.map((json) => RecordDto.fromJson(json)).toList();
    } on DioException catch (e) {
      throw RecordServiceException(
        message: e.message ?? 'Failed to get records',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<RecordDto> getRecordById(String id) async {
    try {
      final response = await dioService.get('/records/$id/');
      return RecordDto.fromJson(response.data);
    } on DioException catch (e) {
      throw RecordServiceException(
        message: e.message ?? 'Failed to get record',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<RecordDto> createRecord(Map<String, dynamic> data, [List<MultipartFile>? files]) async {
    try {
      final response = await dioService.uploadMultipartFormData(
        '/records/',
        data: data,
        files: files,
      );
  
      return RecordDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw RecordServiceException(
        message: e.message ?? 'Failed to create record',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<RecordDto> updateRecord(RecordDto record) async {
    try {
      final response = await dioService.patch(
        '/records/${record.id}/',
        data: record.toJson(),
      );
      return RecordDto.fromJson(response.data);
    } on DioException catch (e) {
      throw RecordServiceException(
        message: e.message ?? 'Failed to update record',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<void> deleteRecord(String id) async {
    try {
      await dioService.delete('/records/${id}/');
    } on DioException catch (e) {
      throw RecordServiceException(
        message: e.message ?? 'Failed to delete record',
        statusCode: e.response?.statusCode,
      );
    }
  }
}