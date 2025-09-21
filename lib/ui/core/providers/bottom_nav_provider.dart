// bottom_nav_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavVisibilityProvider = StateProvider<bool>((ref) {
  return true; // 默认显示底部导航
});