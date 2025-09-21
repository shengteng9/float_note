// data/repository/record_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/core/failures.dart';
import '../../domain/models/record.dart';
import '../services/record_service.dart';
import '../mapper/record_mapper.dart';

abstract class RecordRepository {
  Future<Either<Failure, List<Record>>> getRecords([dynamic data]);
  Future<Either<Failure, Record>> getRecordById(String id);
  Future<Either<Failure, Record>> createRecord(Map<String, dynamic> data, [List<MultipartFile>? files]);
  Future<Either<Failure, Record>> updateRecord(Record record);
  Future<Either<Failure, Unit>> deleteRecord(String id);
  Future<Either<Failure, List<Record>>> getDraftRecords();
  Future<Either<Failure, List<Record>>> getProcessedRecords();
}

class RecordRepositoryImpl implements RecordRepository {
  final RecordService recordService;
  final RecordMapper mapper;

  RecordRepositoryImpl({
    required this.recordService,
    required this.mapper,
  });

  @override
  Future<Either<Failure, List<Record>>> getRecords([dynamic params]) async {
    try {
      final recordsDto = await recordService.getRecords(params);
      final records = recordsDto.map(mapper.toDomain).toList();
      return Right(records);
    } on RecordServiceException catch (e) {
      return Left(_handleServiceException(e));
    } catch (e) {
      print('Error in getRecords: $e');
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Record>> getRecordById(String id) async {
    try {
      final recordDto = await recordService.getRecordById(id);
      final record = mapper.toDomain(recordDto);
      return Right(record);
    } on RecordServiceException catch (e) {
      return Left(_handleServiceException(e));
    } catch (e) {
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Record>> createRecord(Map<String, dynamic> data, [List<MultipartFile>? files]) async {
    try {
      final createdRecordDto = await recordService.createRecord(data, files);
      final createdRecord = mapper.toDomain(createdRecordDto);
      return Right(createdRecord);
    } on RecordServiceException catch (e) {
      
      return Left(_handleServiceException(e));
    } catch (e) {
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Record>> updateRecord(Record record) async {
    try {
      final recordDto = mapper.toDto(record);
      final updatedRecordDto = await recordService.updateRecord(recordDto);
      final updatedRecord = mapper.toDomain(updatedRecordDto);
      return Right(updatedRecord);
    } on RecordServiceException catch (e) {
      return Left(_handleServiceException(e));
    } catch (e) {
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteRecord(String id) async {
    try {
      await recordService.deleteRecord(id);
      return const Right(unit);
    } on RecordServiceException catch (e) {
      return Left(_handleServiceException(e));
    } catch (e) {
      return Left(const UnexpectedFailure(message: 'Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<Record>>> getDraftRecords() async {
    final result = await getRecords();
    return result.fold(
      Left.new,
      (records) => Right(records.where((r) => r.isDraft).toList()),
    );
  }

  @override
  Future<Either<Failure, List<Record>>> getProcessedRecords() async {
    final result = await getRecords();
    return result.fold(
      Left.new,
      (records) => Right(records.where((r) => r.isCompleted).toList()),
    );
  }

  Failure _handleServiceException(RecordServiceException e) {
    switch (e.statusCode) {
      case 401:
        return UnauthorizedFailure(message: e.message);
      case 403:
        return const UnauthorizedFailure(message: 'Access denied');
      case 404:
        return NotFoundFailure(message: e.message);
      case 422:
        return ValidationFailure(message: e.message);
      case 500:
        return ServerFailure(message: e.message, statusCode: e.statusCode);
      default:
        return ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }
}