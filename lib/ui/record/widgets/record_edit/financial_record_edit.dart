import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../view_model/record_state_provider.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import '../../../../domain/models/record.dart';
import '../../../../utils/utils.dart';
import '../../../../constants/constants.dart';

class FinancialRecordEdit extends ConsumerWidget {
  const FinancialRecordEdit({super.key, required this.record});
  final Record record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(recordEditStateNotifierProvider(record))
        .when(
          data: (recordEditState) {
            return _FinancialRecordEditContent(
              record: record,
              recordEditState: recordEditState,
            );
          },
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
  }
}

// 将表单内容提取到 StatefulWidget 中以使用 TextEditingController
class _FinancialRecordEditContent extends ConsumerStatefulWidget {
  const _FinancialRecordEditContent({
    required this.record,
    required this.recordEditState,
  });

  final Record record;
  final RecordEditState recordEditState;

  @override
  ConsumerState<_FinancialRecordEditContent> createState() =>
      __FinancialRecordEditContentState();
}

class __FinancialRecordEditContentState extends ConsumerState<_FinancialRecordEditContent> {
  late TextEditingController dateController;

  @override
  void initState() {
    super.initState();
    // 初始化日期控制器
    dateController = TextEditingController(
      text: widget.recordEditState.transactionDate != null
          ? Utils.formatDate(widget.recordEditState.transactionDate!, 'yyyy-MM-dd H时:m分')
          : '',
    );
  }

  @override
  void didUpdateWidget(_FinancialRecordEditContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 transactionDate 发生变化时，更新控制器的值
    if (widget.recordEditState.transactionDate != oldWidget.recordEditState.transactionDate) {
      dateController.text = widget.recordEditState.transactionDate != null
          ? Utils.formatDate(widget.recordEditState.transactionDate!, 'yyyy-MM-dd H时:m分')
          : '';
    }
  }

  @override
  void dispose() {
    // 释放控制器资源
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recordEditState.isEditing;
    final amount = widget.recordEditState.amount;
    final transactionType = widget.recordEditState.transactionType;
    final amountFrom = widget.recordEditState.amountFrom;
    final amountTo = widget.recordEditState.amountTo;
    final transactionDate = widget.recordEditState.transactionDate;
    final summary = widget.recordEditState.summary;

    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: amount != 0 ? amount.toString() : '',
            onChanged: (value) {
              // 尝试将字符串转换为double
              final double? parsedAmount = double.tryParse(value);
              if (parsedAmount != null) {
                ref
                    .read(recordEditStateNotifierProvider(widget.record).notifier)
                    .updateRecordEntity(amount: parsedAmount);
              }
            },
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入金额';
              }
              final double? parsedAmount = double.tryParse(value);
              if (parsedAmount == null) {
                return '请输入有效的数字';
              }
              return null;
            },
            decoration: InputDecoration(labelText: '金额'),
          ),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: transactionType.isNotEmpty ? transactionType : '支出',
            items: ['支出', '收入'].map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref
                    .read(recordEditStateNotifierProvider(widget.record).notifier)
                    .updateRecordEntity(transactionType: value);
              }
            },
            decoration: InputDecoration(labelText: '交易类型'),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: amountFrom,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(widget.record).notifier)
                  .updateRecordEntity(amountFrom: value),
            },
            decoration: InputDecoration(labelText: '来源账户'),
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: amountTo,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(widget.record).notifier)
                  .updateRecordEntity(amountTo: value),
            },
            decoration: InputDecoration(labelText: '目标账户'),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: dateController, // 使用控制器替代 initialValue
            readOnly: true, // 设置为只读，避免手动输入
            decoration: InputDecoration(labelText: '交易日期'),
            onTap: () => {
              print('选择日期'),
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
                initialDateTime: transactionDate ?? DateTime.now(),
                dateFormat: 'yyyy-MM-dd H时:m分',
                locale: DateTimePickerLocale.zh_cn,
                onConfirm: (dateTime, List<int> index) {
                  print('selected date: $dateTime');
                  ref
                    .read(recordEditStateNotifierProvider(widget.record).notifier)
                    .updateRecordEntity(transactionDate: dateTime);
                  // 直接更新控制器的值，确保即时显示
                  dateController.text = Utils.formatDate(dateTime, 'yyyy-MM-dd H时:m分');
                },
              ),
            },
          ),
          SizedBox(height: 10),
          TextFormField(
            initialValue: summary,
            onChanged: (value) => {
              ref
                  .read(recordEditStateNotifierProvider(widget.record).notifier)
                  .updateRecordEntity(summary: value),
            },
            decoration: InputDecoration(labelText: '摘要'),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('金额: '),
              Text(
                amount.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(children: [Text('类型: '), Text(transactionType)]),
          if (amountFrom.isNotEmpty || amountTo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('账户: '),
                  Expanded(
                    child: Text(
                      _buildAccountText(amountFrom, amountTo),
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),

          if (transactionDate != null)
            Column(
              children: [
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('日期: '),
                    Expanded(
                      child: Text(
                        Utils.formatDate(
                          transactionDate,
                          'yyyy-MM-dd HH:mm:ss',
                        ),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (summary.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('摘要: '),
                    Expanded(child: Text(summary)),
                  ],
                ),
              ],
            ),
        ],
      );
    }
  }

  String _buildAccountText(String amountFrom, String amountTo) {
    if (amountFrom.isNotEmpty && amountTo.isNotEmpty) {
      return '$amountFrom -> $amountTo';
    } else if (amountFrom.isNotEmpty) {
      return amountFrom;
    } else if (amountTo.isNotEmpty) {
      return amountTo;
    }
    return '';
  }
}
