import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 通知服务类
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 未处理的通知计数
  int _pendingNotificationCount = 0;

  // 监听器列表，用于监听未处理通知数的变化
  final List<void Function(int)> _notificationCountListeners = [];

  // 用于前台显示的弹窗控制器
  Completer<TimeOfDay>? _snoozeCompleter;

  // 构造函数
  NotificationService._internal() {
    _loadPendingNotificationCount();
  }

  // 初始化通知服务
  Future<void> initialize() async {
    // 初始化时区数据
    tz.initializeTimeZones();

    // 请求通知权限
    await requestNotificationPermission();

    // 配置Android平台的初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    // 配置iOS平台的初始化设置
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    // 合并初始化设置
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    // 初始化通知插件
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  // 请求通知权限
  Future<void> requestNotificationPermission() async {
    // 处理Android平台权限请求
    if (Platform.isAndroid) {
      // 在Android 13及以上版本，需要请求POST_NOTIFICATIONS权限
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      if (result != null) {
        debugPrint('Android通知权限请求结果: $result');
      }
    } 
    // 处理iOS平台权限请求
    else if (Platform.isIOS) {
      // 对于iOS平台，通过请求权限弹窗获取权限
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            sound: true,
            badge: true,
          );

      if (result != null) {
        debugPrint('iOS通知权限请求结果: $result');
      }
    }
  }

  // 显示即时通知
  Future<void> showNotification(
    int id,
    String title,
    String body,
    String payload,
  ) async {
    // 增加未处理通知计数
    

    // 配置Android平台的通知详情
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          // 在Android上，角标通常由系统管理
        );

    // 配置iOS平台的通知详情
    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          badgeNumber: _pendingNotificationCount + 1, // iOS角标
        );

    // 合并通知详情
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // 显示通知
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
    // 增加未处理通知计数
    _incrementPendingNotificationCount();
  }

  // 安排未来的通知
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    String payload,
  ) async {
    // 配置Android平台的通知详情
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'channel_id',
          'channel_name',
          channelDescription: 'channel_description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        );

    // 配置iOS平台的通知详情
    final DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          badgeNumber: _pendingNotificationCount + 1, // 作为预览，设置角标为当前计数+1
        );

    // 合并通知详情
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    // 对于预约通知，我们不在这里增加计数，因为计数应该在通知实际显示时增加
    // 获取目标时区
    final tz.TZDateTime scheduledDate = _convertTimeToTZDateTime(scheduledTime);

    // 安排通知
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'scheduled_notification:$payload', // 标记为预约通知
      );

      

      debugPrint('成功安排通知: $title, 时间: $scheduledTime');
    } catch (e) {
      debugPrint('安排通知失败: $e');
    }
  }

  // 处理前台通知点击事件
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    final String? payload = notificationResponse.payload;

    // 检查是否是预约通知的首次处理
    if (payload != null && payload.startsWith('scheduled_notification:')) {
      // 这里可以添加处理预约通知的逻辑
      // 在实际应用中，我们应该在通知实际显示时增加计数
      // 由于Flutter Local Notifications插件的限制，我们在点击时处理

      // 增加未处理通知计数（模拟收到通知时的行为）
      _incrementPendingNotificationCount();

      // 提取真实的payload
      final String actualPayload = payload.substring(
        'scheduled_notification:'.length,
      );

      debugPrint('处理预约通知点击，真实payload: $actualPayload');
      // 在这里处理实际的payload逻辑
    } else {
      // 如果不是预约通知，或者预约通知已经被处理过
      // 减少未处理通知计数，因为用户已经点击了通知（处理掉该通知）
      _decrementPendingNotificationCount();
    }

    // 处理通知点击事件，例如导航到特定页面
    if (payload != null) {
      debugPrint('通知被点击，payload: $payload');
      // 这里可以根据payload执行相应的操作
    }
  }

  // 处理后台通知点击事件
  static void onDidReceiveBackgroundNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    // 这个方法必须是静态的
    // 处理后台通知点击事件
    final String? payload = notificationResponse.payload;

    if (payload != null) {
      debugPrint('后台通知被点击，payload: $payload');

      // 在后台通知处理中，我们不能直接访问NotificationService的实例
      // 所以我们直接操作持久化存储中的计数
      try {
        final prefs = await SharedPreferences.getInstance();
        final int currentCount =
            prefs.getInt('pending_notification_count') ?? 0;

        if (currentCount > 0) {
          final int newCount = currentCount - 1;
          await prefs.setInt('pending_notification_count', newCount);

          // 在iOS上，我们需要设置应用角标
          if (Platform.isIOS) {
            final DarwinNotificationDetails darwinNotificationDetails =
                DarwinNotificationDetails(
                  badgeNumber: newCount,
                  presentAlert: false,
                  presentSound: false,
                  presentBadge: true,
                );

            final NotificationDetails notificationDetails = NotificationDetails(
              iOS: darwinNotificationDetails,
            );

            // 使用当前时间安排一个通知，只用于更新角标
            final DateTime now = DateTime.now().add(const Duration(seconds: 1));
            final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
              now,
              tz.local,
            );

            // 使用一个特殊的ID来标识这是一个角标更新通知
            const int badgeUpdateId = 999999;

            await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
              badgeUpdateId,
              '', // 空标题
              '', // 空内容
              scheduledDate,
              notificationDetails,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              payload: 'badge_update',
            );
          }

          debugPrint('后台通知处理：减少未处理通知计数到: $newCount');
        }
      } catch (e) {
        debugPrint('后台通知处理：更新未处理通知计数失败: $e');
      }
    }
  }

  // 增加未处理通知计数
  void _incrementPendingNotificationCount() {
    _pendingNotificationCount++;
    _savePendingNotificationCount();
    _notifyListeners();
    // 更新iOS角标
    _updateiOSBadgeCount();
    debugPrint('增加未处理通知计数到: $_pendingNotificationCount');
  }

  // 减少未处理通知计数
  void _decrementPendingNotificationCount() {
    if (_pendingNotificationCount > 0) {
      _pendingNotificationCount--;
      _savePendingNotificationCount();
      _notifyListeners();
      // 更新iOS角标
      _updateiOSBadgeCount();
      debugPrint('减少未处理通知计数到: $_pendingNotificationCount');
    }
  }

  // 清除所有未处理通知计数
  void clearAllPendingNotifications() {
    _pendingNotificationCount = 0;
    _savePendingNotificationCount();
    _notifyListeners();
    // 更新iOS角标
    _updateiOSBadgeCount();
  }

  // 获取未处理通知计数
  int getPendingNotificationCount() {
    return _pendingNotificationCount;
  }
  
  // 设置iOS应用角标（公共方法）
  Future<void> setiOSBadgeCount(int count) async {
    if (Platform.isIOS) {
      try {
        await _tryDirectBadgeUpdate(count);
        debugPrint('成功设置iOS角标为: $count');
      } catch (e) {
        debugPrint('设置iOS角标失败: $e');
      }
    }
  }

  // 保存未处理通知计数到本地存储
  Future<void> _savePendingNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('pending_notification_count', _pendingNotificationCount);
  }

  // 从本地存储加载未处理通知计数
  Future<void> _loadPendingNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    _pendingNotificationCount = prefs.getInt('pending_notification_count') ?? 0;
  }

  // 注册未处理通知计数变化的监听器
  void addNotificationCountListener(void Function(int) listener) {
    _notificationCountListeners.add(listener);
  }

  // 移除监听器
  void removeNotificationCountListener(void Function(int) listener) {
    _notificationCountListeners.remove(listener);
  }

  // 通知所有监听器
  void _notifyListeners() {
    for (final listener in _notificationCountListeners) {
      listener(_pendingNotificationCount);
    }
  }

  // 取消特定ID的通知
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    clearAllPendingNotifications();
  }

  // 更新iOS应用角标
  void _updateiOSBadgeCount() {
    // 在iOS上，对于flutter_local_notifications 19.4.2版本，
    // 角标通常是通过DarwinNotificationDetails中的badgeNumber设置的
    // 注意：iOS平台上清除角标（设置为0）有特殊处理机制，需要遵循特定流程
    if (Platform.isIOS) {
      print('===== ** update iOS badge, count: $_pendingNotificationCount');
      if (_pendingNotificationCount == 0) {
        _performiOSBadgeUpdate().catchError((e) {
          debugPrint('更新iOS角标失败: $e');
        });
      }
    }
  }

  // 执行iOS角标更新的具体逻辑
  Future<void> _performiOSBadgeUpdate() async {
    // 直接设置角标值，根据iOS原生开发标准方法，不需要特殊流程
    await _tryDirectBadgeUpdate(_pendingNotificationCount);
  }

  // 尝试直接更新角标（用于非零值或作为备选方案）
  Future<void> _tryDirectBadgeUpdate(int badgeNumber) async {
    final DarwinNotificationDetails darwinNotificationDetails = 
        DarwinNotificationDetails(
          badgeNumber: 0,
          presentAlert: false,
          presentSound: false,
          presentBadge: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      iOS: darwinNotificationDetails,
    );

    // 使用当前时间安排一个通知
    final DateTime now = DateTime.now().add(const Duration(seconds: 1));
    final tz.TZDateTime scheduledDate = _convertTimeToTZDateTime(now);

    // 使用特殊ID
    const int badgeUpdateId = 999999;
    // 使用类中已初始化的flutterLocalNotificationsPlugin实例
    await flutterLocalNotificationsPlugin.show(
      badgeUpdateId,
      '', // 空标题
      '', // 空内容
      notificationDetails,
      payload: 'badge_update_direct',
    );
  }

  // 转换时间到目标时区
  tz.TZDateTime _convertTimeToTZDateTime(DateTime dateTime) {
    final tz.Location localLocation = tz.local;
    return tz.TZDateTime.from(dateTime, localLocation);
  }

  // 显示延迟提醒选择弹窗
  Future<TimeOfDay?> showSnoozeDialog(BuildContext context) async {
    _snoozeCompleter = Completer<TimeOfDay>();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('选择延迟时间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('5分钟后'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeCompleter?.complete(
                    TimeOfDay.fromDateTime(
                      DateTime.now().add(const Duration(minutes: 5)),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('15分钟后'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeCompleter?.complete(
                    TimeOfDay.fromDateTime(
                      DateTime.now().add(const Duration(minutes: 15)),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('30分钟后'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeCompleter?.complete(
                    TimeOfDay.fromDateTime(
                      DateTime.now().add(const Duration(minutes: 30)),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('1小时后'),
                onTap: () {
                  Navigator.pop(context);
                  _snoozeCompleter?.complete(
                    TimeOfDay.fromDateTime(
                      DateTime.now().add(const Duration(hours: 1)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    return _snoozeCompleter?.future;
  }

  // 安排延迟提醒
  Future<void> scheduleSnoozeNotification(
    int originalId,
    String title,
    String body,
    SnoozeDuration duration,
  ) async {
    // 计算延迟后的时间
    DateTime scheduledTime = DateTime.now();

    switch (duration) {
      case SnoozeDuration.minutes5:
        scheduledTime = scheduledTime.add(const Duration(minutes: 5));
        break;
      case SnoozeDuration.minutes15:
        scheduledTime = scheduledTime.add(const Duration(minutes: 15));
        break;
      case SnoozeDuration.minutes30:
        scheduledTime = scheduledTime.add(const Duration(minutes: 30));
        break;
      case SnoozeDuration.hours1:
        scheduledTime = scheduledTime.add(const Duration(hours: 1));
        break;
    }

    // 安排新的通知
    await scheduleNotification(
      originalId,
      title,
      body,
      scheduledTime,
      'snoozed',
    );
  }

  // 应用从后台进入前台时，检查并更新未处理通知计数
  // 这个方法应该在应用的主入口处调用，例如在AppState的initState或didChangeAppLifecycleState中
  Future<void> checkAndUpdateNotificationCount() async {
    try {
      // 获取所有已安排但尚未触发的通知
      final pendingNotifications = await flutterLocalNotificationsPlugin
          .pendingNotificationRequests();

      // 统计所有预约通知的数量
      int scheduledNotificationCount = pendingNotifications.length;

      // 这里是一个近似实现
      // 实际应用中，理想的解决方案应该是：
      // 1. 在iOS上实现UNNotificationServiceExtension，在通知显示前增加计数
      // 2. 在Android上实现自定义BroadcastReceiver，在通知显示前增加计数
      // 3. 使用App Groups (iOS) 或 SharedPreferences (Android) 共享计数

      // 注意：以下代码只是一个临时解决方案，真实应用需要原生代码支持

      // 读取可能由原生代码写入的通知计数
      final prefs = await SharedPreferences.getInstance();
      final int nativeNotificationCount =
          prefs.getInt('native_notification_count') ?? 0;

      // 如果有原生通知计数，更新我们的计数
      if (nativeNotificationCount > 0) {
        _pendingNotificationCount = nativeNotificationCount;
        _notifyListeners();
        debugPrint('从原生代码更新通知计数到: $_pendingNotificationCount');

        // 清除原生计数，避免重复更新
        await prefs.remove('native_notification_count');
      }

      debugPrint('检测到$scheduledNotificationCount个待安排的通知');
    } catch (e) {
      debugPrint('检查未处理通知失败: $e');
    }
  }
}

// 延迟提醒的时间选项枚举
enum SnoozeDuration { minutes5, minutes15, minutes30, hours1 }
