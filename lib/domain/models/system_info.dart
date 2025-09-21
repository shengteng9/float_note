import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_info.freezed.dart';

@freezed
abstract class SystemInfo with _$SystemInfo {
  const factory SystemInfo({
    String? appId,
    String? deviceId,
    String? pushToken,
    String? token,
    String? refreshToken,
    @Default(false) bool isLogin,
  }) = _SystemInfo;
}