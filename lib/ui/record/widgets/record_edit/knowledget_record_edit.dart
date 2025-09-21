import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/record_state_provider.dart';
import '../../../../domain/models/record.dart';

class KnowledgetRecordEdit extends ConsumerWidget {
  final Record record;

  const KnowledgetRecordEdit({super.key, required this.record});

  // 知识记录状态字段
  Widget _buildSourceFields(RecordEditState recordEditState, WidgetRef ref) {
    final isEditing = recordEditState.isEditing;
    final sourceType = recordEditState.sourceType;
    final sourceName = recordEditState.sourceName;
    final sourceUrl = recordEditState.sourceUrl;

    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: sourceType,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(record).notifier)
                  .updateRecordEntity(sourceType: value),
            },
            decoration: InputDecoration(labelText: '来源类型'),
          ),
          TextFormField(
            initialValue: sourceName,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(record).notifier)
                  .updateRecordEntity(sourceName: value),
            },
            decoration: InputDecoration(labelText: '来源名称'),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: sourceUrl,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(record).notifier)
                  .updateRecordEntity(sourceUrl: value),
            },
            decoration: InputDecoration(labelText: '来源链接'),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源类型:'),
              SizedBox(width: 4),
              Text(sourceType.isNotEmpty ? sourceType : '无'),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源名称:'),
              SizedBox(width: 4),
              Expanded(child: Text(sourceName.isNotEmpty ? sourceName : '无'),)
              ,
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源链接:'),
              SizedBox(width: 4),
              Expanded(child: Text(sourceUrl.isNotEmpty ? sourceUrl : '无'),)
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordEditStateAsync = ref.watch(
      recordEditStateNotifierProvider(record),
    );

    return recordEditStateAsync.when(
      data: (recordEditState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _buildSourceFields(recordEditState, ref),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
