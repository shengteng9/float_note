import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../view_model/record_form_provider.dart';
class CategoryTool extends ConsumerWidget {
  const CategoryTool({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 临时修复，使用默认值
    const categories = ['知识收集', '个人财务', '行程管理', '其他A', '其他B', '其他C', '其他D'];
    const selectedCategory = ''; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择分类',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Wrap(
          children: List.generate(categories.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8), // 添加右侧间距
              child: FilterChip(
                label: Text(categories[index]),
                selected: selectedCategory == categories[index],
                onSelected: (bool selected) {
                  ref
                      .read(recordFormNotifierProvider.notifier)
                      .toggleCategory(categories[index]);
                },
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                selectedColor: Theme.of(context).colorScheme.primary,
                side: BorderSide.none,
                avatar: selectedCategory == categories[index]
                    ? Container(
                        margin: EdgeInsets.only(left: 10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 2,
                            ),
                          ),
                          child: SizedBox(width: 10, height: 10),
                        ),
                      )
                    : null,
                labelStyle: TextStyle(
                  color: selectedCategory == categories[index]
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              ),
            );
          }),
        ),

        // 简化实现，移除对不存在provider的引用
        TextButton(
          onPressed: () {
            // 可以添加简单的提示
          },
          child: Text('+ 添加分类'),
        ),
      
      ],
    );
  }
}
