import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 安全存储服务，用于存储和读取敏感信息如token等
class SecureStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _avatorKey = 'avator';

  /// 保存Token到本地存储
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      debugPrint('Error saving token: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      // 可以选择重新抛出异常，或者根据业务逻辑决定是否继续执行
    }
  }

  /// 读取Token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return null;
    }
  }

  /// 保存RefreshToken到本地存储
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (e) {
      debugPrint('Error saving refresh token: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 读取RefreshToken
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return null;
    }
  }

  /// 保存登录状态
  Future<void> setLoggedIn(bool isLoggedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
    } catch (e) {
      debugPrint('Error setting login status: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 获取登录状态
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return false;
    }
  }

  /// 保存用户ID
  Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      debugPrint('Error saving user ID: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 获取用户ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('Error getting user ID: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return null;
    }
  }

  /// 保存用户名
  Future<void> saveUserName(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, userName);
    } catch (e) {
      debugPrint('Error saving user name: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 获取用户名
  Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      debugPrint('Error getting user name: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return null;
    }
  }

  /// 保存头像
  Future<void> saveAvator(String? avator) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (avator != null) {
        await prefs.setString(_avatorKey, avator);
      } else {
        await prefs.remove(_avatorKey);
      }
    } catch (e) {
      debugPrint('Error saving avatar: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 获取头像
  Future<String?> getAvator() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_avatorKey);
    } catch (e) {
      debugPrint('Error getting avatar: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
      return null;
    }
  }

  /// 清除所有认证相关信息（退出登录）
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_avatorKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }

  /// 保存完整的用户认证信息
  Future<void> saveUserAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String userName,
    String? avator,
  }) async {
    try {
      
      await Future.wait([
        saveToken(token),
        saveRefreshToken(refreshToken),
        saveUserId(userId),
        saveUserName(userName),
        saveAvator(avator),
        setLoggedIn(true),
      ]);
    } catch (e) {
      debugPrint('Error saving user auth data: $e');
      // 在Web平台上，shared_preferences可能会有不同的行为
      if (kIsWeb) {
        debugPrint('SharedPreferences may not work as expected on web platform');
      }
    }
  }
}