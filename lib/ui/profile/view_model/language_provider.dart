import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 定义支持的语言代码
const List<String> supportedLanguages = ['en', 'zh'];

// 创建语言提供器
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

// 语言通知器
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(_getSystemLanguage()) {
    // 初始化时检查系统语言
    if (!supportedLanguages.contains(state)) {
      // 如果系统语言不支持，默认使用英语
      state = 'zh';
    }
  }

  // 获取系统语言
  static String _getSystemLanguage() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final systemLanguage = systemLocale.languageCode;
    
    // 检查系统语言是否在支持的语言列表中
    if (supportedLanguages.contains(systemLanguage)) {
      return systemLanguage;
    } else {
      // 默认为英语
      return 'en';
    }
  }

  // 更新语言
  void updateLanguage(String languageCode) {
    if (supportedLanguages.contains(languageCode)) {
      state = languageCode;
    }
  }

  // 获取当前语言的Locale
  Locale get currentLocale {
    return Locale(state);
  }
}