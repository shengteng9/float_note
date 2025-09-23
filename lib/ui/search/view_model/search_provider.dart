import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/notification_service.dart';


final searchProvider = StateNotifierProvider<SearchNotifier, String>((
  ref,
) {
  return SearchNotifier();
});


class SearchNotifier extends StateNotifier<String> {

  final NotificationService _notificationService = NotificationService();

  SearchNotifier() : super('');
  int _notificationId = 0;
  
  void sendNotification(String query) {
    debugPrint('_notificationId: $_notificationId');
    _notificationService.showNotification(
      _notificationId++,
      'Search Query',
      'body',
      query,
    );
  }

  void sendDelayedNotification(String query) {
    debugPrint('_notificationId: $_notificationId');
    _notificationService.scheduleNotification(
      _notificationId++,
      'Search Query',
      query,
      DateTime.now().add(const Duration(seconds: 5)),
      query,
    );
  }

  void setiOSBadgeCount(int count) {
    debugPrint('尝试设置iOS角标为: $count');
    _notificationService.setiOSBadgeCount(count);
  }
}