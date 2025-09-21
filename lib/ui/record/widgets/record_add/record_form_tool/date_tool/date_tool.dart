import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/bottom_sheet_buttons.dart';
import '../../../../view_model/record_form_provider.dart';
import 'date_tool_date_time_picker.dart';
import 'package:float_note/utils/utils.dart';
import 'day_picker.dart';

import 'notification_options.dart';

class DateTool extends ConsumerStatefulWidget {
  const DateTool({super.key});

  @override
  ConsumerState<DateTool> createState() => _DateToolState();
}

class _DateToolState extends ConsumerState<DateTool> {
  DateTime? start;
  DateTime? end;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  String? dateTimeHM;

  // 选择执行时间
  void showPickerWithButtons(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return DateToolDateTimePicker();
      },
    );
  }

  // 选择提醒相关选项
  void showNotificationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return NotificationOptions();
      },
    );
  }

  // format 提醒的设置
  String formatNotificationOptions() {
    String showNotificationOptions = '';
    final notificationOptions = ref.watch(
      recordFormNotifierProvider.select((state) => state.notificationOptions),
    );
    if (notificationOptions?['none']) {
      showNotificationOptions = '无';
      return showNotificationOptions;
    } else {
      if (notificationOptions?['onTime']) {
        showNotificationOptions = '准时';
      }
      if (notificationOptions?['custom']['isCustom']) {
        showNotificationOptions =
            '提前${Utils.formatDurationToDayHourMinute(notificationOptions?['custom']['time'] as Duration)}';
      }

      return showNotificationOptions;
    }
  }

  // 设置重复提醒的弹框
  void showDayPicker(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) => DayPicker());
  }

  Widget dateTextWidget(BuildContext context) {
    TextStyle textStyle = TextStyle(
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
      color: Theme.of(context).colorScheme.primary,
    );

    return (start == null && end == null)
        ? Text(
            '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
            style: textStyle,
          )
        : (start != null) && (end != null)
        ? Text(
            '${start?.year}-${start?.month}-${start?.day} 至 ${end?.year}-${end?.month}-${end?.day}',
            style: textStyle,
          )
        : Text(
            '${start?.year}-${start?.month}-${start?.day}',
            style: textStyle,
          );
  }

  // 获取所有值为 true 的 key
  List<dynamic> getRepeatKeys(Map<String, bool> map) {
    return map.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();
  }

  // 格式化 key 列表为 "key1、key2、key3" 的字符串
  String formatRepeatKeys(List<dynamic> keys) {
    if (keys.isEmpty) return '';

    return keys.map((key) => key).join('、');
  }

  @override
  Widget build(BuildContext context) {
    DateTime? selectedDateTime = ref.watch(
      recordFormNotifierProvider.select((state) => state.selectedDateTime),
    );
    String showSelectedTime = selectedDateTime != null
        ? '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}'
        : '';
    final repeatingOptions = ref.watch(
      recordFormNotifierProvider.select((state) => state.repeatingOptions),
    );

    return Column(
      children: [
        SizedBox(height: 15),
        Text('选择日期', style: Theme.of(context).textTheme.titleMedium),
        //SizedBox(height: 10),
        SizedBox(height: 10),

        Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 10, right: 20),
              title: Text(
                '日期',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
              leading: Icon(Icons.date_range_outlined),
              trailing: SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [dateTextWidget(context)],
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[300]),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              leading: const Icon(Icons.timer_outlined),
              title: Text(
                '时间',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showSelectedTime.isNotEmpty)
                      Text(
                        showSelectedTime,
                        style: TextStyle(
                          fontSize: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              onTap: () => {showPickerWithButtons(context)},
            ),
            Divider(height: 1, color: Colors.grey[300]),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              leading: const Icon(Icons.notifications_outlined),
              title: Text(
                '提醒',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
              trailing: SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formatNotificationOptions(),
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.fontSize,
                        color: formatNotificationOptions()=='无'?Theme.of(context).colorScheme.onSurface:Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),
              onTap: () => {showNotificationOptions(context)},
            ),
            Divider(height: 1, color: Colors.grey[300]),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              leading: Icon(Icons.repeat_outlined, size: 22),
              title: Text(
                '重复提醒',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                ),
              ),
              trailing: SizedBox(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      formatRepeatKeys(
                            getRepeatKeys(repeatingOptions ?? {}),
                          ).isNotEmpty
                          ? formatRepeatKeys(
                              getRepeatKeys(repeatingOptions ?? {}),
                            )
                          : '无',
                      style: TextStyle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.fontSize,
                        color:
                            formatRepeatKeys(
                              getRepeatKeys(repeatingOptions ?? {}),
                            ).isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    Icon(Icons.keyboard_arrow_right_outlined),
                  ],
                ),
              ),

              onTap: () {
                showDayPicker(context);
              },
            ),
          ],
        ),

        BottomSheetButtons(
          onCancel: () => {Navigator.pop(context)},
          onConfirm: () => {Navigator.pop(context)},
        ),
      ],
    );
  }
}
