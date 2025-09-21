import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/utils.dart';
import '../../record/view_model/record_state_provider.dart';

class CalendarState {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final bool isExpanded;
  
  
  CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    this.isExpanded = false,
  });
  
  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    bool? isExpanded,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref);
});

class CalendarNotifier extends StateNotifier<CalendarState> {
  final Ref ref;
  
  CalendarNotifier(this.ref) : super(CalendarState(
    selectedDay: DateTime.now(),
    focusedDay: DateTime.now(),
  ));
  
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
    ); 
    ref.read(recordsNotifierProvider.notifier).loadRecords({
      'created_at': Utils.formatDate(selectedDay, 'yyyy-MM-dd'),
    });
  }
  
  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }
  
  void backToToday() {
    final today = DateTime.now();
    state = state.copyWith(
      selectedDay: today,
      focusedDay: today,
    );

    ref.read(recordsNotifierProvider.notifier).loadRecords({
      'created_at': Utils.formatDate(today, 'yyyy-MM-dd'),
    });
  }
}