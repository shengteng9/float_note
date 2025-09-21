// data/mapper/record_mapper.dart
import '../../domain/models/record.dart';
import '../models/record_dto.dart';

class RecordMapper {
  Record toDomain(RecordDto dto) {
    return Record(
      id: dto.id ?? '',
      processingResult: dto.processingResult,
      title: dto.title ?? '',
      type: dto.type ?? '',
      categoryId: dto.categoryId ?? '',
      category: dto.category ?? '',
      rawInputs: dto.rawInputs ?? [],
      content: dto.content,
      isProcessed: dto.isProcessed,
      processedAt: dto.processedAt ,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      fileData: dto.fileData,
      user: dto.user,
    );
  }

  RecordDto toDto(Record record) {
    return RecordDto(
      id: record.id,
      processingResult: record.processingResult,
      title: record.title,
      type: record.type,
      categoryId: record.categoryId,
      category: record.category,
      rawInputs: record.rawInputs,
      content: record.content,
      isProcessed: record.isProcessed,
      processedAt: record.processedAt,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      fileData: record.fileData,
      user: record.user,
    );
  }
}