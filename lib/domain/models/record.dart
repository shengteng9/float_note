
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../utils/utils.dart';
part 'record.freezed.dart';

@freezed
abstract class Record with _$Record {
  const Record._();

  const factory Record({
    String? id,
    Map<String, dynamic>? processingResult,
    required String title,
    required String type,
    String? categoryId,
    required String category,
    List<Map<String, dynamic>>? rawInputs,
    Map<String, dynamic>? content,
    bool? isProcessed,
    DateTime? processedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? fileData,
    String? user,
  }) = _Record;

  bool get isCompleted => isProcessed == true && processingResult != null;

  String get updateDateDisplay =>
      createdAt != null ? Utils.formatDate(createdAt!, 'yyyy-MM-dd HH:mm') : '未知';

  bool get isDraft => type == 'draft';
}

