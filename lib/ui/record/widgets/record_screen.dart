
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_model/record_state_provider.dart';

import 'record_list.dart';
import '../../../routing/routes.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 添加安全的返回逻辑
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              // 如果不能返回，则导航到首页
              router.go(Routes.home);
            }
          },
        ),
        title: const Text('记录列表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(recordsNotifierProvider.notifier).refresh(),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => RecordErrorWidget(
          error: error,
          onRetry: () {
            ref.read(recordsNotifierProvider.notifier).refresh();
          },
        ),
        data: (records) {
          return RecordsListView(records: records);
        },
      ),
    );
  }
}



