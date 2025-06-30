import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class FeedbackService {
  static const String baseUrl = 'http://localhost:5259/api/feedbacks';

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// Submit new feedback (like/comment) for a post
  Future<bool> submitFeedback({String? id, bool? like, String? comment}) async {
    final body = {"postId": id, "like": like, "comment": comment ?? ""};

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
        log(
          "Failed to submit feedback: ${response.statusCode} ${response.body}",
        );
        return false;
      }
    } catch (e) {
      log("Exception while submitting feedback: $e");
      return false;
    }
  }

  /// Fetch all feedbacks from the backend
  Future<List<dynamic>> fetchAllFeedbacks() async {
    final response = await http.get(Uri.parse(baseUrl), headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feedbacks');
    }
  }

  /// Fetch a specific feedback by its id
  Future<Map<String, dynamic>> fetchFeedbackById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feedback');
    }
  }

  /// Fetch all feedbacks for a specific postId
  Future<List<dynamic>> fetchFeedbacksByPostId(String postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/post/$postId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feedbacks for post $postId');
    }
  }

  Future<bool> editFeedbackById(
    String? id,
    String? feedbackId, {
    bool? like,
    String? comment,
  }) async {
    if (feedbackId == null) {
      log("editFeedbackById called with null feedbackId");
      return false;
    }

    final url = Uri.parse('$baseUrl/$feedbackId');
    final body = {"id": feedbackId,"postId":id, "like": like, "comment": comment ?? ""};

    /*final body = <String, dynamic>{'id': feedbackId};
    if (like != null) body['like'] = like;
    if (comment != null) body['comment'] = comment;*/

    final response = await http.patch(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      log(
        "Failed to update feedback: ${response.statusCode} - ${response.body}",
      );
      return false;
    }
  }

  /// Delete feedback by feedbackId
  Future<bool> deleteFeedbackById(String feedbackId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$feedbackId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      log(
        "Failed to delete feedback: ${response.statusCode} - ${response.body}",
      );
      return false;
    }
  }
}
