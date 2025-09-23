import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/search_provider.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text('search'),
        ElevatedButton(
          onPressed: () {
            ref.read(searchProvider.notifier).sendNotification('这是一个测试通知。');
          },
          child: Text('发送通知'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(searchProvider.notifier).sendDelayedNotification('这是一个测试通知。');
          },
          child: Text('延迟通知'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(searchProvider.notifier).setiOSBadgeCount(0);
          },
          child: Text('设置iOS角标'),
        ),
      ],
    );
  }
}