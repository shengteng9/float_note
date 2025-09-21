import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/record.dart';
import 'record_item/record_widget_factory.dart';
import '../view_model/record_state_provider.dart';
// 添加calendarProvider的导入
import '../../../ui/core/providers/calendar_provider.dart';

class RecordsListView extends ConsumerStatefulWidget {
  final List<Record> records;

  const RecordsListView({super.key, required this.records});

  @override
  ConsumerState<RecordsListView> createState() => _RecordsListViewState();
}

class _RecordsListViewState extends ConsumerState<RecordsListView>
    with AutomaticKeepAliveClientMixin {
  // 添加滚动控制器
  late ScrollController _scrollController;
  // 上次滚动位置
  double _lastScrollPosition = 0;
  
  @override
  void initState() {
    super.initState();
    // 初始化滚动控制器
    _scrollController = ScrollController();
    // 添加滚动监听
    _scrollController.addListener(_handleScroll);
  }
  
  @override
  void dispose() {
    // 释放滚动控制器
    _scrollController.dispose();
    super.dispose();
  }
  
  // 处理滚动事件
  void _handleScroll() {
    final currentScrollPosition = _scrollController.position.pixels;
    final isScrollingUp = currentScrollPosition > _lastScrollPosition;
    
    // 检查是否需要收起日历
    if (isScrollingUp) {
      final isCalendarExpanded = ref.read(calendarProvider.select((s) => s.isExpanded));
      if (isCalendarExpanded) {
        ref.read(calendarProvider.notifier).toggleExpanded();
      }
    }
    
    // 更新上次滚动位置
    _lastScrollPosition = currentScrollPosition;
  }
  
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用以启用 AutomaticKeepAliveClientMixin
    
    // 检查记录列表是否为空
    if (widget.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 56, color: Theme.of(context).disabledColor,),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(recordsNotifierProvider.notifier).refresh();
      },
      child: ListView.builder(
        controller: _scrollController, // 添加滚动控制器
        key: const PageStorageKey<String>('records_list_view'), // 添加页面存储键
        physics: const AlwaysScrollableScrollPhysics(), // 确保可以下拉刷新
        itemCount: widget.records.length,
        itemBuilder: (context, index) {
          final record = widget.records[index];
          return Container(
            child: RecordWidgetFactory.build(record),
          );
        },
      ),
    );
  }
}

class RecordErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const RecordErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('错误: ${error.toString()}'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}


