import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/calendar.dart';
import '../../../ui/core/providers/app_providers.dart';

class CalendarSection extends ConsumerWidget {
  const CalendarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    return Calendar(
      selectedDay: state.selectedDay,
      focusedDay: state.focusedDay,
      onDateSelected: (selected, focused) => 
        ref.read(calendarProvider.notifier).onDaySelected(selected, focused),
    );
  }
}