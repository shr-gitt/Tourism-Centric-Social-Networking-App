import 'dart:convert';
import 'dart:developer';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Use your computer's local network IP address instead of 'localhost'
  //static const String posturl = 'http://192.168.1.246:5259/api';
  static const String posturl = Constants.posturl;
  String? id;

  Future<bool> createPost(Map<String, dynamic> postData) async {
    try {
      final response = await http.post(
        Uri.parse('posturl'),
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
    final response = await http.get(Uri.parse(posturl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Map<String, dynamic>> fetchfewPosts(int page, int pageSize) async {
    final response = await http.get(
      Uri.parse('$posturl/posts?page=$page&pageSize=$pageSize'),
    );
    log("Request URL: $posturl/posts?page=$page&pageSize=$pageSize");

    if (response.statusCode == 200) {
      log('Fetched few posts');
      // Decode the JSON response and return it as a map
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Map<String, dynamic>> fetchPostById(String id) async {
    final response = await http.get(Uri.parse('$posturl/$id'));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      log('Response body: ${response.body}');
      throw Exception('Failed to load post');
    }
  }

  Future<bool> deletePost(String id) async {
    try {
      final response = await http.delete(Uri.parse('$posturl/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        log('Failed to delete post. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log('Error deleting post', error: e);
      return false;
    }
  }
}
