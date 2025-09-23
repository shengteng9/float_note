import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/settings_service.dart';
import '../../core/services/notification_service.dart';

part 'settings.g.dart';

class Setting {
  final String systemLanguage;
  final int pendingNotificationCount;

  const Setting({
    this.systemLanguage = 'en',
    this.pendingNotificationCount = 0,
  });

  Setting copyWith({
    String? systemLanguage,
    int? pendingNotificationCount,
  }) {
    return Setting(
      systemLanguage: systemLanguage ?? this.systemLanguage,
      pendingNotificationCount: pendingNotificationCount ?? this.pendingNotificationCount,
    );
  }
}

@riverpod
class SettingNotifier extends _$SettingNotifier {
  final NotificationService _notificationService = NotificationService();
  
  SettingNotifier();

  @override
  AsyncValue<Setting> build() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final systemLanguage = systemLocale.languageCode;
    
    // 初始化时获取当前未处理通知数量
    final pendingNotificationCount = _notificationService.getPendingNotificationCount();
    
    // 注册监听器，监听未处理通知数量变化
    _notificationService.addNotificationCountListener(_onNotificationCountChanged);
    
    return AsyncValue.data(Setting(
      systemLanguage: systemLanguage,
      pendingNotificationCount: pendingNotificationCount,
    ));
  }
  
  // 未处理通知数量变化的回调
  void _onNotificationCountChanged(int count) {
    state = state.whenData((value) => value.copyWith(
      pendingNotificationCount: count,
    ));
  }
  
  // 更新语言
  void updateLanguage(String languageCode) {
    state = state.whenData((value) => value.copyWith(
      systemLanguage: languageCode,
    ));
  }

  // 获取当前语言的Locale
  Locale get currentLocale {
    final languageCode = state.value?.systemLanguage ?? 'en';
    return Locale(languageCode);
  }

  // 获取当前平台（需传入BuildContext）
  TargetPlatform getPlatform(BuildContext context) {
    return Theme.of(context).platform;
  }

  Future<void> feedback(String content) async {
    state = AsyncValue.loading();
    try {
      await ref.watch(settingsServiceProvider).feedback({
        'content': content,
      });
      state = AsyncValue.data(state.value!);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
  
  // 释放资源时移除监听器
  @override
  void dispose() {
    _notificationService.removeNotificationCountListener(_onNotificationCountChanged);
  }
}