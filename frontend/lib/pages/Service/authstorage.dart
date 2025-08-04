import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const _userIdKey = 'userId';
  static const _tokenKey = 'jwtToken';

  static Map<String, dynamic> decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    final payload = base64Url.normalize(parts[1]);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(payload)));

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Invalid payload');
    }

    return payloadMap;
  }

  static Future<void> saveUserName(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    log('Stored user id is $userId');
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    log('In get user id, userid is ${prefs.getString(_userIdKey)}');
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    log('Stored JWT is $token');
    await prefs.setString(_tokenKey, token);

    final decoded = decodeJwt(token);
    log('decoded jwt is: $decoded');

    final username = decoded['sub'];

    //final username =decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name:'];
    log('after decoding, userId is : $username');

    if (username != null) {
      await saveUserName(username);
    } else {
      log('User ID not found in JWT payload');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
  }
}
