// 待优化
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_lunar_calendar/chinese_lunar_calendar.dart';
import '../../../constants/constants.dart';
import 'package:float_note/ui/core/providers/app_providers.dart';

class Calendar extends ConsumerStatefulWidget {

  final Function(DateTime, DateTime) onDateSelected;
  final DateTime selectedDay;
  final DateTime focusedDay;



  const Calendar({
    super.key,
    required this.onDateSelected,
    required this.selectedDay,
    required this.focusedDay,
  });

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {

  @override
  void initState() {
    super.initState();
  }

  String _getFestivalInfo(DateTime date) {
    final lunarCalendar = LunarCalendar.from(utcDateTime: date.toUtc());
    final lunarMonth = lunarCalendar.lunarDate.lunarMonth.number;
    final lunarDay = lunarCalendar.lunarDate.lunarDay;
    final lunarKey = '$lunarMonth-$lunarDay';

    final solarKey = '${date.month}-${date.day}';

    final hasLunarFestival = lunarFestival.containsKey(lunarKey);
    final hasSolarFestival = solarFestival.containsKey(solarKey);

    String resultFestival = '';

    if (hasSolarFestival && hasLunarFestival) {
      resultFestival = '${solarFestival[solarKey]}|${lunarFestival[lunarKey]}';
    } else if (hasSolarFestival) {
      resultFestival = solarFestival[solarKey]!;
    } else if (hasLunarFestival) {
      resultFestival = lunarFestival[lunarKey]!;
    }

    return resultFestival;
  }

  // 获取节日信息
  String _getLunarInfo(DateTime date) {
    final lunarCalendar = LunarCalendar.from(utcDateTime: date.toUtc());
    // 没有节日则返回农历信息
    if (lunarCalendar.lunarDate.lunarDay == 1) {
      return lunarCalendar.lunarDate.lunarMonth.lunarMonthCN.sValue ?? '';
    }
    return lunarCalendar.lunarDate.lunarDayCN;
  }

  // 自定义日历日期的构建方式
  Widget _calendarDayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay, {
    bool isSelected = false,
    bool isToday = false,
    bool isOutside = false,
  }) {
    final festivalText = _getFestivalInfo(day);
    final isFestival = _getFestivalInfo(day).isNotEmpty;

    Color backgroundColor = Colors.transparent;
    Color textNumberColor = Theme.of(context).colorScheme.onSurface;
    Color textFestivalColor = Colors.grey;

    if (isToday) {
      textNumberColor = Theme.of(context).colorScheme.primary;
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textFestivalColor = Theme.of(context).colorScheme.primary;
    } else if (isSelected) {
    textNumberColor = Theme.of(context).colorScheme.primaryContainer;
      backgroundColor = Theme.of(context).colorScheme.primary;
      textFestivalColor = Theme.of(context).colorScheme.primaryContainer;
    } else if (isOutside) {
      textNumberColor = Colors.grey;
    }



    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle, 
        color: backgroundColor
      ),

      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${isToday ? '今' : day.day}',
              style: TextStyle(
                fontSize: 16,
                color: textNumberColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              isFestival ? festivalText : _getLunarInfo(day),
              style: TextStyle(
                fontSize: 12,
                color: textFestivalColor
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //const List<String> weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final languageCode = ref.read(languageProvider.select((s) => s));

    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 10.0, left: 10.0, right: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TableCalendar(
            locale: languageCode,
            firstDay: DateTime.parse(minDatetime),
            lastDay: DateTime.parse(maxDatetime),
            //rowHeight: 62.0,
            focusedDay: widget.focusedDay,
            rangeSelectionMode:  RangeSelectionMode.toggledOff, // 启用范围选择模式
            calendarFormat: ref.watch(calendarProvider).isExpanded ? CalendarFormat.month : CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
            formatAnimationDuration: const Duration(milliseconds: 100),
            onDaySelected: widget.onDateSelected,

            headerVisible: false,
            daysOfWeekHeight: 35,
           daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarStyle: CalendarStyle(
              // tableBorder: TableBorder.all(
              //   color: Colors.red,
              //   width: 0,
              // ),
            ),
            onPageChanged: (focusedDay) {
              widget.onDateSelected(widget.selectedDay, focusedDay);
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _calendarDayBuilder(
                  context,
                  day,
                  focusedDay,
                  isToday: isSameDay(DateTime.now(), day),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return _calendarDayBuilder(
                  context,
                  day,
                  focusedDay,
                  isToday: true,
                );
              },
              outsideBuilder: (context, day, focusedDay) {
                return _calendarDayBuilder(
                  context,
                  day,
                  focusedDay,
                  isOutside: true,
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return _calendarDayBuilder(
                  context,
                  day,
                  focusedDay,
                  isSelected: true,
                  isToday: isSameDay(DateTime.now(), day),
                );
              },
              // rangeStartBuilder: (context, day, focusedDay) {
              //   return _calendarDayBuilder(
              //     context,
              //     day,
              //     focusedDay,
              //     isRangeStart: true,
              //     isToday: isSameDay(DateTime.now(), day),
              //   );
              // },
              // rangeEndBuilder: (context, day, focusedDay) {
              //   return _calendarDayBuilder(
              //     context,
              //     day,
              //     focusedDay,
              //     isRangeEnd: true,
              //     isToday: isSameDay(DateTime.now(), day),
              //   );
              // },
            ),
            // headerStyle: HeaderStyle(
            //   formatButtonVisible: true,
            //   titleCentered: true,
            //   formatButtonDecoration: BoxDecoration(
            //     color: Theme.of(context).colorScheme.primary,
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   formatButtonTextStyle: TextStyle(color: Colors.white),
            // ),
          ),
        ],
      ),
    );
  }
}
