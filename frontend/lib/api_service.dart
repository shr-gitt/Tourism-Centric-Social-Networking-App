import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ApiService {
  // Use your computer's local network IP address instead of 'localhost'
  //static const String baseUrl = 'http://192.168.1.246:5259/api';
  static const String baseUrl = 'http://localhost:5259/api';
  String? id;

  Future<bool> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("Error creating post", error: e);
      return false;
    }
  }
  
  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Map<String, dynamic>> fetchPostById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<bool> deletePost(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load post');
    }
  }
}