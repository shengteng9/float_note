import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class BaseRecord extends StatelessWidget {
  final String title;
  final String? subtitle; // 可选副标题
  final List<String> tags;
  final Widget contentSection; // 【关键】可自定义的中间内容区域
  final VoidCallback? onTap;
  final String type;

  const BaseRecord({
    Key? key,
    required this.title,
    this.subtitle,
    this.tags = const [],
    this.type = '',
    required this.contentSection,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // 移除阴影
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主体内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题行
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            '${type.isNotEmpty ? '${title}（未分类）' : title}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    //const SizedBox(height: 10),
                    // 自定义内容区
                    contentSection,
                    if (tags.isNotEmpty) 
                      const SizedBox(height: 10),
                    // 标签行
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (String tag in tags)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.tag,
                                  size: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.2,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              //  trailing
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                // width: 16,
                // height: 16,
                child: Icon(
                  Icons.edit_note_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
