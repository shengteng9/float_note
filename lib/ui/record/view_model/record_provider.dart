import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/services/record_service.dart';
import '../../../../data/repositories/record_repository.dart';
import '../../../../data/mapper/record_mapper.dart';

part 'record_provider.g.dart';


@riverpod
RecordMapper recordMapper(Ref ref) {
  return RecordMapper();
}

@riverpod
RecordRepository recordRepository(Ref ref) {
  final service = ref.watch(recordServiceProvider);
  final mapper = ref.watch(recordMapperProvider);
  return RecordRepositoryImpl(recordService: service, mapper: mapper);
}

