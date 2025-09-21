import 'package:flutter/material.dart';
import '../../../../domain/models/record.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../utils/utils.dart';
import 'base_record.dart';
import '../record_edit/base_record_edit.dart';

class FinancialRecordWidget extends ConsumerWidget {
  final Record record;

  const FinancialRecordWidget({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = record.content as Map<String, dynamic>;
    final amount = content['amount'].toString();
    final title = content['title'] ?? '未知支出';
    final amountFrom = content['amount_from'] ?? '';
    final amountTo = content['amount_to'] ?? '';
    final tags = List<String>.from(content['tags'] ?? []);
    final summary = content['summary'] ?? '';
    final transactionType = content['transaction_type'] ?? '收支';
    final transactionDate = Utils.formatDate(
      content['transaction_date'] ?? '',
      'yyyy-MM-dd HH:mm:ss',
    );

    final detail = content['detail'] ?? '';

    return BaseRecord(
      title: title,
      subtitle: summary,
      tags: tags,
      contentSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.money,
                size: 14,
              ),
              Text(transactionType, style: TextStyle(fontSize: 14)),
              Text(amount, style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 6),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 14,
              ),
              Text(amountFrom ?? '', style: TextStyle(fontSize: 14)),
              Text('->', style: TextStyle(fontSize: 14)),
              Text(amountTo ?? '', style: TextStyle(fontSize: 14)),
            ],
          ),
          // 交易时间
          SizedBox(height: 6),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 14,
              ),
              Text(
                transactionDate,
                style: TextStyle( fontSize: 14),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 6, right: 14),
            child: Row(
               crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                    Icons.more,
                    size: 14,
                  ),
                
                Expanded(
                  child: Wrap(
                    children: [
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    
      onTap: () {
        showRecordEditDialogFun(
          context,
          record,
        );
      },
    );
  }
}
