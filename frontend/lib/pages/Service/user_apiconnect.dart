import 'dart:developer';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';

class UserConnect {
  final String? userId;
  final Map<String, dynamic>? updatedData;

  UserConnect({this.userId, this.updatedData});

  /// Fetch the logged-in user's data
  Future<Map<String, dynamic>?> fetchCurrentUser() async {
    try {
      String? uid = userId ?? await AuthStorage.getUserId();
      if (uid == null) {
        log("User ID is null");
        return null;
      }

      final userService = UserService();
      final userData = await userService.fetchUserData(uid);
      return userData;
    } catch (e) {
      log("Failed to fetch user: $e");
      return null;
    }
  }

  Future<bool> updateCurrentUser(Map<String, dynamic> data) async {
    try {
      String? uid = userId ?? await AuthStorage.getUserId();
      if (uid == null) {
        log("User ID is null");
        return false;
      }

      final userService = UserService();
      final success = await userService.updateUser(uid, data);
      return success;
    } catch (e) {
      log("Failed to update user: $e");
      return false;
    }
  }

  Future<bool> deleteCurrentUser() async {
    try {
      String? uid = userId ?? await AuthStorage.getUserId();
      if (uid == null) {
        log("User ID is null");
        return false;
      }

      final userService = UserService();
      final success = await userService.deleteUser(uid);
      return success;
    } catch (e) {
      log("Failed to delete user: $e");
      return false;
    }
  }
}
