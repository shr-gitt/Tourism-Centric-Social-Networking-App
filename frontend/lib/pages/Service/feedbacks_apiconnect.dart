// ignore_for_file: non_constant_identifier_names

import 'package:frontend/pages/Service/feedbacks_apiservice.dart';
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
    String? uid = await AuthStorage.getUserName();
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

    return success; 
  }

  Future<bool> addLike() async {
    String? uid = await AuthStorage.getUserName();
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      like: true,
    ).submitFeedback();
  }

  Future<bool> adddisLike() async {
    String? uid = await AuthStorage.getUserName();
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      like: false,
    ).submitFeedback();
  }

  Future<bool> addComment(String comment) async {
    String? uid = await AuthStorage.getUserName();
    log('comment in apiconnect is: $comment and post id is $PostId');
    return await ApiconnectFeedbacks(
      UserId: uid,
      PostId: PostId,
      comment: comment,
    ).submitFeedback();
  }

  Future<bool> editReaction(bool like) async {
    String? uid = await AuthStorage.getUserName();
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

  Future<bool> editComment(String comment) async {
    String? uid = await AuthStorage.getUserName();
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

  Future<bool> remove() async {
    if (feedbackId == null) {
      log("No feedback ID provided for removal.");
      return false;
    }

    final service = FeedbackService();

    final success = await service.deleteFeedbackById(feedbackId!);

    if (success) {
      log("Removed successfully.");
      return true;
    } else {
      log("Failed to remove.");
      return false;
    }
  }
}
