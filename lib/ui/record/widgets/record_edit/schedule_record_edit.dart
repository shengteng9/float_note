import 'package:float_note/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import '../../view_model/record_state_provider.dart';
import '../../../../domain/models/record.dart';
import '../../../../constants/constants.dart';

class ScheduleRecordEdit extends ConsumerWidget {
  const ScheduleRecordEdit({super.key, required this.record});

  final Record record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordEditStateAsync = ref.read(
      recordEditStateNotifierProvider(record),
    );

    return recordEditStateAsync.when(
      data: (recordEditState) {
        return _ScheduleRecordEditContent(
          record: record,
          recordEditState: recordEditState,
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, st) => Text('加载错误: $e'),
    );
  }
}

class _ScheduleRecordEditContent extends ConsumerStatefulWidget {
  const _ScheduleRecordEditContent({
    required this.record,
    required this.recordEditState,
  });

  final Record record;
  final RecordEditState recordEditState;

  @override
  ConsumerState<_ScheduleRecordEditContent> createState() =>
      __ScheduleRecordEditContentState();
}

class __ScheduleRecordEditContentState
    extends ConsumerState<_ScheduleRecordEditContent> {
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(
      text: widget.recordEditState.reminderAt != null
          ? Utils.formatDate(
              widget.recordEditState.reminderAt!,
              'yyyy-MM-dd H时:m分',
            )
          : '',
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  Widget _buildTasksField(RecordEditState recordEditState) {
    final isEditing = recordEditState.isEditing;
    final tasks = recordEditState.tasks;

    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.only(top: 5.0), child: Text('任务列表:')),
          ...tasks.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> task = entry.value;
            String taskName = task['name'] ?? '';
            return Row(
              children: [
                Icon(Icons.radio_button_checked_outlined, size: 14),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: taskName,
                    onChanged: (value) {
                      tasks[index]['name'] = value;
                    },
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline_outlined, size: 14),
                  onPressed: () {
                    final newTasks = [...tasks]..removeAt(index);
                    ref
                        .read(
                          recordEditStateNotifierProvider(
                            widget.record,
                          ).notifier,
                        )
                        .updateRecordEntity(tasks: newTasks);
                  },
                ),
              ],
            );
          }),

          TextButton(
            onPressed: () {
              // 添加一个新任务
              final newTasks = [
                ...tasks,
                {'name': '新任务', 'is_completed': false},
              ];
              ref
                  .read(recordEditStateNotifierProvider(widget.record).notifier)
                  .updateRecordEntity(tasks: newTasks);
            },
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [Icon(Icons.add, size: 16), Text('添加任务')],
            ),
          ),
        ],
      );
    } else if (tasks.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Text('任务列表:'),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...tasks.map((task) {
                    bool isCompleted = task['is_completed'] ?? false;
                    String taskName = task['name'] ?? '';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            isCompleted
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 16,
                            color: isCompleted ? Colors.green : Colors.grey,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            taskName,
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget _buildStatusField(RecordEditState recordEditState) {
    final isEditing = recordEditState.isEditing;
    final status = recordEditState.status;

    print('当前状态: $status');

    if (isEditing) {
      return DropdownButtonFormField<String>(
        value: status,
        isExpanded: true,
        items: ['待处理', '进行中', '已完成', '已取消'].map((status) {
          return DropdownMenuItem(value: status, child: Text(status));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            ref
                .read(recordEditStateNotifierProvider(null).notifier)
                .updateRecordEntity(status: value);
          }
        },
        decoration: InputDecoration(labelText: '状态'),
        style: TextStyle(fontSize: 14, color: Colors.black),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态:'),
            SizedBox(width: 10),
            Text(status.isNotEmpty ? status : '无'),
          ],
        ),
      );
    }
  }

  Widget _buildDueDateField(RecordEditState recordEditState) {
    final isEditing = recordEditState.isEditing;
    final dueDate = recordEditState.dueDate;

    if (dueDate == null) {
      return Container();
    }

    if (isEditing) {
      return TextFormField(
        initialValue: Utils.formatDate(dueDate, 'yyyy-MM-dd HH:mm:ss'),
        decoration: InputDecoration(labelText: '截止日期'),
        style: TextStyle(fontSize: 14),
      );
    } else if (dueDate != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('截止日期:'),
            SizedBox(width: 10),
            Expanded(
              child: Text(Utils.formatDate(dueDate, 'yyyy-MM-dd HH:mm:ss')),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget _buildReminderField(
    RecordEditState recordEditState,
    BuildContext context,
  ) {
    final isEditing = recordEditState.isEditing;
    final needReminder = recordEditState.needReminder;
    final reminderAt = recordEditState.reminderAt;

    if (isEditing) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('是否需要提醒', style: TextStyle(fontSize: 14)),
              Checkbox(
                value: needReminder,
                onChanged: (value) {
                  ref
                      .read(
                        recordEditStateNotifierProvider(widget.record).notifier,
                      )
                      .updateRecordEntity(needReminder: value);
                },
                // 移除了注释掉的代码
              ),
            ],
          ),
          Divider(height: 1.5, thickness: 1.2, color: Colors.black45),

          // 保持原有的TextFormField不变
          SizedBox(height: 8), // 添加间距
          TextFormField(
            readOnly: true,
            controller: dateController,
            decoration: InputDecoration(labelText: '提醒时间'),
            style: TextStyle(fontSize: 14),
            onTap: () => {
              DatePicker.showDatePicker(
                context,
                onMonthChangeStartWithFirstDate: true,
                pickerMode: DateTimePickerMode.time,
                pickerTheme: DateTimePickerTheme(
                  showTitle: true,
                  selectionOverlay: Container(color: Colors.transparent),
                ),
                minDateTime: DateTime.parse(minDatetime),
                maxDateTime: DateTime.parse(maxDatetime),
                initialDateTime: reminderAt ?? DateTime.now(),
                dateFormat: 'yyyy-MM-dd H时:m分',
                locale: DateTimePickerLocale.zh_cn,
                onConfirm: (dateTime, List<int> index) {
                  print('selected date: $dateTime');
                  ref
                      .read(
                        recordEditStateNotifierProvider(widget.record).notifier,
                      )
                      .updateRecordEntity(reminderAt: dateTime);
                  // 直接更新控制器的值，确保即时显示
                  dateController.text = Utils.formatDate(
                    dateTime,
                    'yyyy-MM-dd H时:m分',
                  );
                },
              ),
            },
          ),
        ],
      );
    } else if (needReminder) {
      // 非编辑状态的代码保持不变
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('提醒时间:'),
            SizedBox(width: 10),
            Text(Utils.formatDate(reminderAt, 'yyyy-MM-dd HH:mm:ss')),
          ],
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusField(widget.recordEditState),
        _buildDueDateField(widget.recordEditState),
        _buildTasksField(widget.recordEditState),
        _buildReminderField(widget.recordEditState, context),
      ],
    );
  }
}
