// 通知配置常量

// 通知渠道ID和名称
const String reminderChannelId = 'scheduled_reminder_channel';
const String reminderChannelName = '日程提醒';
const String reminderChannelDescription = '用于显示日程提醒的通知';

// 通知声音文件路径
const String notificationSoundPath = 'assets/audio/notification_sound.mp3';

// 通知图标路径
const String notificationIconPath = '@mipmap/ic_launcher';

// 通知默认标题
const String defaultNotificationTitle = 'Float Note';

// 通知相关的请求码
const int notificationRequestCode = 1001;

// 通知类型枚举
enum NotificationType {
  reminder,
  alert,
  message,
  other,
}

// 通知优先级枚举
enum NotificationPriority {
  low,
  medium,
  high,
  max,
}