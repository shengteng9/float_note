
import 'package:flutter/material.dart';
import '../../../../domain/models/record.dart';
import 'financial_record.dart';
import 'knowledge_record.dart';
import 'schedule_record.dart';
import 'package:float_note/ui/record/widgets/record_item/other_record.dart';

typedef RecordWidgetBuilder = Widget Function(Record record);

class RecordWidgetFactory {
  static final Map<String, RecordWidgetBuilder> _builders = {
    '个人财务': (record) => FinancialRecordWidget(record: record),
    '行程安排': (record) => ScheduleRecordWidget(record: record),
    '知识管理': (record) => KnowledgeRecordWidget(record: record),
    '其他': (record) => OtherRecordWidget(record: record),
  };

  static Widget build(Record record) {
    final builder = _builders[record.type];
    if (builder != null) {
      return builder(record);
    }

    // 默认 fallback
    return ListTile(
      title: Text("不支持的类型: ${record.type}"),
      subtitle: Text("ID: ${record.id}"),
      leading: Icon(Icons.warning, color: Colors.grey),
    );
  }
}