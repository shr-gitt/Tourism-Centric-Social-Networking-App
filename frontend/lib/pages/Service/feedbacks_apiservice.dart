// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;

class FeedbackService {
  static const String feedbackurl = Constants.feedbackurl;
  static const String posturl = Constants.posturl;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  /// Submit new feedback (like/comment) for a post
  Future<bool> submitFeedback({
    String? UserId,
    String? PostId,
    bool? like,
    String? comment,
  }) async {
    final body = {
      "UserId": UserId,
      "PostId": PostId,
      "like": like,
      "comment": comment ?? "",
    };

    log("Submitting feedback with body: $body");

    try {
      final response = await http.post(
        Uri.parse(feedbackurl),
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
    } finally {
      log("submitFeedback execution completed.");
    }
  }

  /// Fetch all feedbacks from the backend
  Future<List<dynamic>> fetchAllFeedbacks() async {
    try {
      final response = await http.get(Uri.parse(feedbackurl), headers: _headers);

      if (response.statusCode == 200) {
        log('Fetched all feedbacks');
        return jsonDecode(response.body);
      } else {
        log('Error body in fetchAllFeedbacks: ${response.body}');
        throw Exception('Failed to load feedbacks');
      }
    } catch (e) {
      log('Exception in fetchAllFeedbacks: $e');
      rethrow;
    } finally {
      log("fetchAllFeedbacks execution completed.");
    }
  }

  /// Fetch a specific feedback by its id
  Future<Map<String, dynamic>> fetchFeedbackById(String feedbackid) async {
    try {
      final response = await http.get(
        Uri.parse('$feedbackurl/$feedbackid'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load feedback');
      }
    } catch (e) {
      log('Exception in fetchFeedbackById: $e');
      rethrow;
    } finally {
      log("fetchFeedbackById execution completed.");
    }
  }

  /// Fetch all feedbacks for a specific postId
  Future<List<dynamic>> fetchFeedbacksByPostId(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$feedbackurl/post/$postId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load feedbacks for post $postId');
      }
    } catch (e) {
      log('Exception in fetchFeedbacksByPostId: $e');
      rethrow;
    } finally {
      log("fetchFeedbacksByPostId execution completed.");
    }
  }

  /// Edit feedback by feedbackId
  Future<bool> editFeedbackById(
    String? uid,
    String? pid,
    String? feedbackId, {
    bool? like,
    String? comment,
  }) async {
    if (feedbackId == null) {
      log("editFeedbackById called with null feedbackId");
      return false;
    }

    final url = Uri.parse('$feedbackurl/$feedbackId');
    final body = <String, dynamic>{};
    if (like != null) body['like'] = like;
    if (comment != null) body['comment'] = comment;

    log("PATCH Body: $body");

    try {
      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        log("Failed to update feedback: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      log("Exception in editFeedbackById: $e");
      return false;
    } finally {
      log("editFeedbackById execution completed.");
    }
  }

  /// Delete feedback by feedbackId
  Future<bool> deleteFeedbackById(String feedbackId) async {
    try {
      final response = await http.delete(
        Uri.parse('$feedbackurl/$feedbackId'),
        headers: _headers,
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        log("Failed to delete feedback: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      log("Exception in deleteFeedbackById: $e");
      return false;
    } finally {
      log("deleteFeedbackById execution completed.");
    }
  }
}
