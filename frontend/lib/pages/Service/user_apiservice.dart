import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class UserService {
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

  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$manageurl/Index'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        log('User settings fetched');
        return jsonDecode(response.body);
      } else {
        log('Failed to fetch settings: ${response.statusCode}');
        log('Error body: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception in getUserSettings: $e');
      return null;
    }
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
        '$userurl/Register',
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

  Future<Map<String, dynamic>> fetchUserByUserName(String username) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$userurl/GetByUserName/$username'),
      headers: headers,
    );

    log('Url is : $userurl/GetByUserName/$username');
    if (response.statusCode == 200) {
      log('User has been fetched from fetchUserByUserName');
      return jsonDecode(response.body);
    } else {
      log('User has not been fetched from fetchUserByUserName');
      throw Exception('Failed to load user: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> fetchUserData(String username) async {
    try {
      log(
        'Currently in fetchUserData trying to fetchUserByUserName. here, username is $username',
      );
      final userData = await fetchUserByUserName(username);
      log('Fetched user: $userData');
      return userData;
    } catch (e) {
      log('Error fetching user through fetchUserData: $e');
      return null;
    }
  }

  Future loginUser(Map<String, dynamic> data) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$userurl/Login'),
      headers: headers,
      body: jsonEncode(data),
    );
    log('Trying to log in user');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('data $data');

      final token = data['token'];
      log('User login successfully.');
      log('token is $token');
      await AuthStorage.saveToken(token);

      final username = await AuthStorage.getUserName();
      return username;
    } else {
      log('Failed to login user: ${response.body}-${response.statusCode}');
      return null;
    }
  }

  Future logoutUser() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$userurl/Logout'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('logout service data is $data');

      return true;
    } else {
      log('Failed to logout user: ${response.body} - ${response.statusCode}');
      return false;
    }
  }

  Future guestUser() async {
    final header = await _getHeaders();
    final response = await http.post(
      Uri.parse('$userurl/UseAsGuest'),
      headers: header,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Guest User service data is $data');

      return true;
    } else {
      log(
        'Failed to login as guest user: ${response.body} - ${response.statusCode}',
      );
      return false;
    }
  }

  /*Future<bool> updateUser(
    String username,
    Map<String, dynamic> updatedData,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$userurl/$username'),
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

  Future<bool> deleteUser(String username) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$userurl/$username'),
      headers: headers,
    );

    if (response.statusCode == 204) {
      log('User deleted successfully.');
      return true;
    } else {
      log('Failed to delete user: ${response.body}');
      return false;
    }
  }*/
}
