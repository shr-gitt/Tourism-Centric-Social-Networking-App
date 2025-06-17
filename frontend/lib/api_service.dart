import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your computer's local network IP address instead of 'localhost'
  //static const String baseUrl = 'http://192.168.1.246:5259/api';
  static const String baseUrl = 'http://localhost:5259/api';

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<bool> createPost(Map<String, dynamic> postData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postData),
    );

    return response.statusCode == 201; // Created
  }
}
