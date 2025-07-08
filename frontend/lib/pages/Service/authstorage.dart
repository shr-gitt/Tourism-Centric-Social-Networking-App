import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    //final prefs = await SharedPreferences.getInstance();
    //return prefs.getString('userId');
    return "686b8bc91d177681dc98f1b7";
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}

/*
await AuthStorage.saveUserId(userId);
String? uid = await AuthStorage.getUserId();
*/