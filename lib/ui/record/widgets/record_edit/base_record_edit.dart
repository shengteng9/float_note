import 'package:float_note/domain/core/failures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:float_note/domain/models/record.dart';
import '../../view_model/record_state_provider.dart';
import 'schedule_record_edit.dart';
import 'knowledget_record_edit.dart';
import 'financial_record_edit.dart';
import '../../../../utils/utils.dart';

class RecordEdit extends ConsumerStatefulWidget {
  final Record record;

  const RecordEdit({super.key, required this.record});

  @override
  ConsumerState<RecordEdit> createState() => _RecordEditState();
}

class _RecordEditState extends ConsumerState<RecordEdit> {
  final _formKey = GlobalKey<FormState>();

  void _handleSave() {
    final formState = _formKey.currentState;
    if (formState == null) return;

    _formKey.currentState!.save();

    ref
        .read(recordEditStateNotifierProvider(widget.record).notifier)
        .editRecordByForm(widget.record);

    // Navigator.of(context).pop();

    print('统一保存处理完成');
  }

  Widget _buildTitleField(RecordEditState recordEditState) {
    if (recordEditState.isEditing) {
      return TextFormField(
        initialValue: recordEditState.title,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '标题不能为空';
          }
          return null;
        },
        // 在表单提交前保存值
        onSaved: (value) {
          ref
              .read(recordEditStateNotifierProvider(widget.record).notifier)
              .updateRecordEntity(title: value);
        },
        decoration: InputDecoration(
          labelText: '标题',
          errorStyle: TextStyle(color: Colors.red),
        ),
        style: TextStyle(fontSize: 14),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('标题:'),
            SizedBox(width: 10),
            Expanded(
              child: Text(recordEditState.title),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailField(RecordEditState recordEditState) {
    final isEditing = recordEditState.isEditing;
    final detail = recordEditState.detail;

    if (isEditing) {
      return TextFormField(
        maxLines: 2,
        initialValue: detail,
        decoration: InputDecoration(labelText: '详情'),
        onChanged: (value) {
          // update record edit state
          ref
              .read(recordEditStateNotifierProvider(widget.record).notifier)
              .updateRecordEntity(detail: value);
        },
        style: TextStyle(fontSize: 14),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(right: 10.0), child: Text('详情:')),
            Expanded(
              child: Text(
                detail.isNotEmpty ? detail : '无',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCreatedAtField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('创建时间:'),
          SizedBox(width: 10),
          Text(widget.record.updateDateDisplay),
        ],
      ),
    );
  }

  Widget _buildTagsField(RecordEditState recordEditState) {
    final isEditing = recordEditState.isEditing;
    final tags = recordEditState.tags;

    if (isEditing) {
      return TextFormField(
        initialValue: tags.join(', '),
        onChanged: (value) {
          // update record edit state
          ref
              .read(recordEditStateNotifierProvider(widget.record).notifier)
              .updateRecordEntity(
                tags: value
                    .split(RegExp(r'[,，\s]+'))
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList(),
              );
        },
        decoration: InputDecoration(labelText: '标签 (用逗号分隔)'),
        style: TextStyle(fontSize: 14),
      );
    } else {
      return tags.isNotEmpty
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only( right: 10),
                  child: Text('标签:'),
                ),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontSize: 12,
                                height: 1.2,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            )
          : Text('无标签');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordEditStateAsync = ref.watch(
      recordEditStateNotifierProvider(widget.record),
    );

    final isEditing =
        ref
            .read(recordEditStateNotifierProvider(widget.record))
            .value
            ?.isEditing ??
        false;

    return AlertDialog(
      title: Center(
        child: Text(
          isEditing ? '编辑记录' : '记录详情',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      contentPadding: EdgeInsets.all(0),
      content: ConstrainedBox(
        constraints: BoxConstraints( minWidth: 400, maxWidth: 600),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: recordEditStateAsync.when(
            loading: () => Container(
              padding: EdgeInsets.only(top: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 14),
                  Text('加载中...'),
                ],
              ),
            ),
            error: (error, stack) => Text('加载失败: $error'),
            data: (recordEditState) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTitleField(recordEditState),
               
                    _buildTagsField(recordEditState),
             
                    _buildDetailField(recordEditState),

                    widget.record.type == '行程安排'
                        ? ScheduleRecordEdit(record: widget.record)
                        : Container(),

                    widget.record.type == '知识管理'
                        ? KnowledgetRecordEdit(record: widget.record)
                        : Container(),

                    widget.record.type == '个人财务'
                        ? FinancialRecordEdit(record: widget.record)
                        : Container(),

            
                    _buildCreatedAtField(),
               

                    if (!isEditing)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          try {
                            await ref
                                .read(recordsNotifierProvider.notifier)
                                .deleteRecord(widget.record.id!);
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text('记录删除成功'),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                duration:Duration(milliseconds: 300),
                              ),
                            );
                            Navigator.of(context).pop();
                          } catch (e) {
                            String errorMessage = '删除失败，请重试';
                            if (e is Failure) {
                              errorMessage = Utils.getErrorMessage(e);
                            } else {
                              errorMessage = e.toString();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration:Duration(milliseconds: 300)
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              '删除这条信息',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (recordEditStateAsync.valueOrNull?.isEditing ?? false) {
              return ref
                  .read(recordEditStateNotifierProvider(widget.record).notifier)
                  .toggleEditing();
            } else {
              ref
                  .read(recordEditStateNotifierProvider().notifier)
                  .resetState(widget.record);
              return Navigator.of(context).pop();
            }
          },
          child: Text(
            recordEditStateAsync.valueOrNull?.isEditing ?? false ? '取消' : '关闭',
          ),
        ),

        !(recordEditStateAsync.valueOrNull?.isEditing ?? false)
            ? TextButton(
                onPressed: () {
                  ref
                      .read(
                        recordEditStateNotifierProvider(widget.record).notifier,
                      )
                      .toggleEditing();
                },
                child: Text('编辑'),
              )
            : TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // 统一处理保存逻辑
                    _handleSave();
                  }
                },
                child: Text('保存'),
              ),
      ],
    );
  }
}

void showRecordEditDialogFun(BuildContext context, Record record) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      //return EditFormRecordDialog(record: record, onUpdate: onUpdate);
      return RecordEdit(record: record);
    },
  );
}
