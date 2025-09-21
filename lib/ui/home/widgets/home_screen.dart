import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_section.dart';

import '../../record/widgets/record_list.dart';
import '../../record/view_model/record_state_provider.dart';
import '../../../ui/core/providers/app_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以启用 AutomaticKeepAliveClientMixin
    final isExpanded = ref.watch(calendarProvider.select((s) => s.isExpanded));
    final recordsAsync = ref.watch(recordsNotifierProvider);
    return Column(
      children: [
        CalendarSection(),
        IconButton(
          icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onPressed: () => ref.read(calendarProvider.notifier).toggleExpanded(),
        ),
        Expanded(
          child: recordsAsync.when(
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
        ),)
      ],
    );
  }
}
