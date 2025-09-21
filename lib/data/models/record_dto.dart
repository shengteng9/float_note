// data/model/record_dto.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_dto.freezed.dart';
part 'record_dto.g.dart';

@freezed
abstract class RecordDto with _$RecordDto {
  const factory RecordDto({
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'processing_result') Map<String,dynamic>? processingResult,
    @JsonKey(name: 'title') String? title,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'category') String? category,
    @JsonKey(name: 'raw_inputs') List<Map<String, dynamic>>? rawInputs,
    @JsonKey(name: 'content') Map<String, dynamic>? content,
    @JsonKey(name: 'is_processed') bool? isProcessed,
    @JsonKey(name: 'processed_at') DateTime? processedAt,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'file_data') Map<String, dynamic>? fileData,
    @JsonKey(name: 'user') String? user,
  }) = _RecordDto;

  factory RecordDto.fromJson(Map<String, dynamic> json) => _$RecordDtoFromJson(json);
 
}