import 'dart:convert';
import 'dart:developer';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class PasswordApiservice {
  static const String userurl = Constants.userurl;
  static const String manageurl = Constants.manageurl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ForgotPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );

      if (response.statusCode == 200) {
        log('Forgot password link sent');
        return true;
      } else {
        log('Forgot password failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in forgotPassword: $e');
      return false;
    }
  }

  Future<bool> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ResetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        log('Password reset successful');
        return true;
      } else {
        log('Reset password failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in resetPassword: $e');
      return false;
    }
  }

  Future<bool> changePassword(
    String oldPwd,
    String newPwd,
    String confirmPwd,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$manageurl/ChangePassword'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'OldPassword': oldPwd,
          'NewPassword': newPwd,
          'ConfirmPassword': confirmPwd,
        }),
      );

      if (response.statusCode == 200) {
        log('Password changed');
        return true;
      } else {
        log('Change password failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in changePassword: $e');
      return false;
    }
  }

  Future<bool> setPassword(String newPwd, String confirmPwd) async {
    try {
      final response = await http.post(
        Uri.parse('$manageurl/SetPassword'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'NewPassword': newPwd,
          'ConfirmPassword': confirmPwd,
        }),
      );

      if (response.statusCode == 200) {
        log('Password set');
        return true;
      } else {
        log('Set password failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in setPassword: $e');
      return false;
    }
  }
}
