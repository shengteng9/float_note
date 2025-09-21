// 工具类
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../domain/core/failures.dart';


class Utils {
  // 日期格式化，增加异常处理
  static String formatDate(dynamic date, String pattern) {
    try {
      if (date == null || (date is String && date.isEmpty)) {
        return '无日期数据'; // 返回默认文本而不是尝试解析空值
      }
      return DateFormat(pattern).format(date is String ? DateTime.parse(date) : date);
    } catch (e) {
      // 捕获并处理日期解析异常
      debugPrint('日期格式化失败: $e, 输入值: $date');
      return '日期格式错误'; // 提供错误提示而不是崩溃
    }
  }

  // 农历节日
  static const Map<String, String> lunarFestival = {
    '12-30': '除夕',
    '1-1': '春节',
    '1-15': '元宵节',
    '5-5': '端午节',
    '8-15': '中秋节',
    '9-9': '重阳节',
  };
  // 阳历节日
  static const Map<String, String> solarFestival = {
    '1-1': '元旦节',
    '2-14': '情人节',
    '5-1': '劳动节',
    '5-4': '青年节',
    '6-1': '儿童节',
    '9-10': '教师节',
    '10-1': '国庆节',
    '12-25': '圣诞节',
    '3-8': '妇女节',
    '3-12': '植树节',
    '4-1': '愚人节',
    '5-12': '护士节',
    '7-1': '建党节',
    '8-1': '建军节',
    '12-24': '平安夜',
  };

  static String formatDurationToDayHourMinute(Duration duration) {
    String showText = '';
    // 获取天数
    final days = duration.inDays;

    if (days > 0) {
      showText = '$days天';
    }

    // 获取剩余小时数（去除整天后的小时数）
    final hours = duration.inHours.remainder(24);

    if (hours > 0) {
      // 格式化为两位数
      showText = '$showText${hours.toString().padLeft(2, '0')}小时';
    }
    // 获取剩余分钟数（去除整小时后的分钟数）
    final minutes = duration.inMinutes.remainder(60);

    if (minutes > 0) {
      showText = '$showText${minutes.toString().padLeft(2, '0')}分钟';
    }

    return showText;
  }

  static String convertIfSnake(String input) {
    // 正则：匹配典型的 snake_case（小写字母 + 下划线 + 小写字母）
    // 例如：a_b, user_name, first_name_last
    final snakePattern = RegExp(r'^[a-z]+(_[a-z]+)*$');

    // 判断是否匹配 snake_case
    if (snakePattern.hasMatch(input)) {
      return snakeToCamel(input);
    }

    // 不是 snake_case，直接返回原字符串
    return input;
  }

  // 蛇形转驼峰的辅助函数
  static String snakeToCamel(String snake) {

    var snakeWords = snake.split('_');
    if (snakeWords.length == 1) {
      return snake;
    } else {
      String camel = '';
      for (var i = 0; i < snakeWords.length; i++) {
        if (i == 0) {
          camel += snakeWords[i].toLowerCase();
        } else {
          camel += '${snakeWords[i][0].toUpperCase()}${snakeWords[i].substring(1).toLowerCase()}';
        }
      }
      return camel;
    }
  }

  // 处理failures的映射
  static String getErrorMessage(dynamic error) {
  if (error is Failure) {
    return error.when(
      serverFailure: (message, statusCode) => 
          statusCode != null ? '$message (错误码: $statusCode)' : message,
      networkFailure: (message) => message,
      unauthorizedFailure: (message) => message,
      notFoundFailure: (message) => message,
      validationFailure: (message) => message,
      unexpectedFailure: (message) => message,
    );
  } else if (error is Error || error is Exception) {
    return error.toString();
  }
  return '操作失败，请重试';
}

}
