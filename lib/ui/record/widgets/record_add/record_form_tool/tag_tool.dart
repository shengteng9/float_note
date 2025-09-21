import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../view_model/record_form_provider.dart';

class TagTool extends ConsumerWidget {
  const TagTool({super.key});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // 临时修复，使用默认值
    const tags = ['标签A', '标签B', '标签C', '标签D'];
    const selectedTags = [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Text(
              '选择标签',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tags.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8), // 添加右侧间距
                    child: FilterChip(
                      label: Text(tags[index]),
                      selected: selectedTags.contains(tags[index]),
                      onSelected: (bool selected) {
                        ref
                            .read(recordFormNotifierProvider.notifier)
                            .toggleTag(tags[index]);
                      },
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      selectedColor: Theme.of(context).colorScheme.secondary,
                      side: BorderSide.none,
                      avatar: selectedTags.contains(tags[index])
                          ? Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Text(
                                '#',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : null,
                      labelStyle: TextStyle(
                        color: selectedTags.contains(tags[index])
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 5,
                      ),
                    ),
                  );
                }),
              ),
            ),

          // 简化实现，移除对不存在provider的引用
          TextButton(
            onPressed: () {
              // 可以添加简单的提示
            },
            child: Text('+ 添加标签'),
          ),
      ],
    
    );
  }
}