import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../domain/models/record.dart';

import 'base_record.dart';
import '../record_edit/base_record_edit.dart';

class OtherRecordWidget extends ConsumerWidget {
  final Record record;
  const OtherRecordWidget({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = record.content as Map<String, dynamic>;
    final title = content['title'] ?? '其他';
    final tags = List<String>.from(content['tags'] ?? []);
    final detail = content['detail'] ?? '';
    return BaseRecord(
      title: title,
      tags: tags,
      type: record.type,
      contentSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                    Icons.more,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
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
