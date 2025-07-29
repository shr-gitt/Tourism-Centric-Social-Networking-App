import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class UserService {
  static const String userurl = Constants.userurl;
  static const String authurl = Constants.authurl;

  // Add JWT if needed from secure storage
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthStorage.getToken(); // if using JWT
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // uncomment if using token
    };
  }

  Future<bool> registerUser(Map<String, dynamic> data, File? image) async {
    Dio dio = Dio();

    FormData formData = FormData.fromMap({
      'UserName': data['UserName'],
      'Name': data['Name'],
      'Phone': data['PhoneNumber'],
      'Email': data['Email'],
      'Password': data['Password'],
      'ConfirmPassword': data['ConfirmPassword'],
    });

    if (image != null) {
      formData.files.add(
        MapEntry(
          'Image', // Field name expected by the server
          await MultipartFile.fromFile(image.path, filename: 'profile.jpg'),
        ),
      );
    }

    try {
      final response = await dio.post(
        '$authurl/Register',
        data: formData,
        //options: Options(headers: await _getHeaders()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        log('User registered successfully.');
        return true;
      } else {
        log('Failed to register user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      log("Error registering user: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$userurl/$userId'),
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

  Future loginUser(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$authurl/Login'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('data $data');
      //final userId = data['userId'];
      final token = data['token'];
      log('User login successfully.');
      await AuthStorage.saveToken(token);
      final userId = await AuthStorage.getUserId();
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
      Uri.parse('$userurl/$userId'),
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
      Uri.parse('$userurl/$userId'),
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
