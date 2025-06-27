import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class ApiconnectFeedbacks {
  final String? id;
  final String postid;
  final bool? like;
  final String? comments;

  ApiconnectFeedbacks(this.id, this.postid, this.like, this.comments);

  static const String baseUrl = "http://localhost:5259/api/feedbacks";

  Map<String, dynamic> _buildRequestBody() {
    return {
      "id": id,
      "post_id": postid,
      "like": like, // null = no reaction
      "comment": comments,
    };
  }

  Future<void> _sendFeedback(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(_buildRequestBody()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Feedback submitted successfully.");
      } else {
        log("Failed to submit feedback: ${response.statusCode}");
      }
    } catch (e) {
      log("Error submitting feedback: $e");
    }
  }

  Future<void> addLike(BuildContext context) async {
    await _sendFeedback(context);
  }

  Future<void> removeLike(BuildContext context) async {
    await ApiconnectFeedbacks(
      id,
      postid,
      null,
      comments,
    )._sendFeedback(context);
  }

  Future<void> adddisLike(BuildContext context) async {
    await _sendFeedback(context);
  }

  Future<void> removedisLike(BuildContext context) async {
    await ApiconnectFeedbacks(
      id,
      postid,
      null,
      comments,
    )._sendFeedback(context);
  }

  Future<void> addComment(BuildContext context) async {
    await ApiconnectFeedbacks(
      id,
      postid,
      like,
      comments,
    )._sendFeedback(context);
  }
}
