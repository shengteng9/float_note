import 'package:float_note/ui/record/widgets/record_edit/base_record_edit.dart';
import 'package:float_note/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/record.dart';
import 'base_record.dart';
import '../../view_model/record_state_provider.dart';

class ScheduleRecordWidget extends ConsumerWidget {
  final Record record;
  const ScheduleRecordWidget({super.key, required this.record});

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case '待处理':
        return Icon(Icons.pending_actions, size: 18, color: Colors.grey);
      case '进行中':
        return Icon(Icons.timelapse_outlined, size: 18, color: Colors.orange);
      case '已完成':
        return Icon(Icons.check_circle_outlined, size: 18, color: Colors.green);
      default:
        return Icon(Icons.cancel_outlined, size: 18, color: Colors.grey);
    }
  }

  // 修改tasks的状态
  void _updateTaskStatus(int index, WidgetRef ref) {
    final contentCopy = Map<String, dynamic>.from(record.content ?? {});
    final List<dynamic> tasks = List<dynamic>.from(contentCopy['tasks'] ?? []);

    if (index >= 0 && index < tasks.length) {
      // 修改任务状态
      tasks[index] = Map<String, dynamic>.from(tasks[index]);
      tasks[index]['is_completed'] =
          !(tasks[index]['is_completed'] as bool? ?? false);

      contentCopy['tasks'] = tasks;

      if (contentCopy['status'] != '已取消') {
        final allCompleted = tasks.every(
          (task) => task['is_completed'] == true,
        );
        final allPending = tasks.every((task) => task['is_completed'] == false);

        if (allCompleted) {
          contentCopy['status'] = '已完成';
        } else if (allPending) {
          contentCopy['status'] = '待处理';
        } else {
          contentCopy['status'] = '进行中';
        }
      }
      final updatedRecord = record.copyWith(content: contentCopy);
      // 使用新的Record实例更新
      ref
          .read(
            recordDetailNotifierProvider(record.id!, updatedRecord).notifier,
          )
          .updateRecord(updatedRecord);
    }
  }

  // 提醒
  Widget buildReminder() {
    final content = record.content as Map<String, dynamic>;
    final reminderAt = Utils.formatDate(
      content['reminder_at'] ?? '',
      'yyyy-MM-dd HH:mm',
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.alarm, size: 18, color: Colors.red),
          SizedBox(width: 6),
          Text(reminderAt, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = record.content as Map<String, dynamic>;
    final title = content['title'] ?? '未能识别';

    final tags = List<String>.from(content['tags'] ?? []);
    final status = content['status'] ?? '未知';
    final List<dynamic> tasks = content['tasks'] ?? [];
    final dueDate = content['due_date'] ?? '';
    final needReminder = content['need_reminder'] ?? false;

    return BaseRecord(
      title: title,
      tags: tags,
      contentSection: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildStatusIcon(status),
                SizedBox(width: 6),
                Expanded(
                  child: Wrap(
                    children: [
                      Text(status, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (tasks.isNotEmpty)
                  for (var task in tasks)
                    // 点击事件
                    InkWell(
                      onTap: () => _updateTaskStatus(tasks.indexOf(task), ref),
                      child:  Row(
                          key: Key(task['name']),
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              task['is_completed']
                                  ? Icons.check_box_outlined
                                  : Icons.check_box_outline_blank_outlined,
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Wrap(
                                children: [
                                  Text(
                                    task['name'],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      
                    ),
              ],
            ),
          ),

          if (dueDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          Utils.formatDate(dueDate, 'yyyy-MM-dd HH:mm:ss'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // 提醒
          if (needReminder) buildReminder(),
        ],
      ),
      onTap: () {
        showRecordEditDialogFun(context, record);
      },
    );
  }
}
