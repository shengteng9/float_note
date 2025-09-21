import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../ui/core/providers/app_providers.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';

import '../../../constants/constants.dart';

class AppBarTitle extends ConsumerWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusedDay = ref.watch(calendarProvider.select((s) => s.focusedDay));
    final formattedDate = DateFormat('yyyy.MM').format(focusedDay);
 
    // 判断是否需要显示"今"按钮（对比selectedDay与今天）
    final showBackButton = !isSameDay(
      ref.watch(calendarProvider.select((s) => s.focusedDay)),
      DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.all(0.0), // 两侧最小间距
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右贴边
        children: [
          // 左侧菜单按钮（左对齐）
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48), // 最小点击区域
            child: IconButton(
              icon: const Icon(Icons.menu),
              padding: EdgeInsets.zero, // 移除默认padding
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),

          // 中间日期（严格居中）
          Expanded(
            child: Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _showDatePicker(context, ref),
              ),
            ),
          ),

          
          if (showBackButton)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48), // 最小点击区域
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  '今',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => ref.read(calendarProvider.notifier).backToToday(),
              ),
            )
          else
            const SizedBox(width: 48), // 保持对称间距
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(calendarProvider.select((s) => s.selectedDay));
    final locale = ref.read(languageProvider.select((s) => s));
    // 日期选择器实现
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        selectionOverlay: Container(
          color: Colors.transparent,
        ),
      ),
      minDateTime: DateTime.parse(minDatetime),
      maxDateTime: DateTime.parse(maxDatetime),
      initialDateTime: selectedDay,
      dateFormat:  'yyyy-MMMM-dd',
      locale: locale == 'zh' ? DateTimePickerLocale.zh_cn : DateTimePickerLocale.en_us,
      onConfirm: (dateTime, List<int> index) {
        ref.read(calendarProvider.notifier).onDaySelected(dateTime, dateTime);
      },
    );
  
  }
}