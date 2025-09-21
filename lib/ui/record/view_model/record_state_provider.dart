
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/record.dart';
import 'record_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart'; 
import '../../../utils/utils.dart';
import 'package:dio/dio.dart';
import '../../core/providers/calendar_provider.dart';

part 'record_state_provider.freezed.dart';
part 'record_state_provider.g.dart';


@freezed
abstract class RecordEditState with _$RecordEditState {
  const factory RecordEditState({
    @Default(false) bool isEditing,
    @Default('') String title,
    @Default('') String summary,
    @Default('') String detail,
    @Default('') String status,
    @Default(0.0) double amount,
    @Default('') String amountFrom,
    @Default('') String amountTo,
    @Default('') String transactionType,
    DateTime? transactionDate,
    DateTime? dueDate,
    @Default(<dynamic>[]) List<dynamic> tags,
    @Default(<dynamic>[]) List<dynamic> tasks,
    @Default('') String sourceType,
    @Default('') String sourceName,
    @Default('') String sourceUrl,
    @Default(false) bool needReminder,
    DateTime? reminderAt,
  }) = _RecordEditState;

  factory RecordEditState.fromJson(Map<String, Object?> json) => _$RecordEditStateFromJson(json);
}


@riverpod
class RecordEditStateNotifier extends _$RecordEditStateNotifier {

  /// 创建初始记录编辑状态
  /// [record] 如果为null，创建新建状态；否则基于已有记录创建编辑状态
  RecordEditState _createInitialState([Record? record]) {
    if (record == null) {
      return const RecordEditState(isEditing: true);
    }
    
    // 当有record时，基于record的数据创建状态
    final content = record.content as Map<String, dynamic>;
    return RecordEditState(
      isEditing: false,
      title: content['title'] ?? '',
      summary: content['summary'] ?? '',
      detail: content['detail'] ?? '',
      status: content['status'] ?? '',
      amount: content['amount'] ?? 0, 
      amountFrom: content['amount_from'] ?? '',
      amountTo: content['amount_to'] ?? '',
      transactionType: content['transaction_type'] ?? '',
      transactionDate: content['transaction_date'] != null ? DateTime.parse(content['transaction_date']) : null,
      dueDate: content['due_date'] != null ? DateTime.parse(content['due_date']) : null,
      tags: content['tags'] ?? [],
      tasks: content['tasks'] ?? [],
      sourceType: content['source_type'] ?? '',
      sourceName: content['source_name'] ?? '',
      sourceUrl: content['source_url'] ?? '',
      needReminder: content['need_reminder'] ?? false,
      reminderAt: content['reminder_at'] != null ? DateTime.parse(content['reminder_at']) : null,
    );
  }

  @override
  AsyncValue<RecordEditState> build([Record? record]) {
    final initialState = _createInitialState(record);
    return AsyncValue.data(initialState);
  }

  void toggleEditing() {
    state = state.whenData((value) => value.copyWith(isEditing: !value.isEditing));
  }

  /// 重置记录编辑状态到初始状态
  void resetState([Record? record]) {
    final initialState = _createInitialState(record);
    state = AsyncValue.data(initialState);
  }
  // 根据form中的值更新state
  void updateRecordEntity({
    String? title,
    String? summary,
    String? detail,
    String? status,
    double? amount,
    String? amountFrom,
    String? amountTo,
    String? transactionType,
    DateTime? transactionDate,
    DateTime? dueDate,
    List<dynamic>? tags,
    List<dynamic>? tasks,
    String? sourceType,
    String? sourceName,
    String? sourceUrl,
    bool? needReminder,
    DateTime? reminderAt,
  }) {
    final currentState = state.value;
    if (currentState == null) return;
 
    // 使用 copyWith 方法创建新的状态对象，只更新提供的字段
    final updatedState = currentState.copyWith(
      title: title ?? currentState.title,
      summary: summary ?? currentState.summary,
      detail: detail ?? currentState.detail,
      status: status ?? currentState.status,
      amount: amount ?? currentState.amount,
      amountFrom: amountFrom ?? currentState.amountFrom,
      amountTo: amountTo ?? currentState.amountTo,
      transactionType: transactionType ?? currentState.transactionType,
      transactionDate: transactionDate ?? currentState.transactionDate,
      dueDate: dueDate ?? currentState.dueDate,
      tags: tags ?? currentState.tags,
      tasks: tasks ?? currentState.tasks,
      sourceType: sourceType ?? currentState.sourceType,
      sourceName: sourceName ?? currentState.sourceName,
      sourceUrl: sourceUrl ?? currentState.sourceUrl,
      needReminder: needReminder ?? currentState.needReminder,
      reminderAt: reminderAt ?? currentState.reminderAt,
    );
    
    // 更新状态
    state = AsyncValue.data(updatedState);
  }

  // 更新 record 的方法
  Future<void> editRecordByForm(Record record) async {
    final currentState = state.value;
    if (currentState == null) return;
  
    final currentStateKeys = currentState.toJson().keys.toList(); 
    final mutableRecordContent = Map<String, dynamic>.from(record.content as Map<String, dynamic>);
  
    var recordContentKeys = mutableRecordContent.keys.toList();
    for (var recordContentKey in recordContentKeys) {
      var convertedKey = Utils.convertIfSnake(recordContentKey);
      if (currentStateKeys.contains(convertedKey)) {
        mutableRecordContent[recordContentKey] = currentState.toJson()[convertedKey];
      }
    }
    // 如果需要，可以创建一个新的 Record 对象
    final updateRecord = record.copyWith(
      content: mutableRecordContent,
    );

    final repository = ref.watch(recordRepositoryProvider);
    final result = await repository.updateRecord(updateRecord);
    result.fold(
      (failure) => throw failure,
      (updatedRecord) {
        // 更新单个记录状态
        final initialState = _createInitialState(updatedRecord);
        state = AsyncValue.data(initialState);
        ref.read(recordsNotifierProvider.notifier).updateRecordInList(updatedRecord);
      },
    );
  }
}

class RecordsNotifier extends StateNotifier<AsyncValue<List<Record>>> {
  final Ref ref;
  bool _hasInitialized = false;
  
  RecordsNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initializeIfNeeded();
  }
  
  void _initializeIfNeeded() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      loadRecords({'created_at': Utils.formatDate(DateTime.now(), 'yyyy-MM-dd')});
    }
  }
  
  Future<void> loadRecords([dynamic params]) async {

    state = const AsyncValue.loading();
    final repository = ref.watch(recordRepositoryProvider);

    final result = await repository.getRecords(params);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (records) => state = AsyncValue.data(records),
    );
  }
  
  Future<void> refresh() async {

    ref.watch(calendarProvider).selectedDay;
    await loadRecords({'created_at': Utils.formatDate(ref.watch(calendarProvider).selectedDay, 'yyyy-MM-dd')});
  }
  
  Future<void> addRecord(Map<String, dynamic> data, List<MultipartFile>? files) async {
    final repository = ref.watch(recordRepositoryProvider);
    final result = await repository.createRecord(data, files);
    result.fold(
      (failure) => throw failure,
      (newRecord) {
        if (state is AsyncData<List<Record>>) {
          final currentRecords = (state as AsyncData<List<Record>>).value;
          state = AsyncValue.data([newRecord, ...currentRecords]);
        } 
      },
    );
  }
  
  Future<void> deleteRecord(String id) async {
    final repository = ref.watch(recordRepositoryProvider);
    final result = await repository.deleteRecord(id);
    result.fold(
      (failure) => throw failure,
      (_) {
        if (state is AsyncData<List<Record>>) {
          final currentRecords = (state as AsyncData<List<Record>>).value;
          state = AsyncValue.data(currentRecords.where((r) => r.id != id).toList());
        }
      },
    );
  }

  // 更新列表中的单个记录
  void updateRecordInList(Record updatedRecord) {
    if (state is AsyncData<List<Record>>) {
      final currentRecords = (state as AsyncData<List<Record>>).value;
      final updatedRecords = currentRecords.map((record) {
        if (record.id == updatedRecord.id) {
          return updatedRecord;
        }
        return record;
      }).toList();
      state = AsyncValue.data(updatedRecords);
    }
  }
}

// 记录列表 Provider
final recordsNotifierProvider = StateNotifierProvider<RecordsNotifier, AsyncValue<List<Record>>>((ref) {
  return RecordsNotifier(ref);
});

// 单个记录状态
@riverpod
class RecordDetailNotifier extends _$RecordDetailNotifier {
  late final String recordId;
  
  @override
  AsyncValue<Record> build(String id, [Record? initRecord]) {
    recordId = id;
    if (initRecord != null) {
      return AsyncValue.data(initRecord);
    }
    // 初始化时如果没有提供记录，加载记录
    loadRecord();
    return const AsyncValue.loading();
  }
  
  Future<void> loadRecord() async {
    state = const AsyncValue.loading();
    final repository = ref.watch(recordRepositoryProvider);
    final result = await repository.getRecordById(recordId);
    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (record) => state = AsyncValue.data(record),
    );
  }
  
  Future<void> updateRecord(Record record) async {
    final repository = ref.watch(recordRepositoryProvider);
    final result = await repository.updateRecord(record);
    result.fold(
      (failure) => throw failure,
      (updatedRecord) {
        // 更新单个记录状态
        state = AsyncValue.data(updatedRecord);
        ref.read(recordsNotifierProvider.notifier).updateRecordInList(updatedRecord);
      },
    );
  }
}

// 草稿记录 Provider
@riverpod
Future<List<Record>> draftRecords(Ref ref) async {
  final repository = ref.watch(recordRepositoryProvider);
  final result = await repository.getDraftRecords();
  return result.fold(
    (failure) => throw failure,
    (records) => records,
  );
}

// 已处理记录 Provider
@riverpod
Future<List<Record>> processedRecords(Ref ref) async {
  final repository = ref.watch(recordRepositoryProvider);
  final result = await repository.getProcessedRecords();
  return result.fold(
    (failure) => throw failure,
    (records) => records,
  );
}