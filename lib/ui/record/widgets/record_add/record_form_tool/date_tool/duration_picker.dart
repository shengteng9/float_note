import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/widgets/bottom_sheet_buttons.dart';
import '../../../../view_model/record_form_provider.dart';

class DurationPicker extends ConsumerStatefulWidget {
  const DurationPicker({super.key});

  @override
  ConsumerState<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends ConsumerState<DurationPicker> {
  late FixedExtentScrollController _daysController;
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  int days = 0;
  int hours = 0;
  int minutes = 0;

  @override
  void initState() {
    super.initState();

    // 从现有设置中获取初始值
    final notificationOptions = ref.read(
      recordFormNotifierProvider.select((s) => s.notificationOptions),
    );

    Duration initialDuration = Duration.zero;
    if (notificationOptions?['custom']?['isCustom'] == true) {
      initialDuration =
          notificationOptions?['custom']?['time'] ?? Duration.zero;
    }

    days = initialDuration.inDays;
    hours = initialDuration.inHours.remainder(24);
    minutes = initialDuration.inMinutes.remainder(60);

    // 初始化控制器并设置初始位置
    _daysController = FixedExtentScrollController(initialItem: days);
    _hoursController = FixedExtentScrollController(initialItem: hours);
    _minutesController = FixedExtentScrollController(initialItem: minutes);
  }

  @override
  void dispose() {
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '提前',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.access_time_outlined),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: _daysController,
                  itemExtent: 40,
                  onSelectedItemChanged: (value) => days = value,
                  children: List.generate(
                    32,
                    (i) => Text('$i 天', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 200, color: Colors.grey[300]),
            Expanded(
              child: SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: _hoursController,
                  itemExtent: 40,
                  onSelectedItemChanged: (value) => hours = value,
                  children: List.generate(
                    25,
                    (i) => Text('$i 时', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 200, color: Colors.grey[300]),
            Expanded(
              child: SizedBox(
                height: 200,
                child: CupertinoPicker(
                  scrollController: _minutesController,
                  itemExtent: 40,
                  onSelectedItemChanged: (value) => minutes = value,
                  children: List.generate(
                    61,
                    (i) => Text('$i 分', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
        BottomSheetButtons(
          onCancel: () => Navigator.pop(context),
          onConfirm: () {
            final notificationOptions = ref.read(
              recordFormNotifierProvider.select((s) => s.notificationOptions),
            );
            Map<String, dynamic> updateOptions = {...?notificationOptions};

            if (days == 0 && hours == 0 && minutes == 0) {
              updateOptions['custom'] = {
                'isCustom': false,
                'time': Duration.zero,
              };
              if (!notificationOptions?['onTime'] &&
                  !notificationOptions?['none']) {
                updateOptions['none'] = true;
              }
            } else {
              Duration duration = Duration(
                days: days,
                hours: hours,
                minutes: minutes,
              );
              updateOptions['custom'] = {'isCustom': true, 'time': duration};
              if (notificationOptions?['none']) {
                updateOptions['none'] = false;
              }
              if (notificationOptions?['onTime']) {
                updateOptions['onTime'] = false;
              }
            }

            ref
                .read(recordFormNotifierProvider.notifier)
                .setNotificationOptions(updateOptions);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
