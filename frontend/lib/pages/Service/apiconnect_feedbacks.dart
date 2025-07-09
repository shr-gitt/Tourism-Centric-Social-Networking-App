// ignore_for_file: non_constant_identifier_names

import 'package:frontend/pages/Service/api_service_feedbacks.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'dart:developer';

class ApiconnectFeedbacks {
  final String? PostId;
  final String? UserId;
  final String? feedbackId;
  final bool? like;
  final String? comment;

  ApiconnectFeedbacks({
    this.PostId,
    this.UserId,
    this.feedbackId,
    this.like,
    this.comment,
  });

  Future<bool> submitFeedback() async {
    final service = FeedbackService();
    String? uid = await AuthStorage.getUserId();
    final success = await service.submitFeedback(
      UserId: uid,
      PostId: PostId,
      like: like,
      comment: comment,
    );

    if (success) {
      log("Feedback submitted successfully.");
    } else {
      log("Failed to submit feedback.");
    }

    return success; // <---- Return success here
  }

  Future<bool> addLike() async {
    String? uid = await AuthStorage.getUserId();
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      like: true,
    ).submitFeedback();
  }

  Future<bool> adddisLike() async {
    String? uid = await AuthStorage.getUserId();
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      like: false,
    ).submitFeedback();
  }

  Future<bool> addComment() async {
    String? uid = await AuthStorage.getUserId();
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      comment: comment,
    ).submitFeedback();
  }

  Future<bool> editReaction(bool like) async {
    String? uid = await AuthStorage.getUserId();
    if (feedbackId == null) {
      log("No feedback ID provided for editing.");
      return false;
    }

    final service = FeedbackService();

    final success = await service.editFeedbackById(
      uid,
      PostId,
      feedbackId,
      like: like,
      comment: comment,
    );

    if (success) {
      log("Feedback updated successfully.");
      return true;
    } else {
      log("Failed to update feedback.");
      return false;
    }
  }

  Future<bool> removeReaction() async {
    if (feedbackId == null) {
      log("No feedback ID provided for removal.");
      return false;
    }

    final service = FeedbackService();

    final success = await service.deleteFeedbackById(feedbackId!);

    if (success) {
      log("Reaction removed successfully.");
      return true;
    } else {
      log("Failed to remove reaction.");
      return false;
    }
  }
}
