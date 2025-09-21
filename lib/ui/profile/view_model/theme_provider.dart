import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 创建主题提供器
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

// 创建主题模式提供器
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

// 主题模式通知器
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  void setLightTheme() => state = ThemeMode.light;
  void setDarkTheme() => state = ThemeMode.dark;
  void setSystemTheme() => state = ThemeMode.system;
}

// 主题通知器
class ThemeNotifier extends StateNotifier<ThemeData> {
  // 存储当前主题颜色
  Color _customColor = Color(0xFF434EBB);

  ThemeNotifier() : super(_createLightTheme(Color(0xFF434EBB)));

  // 切换到亮色主题
  void setLightTheme() {
    state = _createLightTheme(_customColor);
  }

  // 切换到暗色主题
  void setDarkTheme() {
    state = _createDarkTheme(_customColor);
  }

  // 更新主题颜色
  void updateThemeColor(Color color) {
    _customColor = color;
    // 根据当前主题亮度更新主题
    if (state.brightness == Brightness.light) {
      setLightTheme();
    } else {
      setDarkTheme();
    }
  }

  // 创建亮色主题
  static ThemeData _createLightTheme(Color customColor) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: customColor,
      colorScheme: ColorScheme.light(
        primary: customColor,
        secondary: customColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: customColor,
        foregroundColor: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: customColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customColor,
        ),
      ),
    );
  }

  // 创建暗色主题
  static ThemeData _createDarkTheme(Color customColor) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: customColor,
      colorScheme: ColorScheme.dark(
        primary: customColor,
        secondary: customColor,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
      appBarTheme: AppBarTheme(
        backgroundColor: customColor,
        foregroundColor: Colors.white,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: customColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: customColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: customColor,
        ),
      ),
    );
  }
}