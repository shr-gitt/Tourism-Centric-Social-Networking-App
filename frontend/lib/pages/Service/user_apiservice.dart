import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'http://localhost:5259/api/users';
  static const String url = 'http://localhost:5259/api/auth';

  // Add JWT if needed from secure storage
  Future<Map<String, String>> _getHeaders() async {
    // String? token = await AuthStorage.getToken(); // if using JWT
    return {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer $token', // uncomment if using token
    };
  }

  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final userData = await fetchUserById(userId);
      log('Fetched user: $userData');
      return userData;
    } catch (e) {
      log('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> registerUser(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$url/register'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      log('User registered successfully.');
      return true;
    } else {
      log('Failed to register user: ${response.body}-${response.statusCode}');
      return false;
    }
  }

  Future loginUser(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$url/login'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('data $data');
      final userId = data['userId'];
      log('User login successfully.');
      return userId;
    } else {
      log('Failed to login user: ${response.body}-${response.statusCode}');
      return null;
    }
  }

  Future<bool> updateUser(
    String userId,
    Map<String, dynamic> updatedData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/$userId'),
      headers: headers,
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 204 || response.statusCode == 200) {
      log('User updated successfully.');
      return true;
    } else {
      log('Failed to update user: ${response.body}');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$userId'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      log('User deleted successfully.');
      return true;
    } else {
      log('Failed to delete user: ${response.body}');
      return false;
    }
  }
}
