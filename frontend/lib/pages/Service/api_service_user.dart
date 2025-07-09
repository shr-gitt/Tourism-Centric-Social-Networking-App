import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'http://localhost:5259/api/users';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> fetchUserById(String feedbackid) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$feedbackid'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feedback');
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
}
