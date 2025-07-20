import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _userIdKey = 'userId';

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    log('Stored user if is $userId');
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    //await prefs.remove(_tokenKey);
  }
}
