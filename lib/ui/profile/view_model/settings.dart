import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/settings_service.dart';

part 'settings.g.dart';

class Setting {
  final String systemLanguage;

  const Setting({
    this.systemLanguage = 'en',
  });

  Setting copyWith({
    String? systemLanguage,
  }) {
    return Setting(
      systemLanguage: systemLanguage ?? this.systemLanguage,
    );
  }
}

@riverpod
class SettingNotifier extends _$SettingNotifier {
  
  SettingNotifier();

  @override
  AsyncValue<Setting> build() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final systemLanguage = systemLocale.languageCode;
    return AsyncValue.data(Setting(
      systemLanguage: systemLanguage,
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
}