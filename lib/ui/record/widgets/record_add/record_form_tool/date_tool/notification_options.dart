import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/bottom_sheet_buttons.dart';
import '../../../../view_model/record_form_provider.dart';
import 'duration_picker.dart';
import 'package:float_note/utils/utils.dart';

class NotificationOptions extends ConsumerWidget {
  const NotificationOptions({super.key});

  // 自定义时间的提醒选择，天、时、分
  void showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DurationPicker(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationOptions = ref.watch(
      recordFormNotifierProvider.select((s) => s.notificationOptions),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  ref
                      .read(recordFormNotifierProvider.notifier)
                      .setNotificationOptions({
                        'none': !notificationOptions?['none'],
                      });
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                leading: Checkbox(
                  value: notificationOptions?['none'],
                  onChanged: null,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return Colors.transparent;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                title: Text(
                  '无',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              ListTile(
                onTap: () {
                  Map<String, dynamic> updateOptions = {
                    'onTime': !notificationOptions?['onTime'],
                  };
                  ref
                      .read(recordFormNotifierProvider.notifier)
                      .setNotificationOptions(updateOptions);
                },
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                leading: Checkbox(
                  value: notificationOptions?['onTime'],
                  onChanged: null,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return Colors.transparent;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                title: Text(
                  '准时',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                title: Text(
                  '自定义',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  ),
                ),
                leading: Checkbox(
                  value: notificationOptions?['custom']?['isCustom'],
                  onChanged: null,
                  fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return Colors.transparent;
                  }),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                trailing: !notificationOptions?['custom']?['isCustom']
                    ? null
                    : Text(
                        '提前${Utils.formatDurationToDayHourMinute(notificationOptions?['custom']['time'] as Duration)}',
                      ),
                onTap: () {
                  showDatePicker(context);
                },
              ),
            ],
          ),
        ),

        BottomSheetButtons(
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
