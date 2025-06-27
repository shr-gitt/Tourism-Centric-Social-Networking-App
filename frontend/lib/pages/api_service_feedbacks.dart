import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class FeedbackService {
  // Replace with your actual IP if testing on device
  static const String baseUrl = 'http://localhost:5259/api/feedbacks';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  Future<bool> submitFeedback({
  required String id,
  bool? like,
  String? comment,
}) async {
  final body = {
    "postId": id,
    "like": like,
    "comment": comment ?? "",
  };

  log("Submitting feedback with body: $body");

  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headers,
      body: jsonEncode(body),
    );

    log("Response status: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      log("Feedback submitted successfully.");
      return true;
    } else {
      log("Failed to submit feedback: ${response.statusCode} ${response.body}");
      return false;
    }
  } catch (e) {
    log("Exception while submitting feedback: $e");
    return false;
  }
}


  Future<List<dynamic>> fetchAllFeedbacks() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feedbacks');
    }
  }

  Future<bool> deleteFeedback(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      log("Failed to delete feedback: ${response.statusCode}");
      return false;
    }
  }
}
