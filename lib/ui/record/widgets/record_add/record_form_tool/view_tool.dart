import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;
import '../../../view_model/record_form_provider.dart';

import 'category_tool.dart';
import 'tag_tool.dart';
import 'date_tool/date_tool.dart';

class ViewTool extends ConsumerWidget {
  const ViewTool({super.key});

  void _showAddFrom(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const DateTool(),
      );
    },
  );
}


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 临时修复，直接使用none状态
    const activeTab = RecordFormToolTab.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            badges.Badge(
              position: badges.BadgePosition.topEnd(top: 5, end: 5),
              showBadge: true,
              //badgeContent: Text("3", style: TextStyle(color: Colors.white)),
              child: IconButton(
                isSelected: activeTab == RecordFormToolTab.category,
                icon: Icon(Icons.category),
                selectedIcon: Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {},
              ),
            ),

            IconButton(
              isSelected: activeTab == RecordFormToolTab.tag,
              onPressed: () {},
              icon: Icon(Icons.tag),
              selectedIcon: Icon(
                Icons.tag,
                color: Theme.of(context).colorScheme.primary,
              ),
              color: Theme.of(context).colorScheme.onSurface,
            ),
            IconButton(
              isSelected: activeTab == RecordFormToolTab.timer,
              onPressed: () => {
                _showAddFrom(context, ref),
              },
              icon: Icon(Icons.timer),
              selectedIcon: Icon(
                Icons.timer,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        activeTab == RecordFormToolTab.category
            ? const CategoryTool()
            : activeTab == RecordFormToolTab.tag
            ? const TagTool()
            : SizedBox.shrink(),
      ],
    );
  }
}
