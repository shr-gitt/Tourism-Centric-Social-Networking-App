import 'dart:convert';
import 'dart:developer';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class ExternalloginApiservice {
  static const String userurl = Constants.userurl;
  static const String manageurl = Constants.manageurl;

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> removeExternalLogin(String provider, String key) async {
    try {
      final response = await http.post(
        Uri.parse('$manageurl/RemoveExternalLogin'),
        headers: await _getHeaders(),
        body: jsonEncode({'LoginProvider': provider, 'ProviderKey': key}),
      );

      if (response.statusCode == 200) {
        log('External login removed');
        return true;
      } else {
        log('Failed to remove external login: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in removeExternalLogin: $e');
      return false;
    }
  }

  Future<bool> linkExternalLogin(String provider) async {
    try {
      final response = await http.post(
        Uri.parse('$manageurl/LinkExternalLogin'),
        headers: await _getHeaders(),
        body: jsonEncode({'Provider': provider}),
      );

      if (response.statusCode == 200) {
        log('External login link initiated');
        return true;
      } else {
        log('Failed to start external login link: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in linkExternalLogin: $e');
      return false;
    }
  }

  Future<bool> linkExternalLoginCallback() async {
    try {
      final response = await http.get(
        Uri.parse('$manageurl/LinkExternalLoginCallback'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        log('External login callback successful');
        return true;
      } else {
        log('External login callback failed: ${response.statusCode}');
        log('Error body: ${response.body}');

        return false;
      }
    } catch (e) {
      log('Exception in linkExternalLoginCallback: $e');
      return false;
    }
  }
}
