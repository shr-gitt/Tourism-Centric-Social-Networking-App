import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class EnhancedUserApiService {
  static const String userurl = Constants.userurl;
  static const String manageurl = Constants.manageurl;

  // Add JWT if needed from secure storage
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Forgot Password - Send reset code to email
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ForgotPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('Forgot password response: ${result['message']}');
        return result['success'] ?? true;
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

  /// Reset Password - Reset password using code
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ResetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Email': email,
          'Code': code,
          'Password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('Reset password successful: ${result['message']}');
        return result['success'] ?? true;
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

  /// Guest Access - Create temporary guest user
  Future<Map<String, dynamic>?> useAsGuest() async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/UseAsGuest'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('Guest access granted');
        
        if (result['success'] == true && result['data'] != null) {
          // Save token and refresh token
          final data = result['data'];
          await AuthStorage.saveToken(data['token']);
          await AuthStorage.saveRefreshToken(data['refreshToken']);
          
          return result;
        }
        return result;
      } else {
        log('Guest access failed: ${response.statusCode}');
        log('Error body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception in useAsGuest: $e');
      return null;
    }
  }

  /// External Login - Initiate external login (Google, Facebook, etc.)
  Future<String?> initiateExternalLogin(String provider, String returnUrl) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ExternalLogin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'returnUrl': returnUrl,
        }),
      );

      if (response.statusCode == 401 || response.statusCode == 302) {
        // This is expected for external login challenge
        // Return the redirect URL from headers or response
        return response.headers['location'] ?? 
               '${Constants.baseurl}/Account/ExternalLogin?provider=$provider&returnUrl=$returnUrl';
      } else {
        log('External login initiation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in initiateExternalLogin: $e');
      return null;
    }
  }

  /// External Login Confirmation - Complete external login
  Future<bool> confirmExternalLogin(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/ExternalLoginConfirmation'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('External login confirmed: ${result['message']}');
        return result['success'] ?? true;
      } else {
        log('External login confirmation failed: ${response.statusCode}');
        log('Error body: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Exception in confirmExternalLogin: $e');
      return false;
    }
  }

  /// Get All Users (Admin functionality)
  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$userurl/GetAll'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result is List) {
          return List<Map<String, dynamic>>.from(result);
        }
        return null;
      } else {
        log('Get all users failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in getAllUsers: $e');
      return null;
    }
  }

  /// Get User by Username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$userurl/$username'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('User fetched by username: $username');
        return result;
      } else {
        log('Get user by username failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in getUserByUsername: $e');
      return null;
    }
  }

  /// Logout User
  Future<bool> logoutUser() async {
    try {
      final response = await http.post(
        Uri.parse('$userurl/Logout'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('User logged out: ${result['message']}');
        
        // Clear local storage
        await AuthStorage.logout();
        
        return result['success'] ?? true;
      } else {
        log('Logout failed: ${response.statusCode}');
        // Still clear local storage even if server request fails
        await AuthStorage.logout();
        return false;
      }
    } catch (e) {
      log('Exception in logoutUser: $e');
      // Clear local storage even on exception
      await AuthStorage.logout();
      return false;
    }
  }

  /// Refresh Token
  Future<Map<String, dynamic>?> refreshToken() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) {
        log('No refresh token available');
        return null;
      }

      final response = await http.post(
        Uri.parse('$userurl/RefreshToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true && result['data'] != null) {
          final data = result['data'];
          await AuthStorage.saveToken(data['token']);
          await AuthStorage.saveRefreshToken(data['refreshToken']);
          log('Token refreshed successfully');
          return result;
        }
        return null;
      } else {
        log('Token refresh failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in refreshToken: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await AuthStorage.getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$manageurl/Index'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final refreshResult = await refreshToken();
        return refreshResult != null;
      }
      return false;
    } catch (e) {
      log('Exception in isAuthenticated: $e');
      return false;
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$manageurl/Index'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        log('Current user profile fetched');
        return result;
      } else {
        log('Get current user profile failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('Exception in getCurrentUserProfile: $e');
      return null;
    }
  }
}