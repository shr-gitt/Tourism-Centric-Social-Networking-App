import 'dart:convert';
import 'dart:developer';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class UsersettingsApiservice {
  static const String userurl = Constants.userurl;
  static const String manageUrl = Constants.manageurl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> addPhone(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$manageUrl/AddPhone'),
        headers: await _getHeaders(),
        body: jsonEncode({'PhoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        log('Phone verification code sent');
        return true;
      } else {
        log('Failed to send phone code: ${response.statusCode}');
        log('Error body: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Exception in addPhone: $e');
      return false;
    }
  }

  Future<bool> verifyPhone(String phoneNumber, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$manageUrl/VerifyPhone'),
        headers: await _getHeaders(),
        body: jsonEncode({'PhoneNumber': phoneNumber, 'Code': code}),
      );

      if (response.statusCode == 200) {
        log('Phone verified');
        return true;
      } else {
        log('Phone verification failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in verifyPhone: $e');
      return false;
    }
  }

  Future<bool> removePhone() async {
    try {
      final response = await http.post(
        Uri.parse('$manageUrl/RemovePhone'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        log('Phone number removed');
        return true;
      } else {
        log('Failed to remove phone: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in removePhone: $e');
      return false;
    }
  }

  Future<bool> twoFactor({required bool state}) async {
    try {
      final response = await http.post(
        Uri.parse('$manageUrl/EnableTwoFactor'),
        headers: await _getHeaders(),
        body: jsonEncode(state)
      );

      if (response.statusCode == 200) {
        log('2FA enabled');
        return true;
      } else {
        log('Failed to enable 2FA: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in enableTwoFactor: $e');
      return false;
    }
  }
}
