import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/record.dart';
import 'base_record.dart';
import '../record_edit/base_record_edit.dart';

class KnowledgeRecordWidget extends ConsumerWidget {
  final Record record;
  const KnowledgeRecordWidget({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = record.content as Map<String, dynamic>;
    final title = content['title'] ?? '未能识别';
    final detail = content['detail'] ?? '未能识别梗概';
    final tags = List<String>.from(content['tags'] ?? []);
    final sourceType = content['source_type'] ?? '未知';
    final sourceName = content['source_name'] ?? '未知';
    final sourceUrl = content['source_url'] ?? '未知';

    return BaseRecord(
      title: title,
      subtitle: detail,
      tags: tags,
      contentSection: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            children: [
              Icon(
                Icons.source_outlined,
                size: 14,
              ),
              Text(sourceType, style: TextStyle(fontSize: 14)),
            ],
          ),

          if (sourceName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Icon(
                    Icons.content_paste_outlined,
                    size: 14,
                  ),
                  Text(sourceName, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

          if (sourceUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  Icon(
                    Icons.link_outlined,
                    size: 14,
                  ),
                  Text(sourceUrl, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.only(top: 6, right: 12),
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
        showRecordEditDialogFun(context, record);
      },
    );
  }
}
