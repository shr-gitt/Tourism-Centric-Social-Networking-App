import 'package:flutter/widgets.dart';
import 'package:frontend/pages/api_service_feedbacks.dart';
import 'dart:developer';

class ApiconnectFeedbacks {
  final String? postId;
  final String? feedbackId;
  final bool? like;
  final String? comment;

  ApiconnectFeedbacks({this.postId, this.feedbackId, this.like, this.comment});

  Future<void> submitFeedback(BuildContext context) async {
    final service = FeedbackService();

    final success = await service.submitFeedback(
      id: postId,
      like: like,
      comment: comment,
    );

    if (success) {
      log("Feedback submitted successfully.");
    } else {
      log("Failed to submit feedback.");
    }
  }

  Future<void> addLike(BuildContext context) async {
    await ApiconnectFeedbacks(
      postId: postId,
      like: true,
    ).submitFeedback(context);
  }

  Future<void> adddisLike(BuildContext context) async {
    await ApiconnectFeedbacks(
      postId: postId,
      like: false,
    ).submitFeedback(context);
  }

  Future<void> addComment(BuildContext context) async {
    await ApiconnectFeedbacks(
      postId: postId,
      comment: comment,
    ).submitFeedback(context);
  }

  Future<void> editReaction(BuildContext context,bool like) async {
    //Edit reaction works only when a liked post is disliked and then disliked but doesn't work when a liked post is directly disliked
    if (feedbackId == null) {
      log("No feedback ID provided for editing.");
      return;
    }

    final service = FeedbackService();

    final success = await service.editFeedbackById(
      postId,
      feedbackId!,
      like: like,
      comment: comment,
    );

    if (success) {
      log("Feedback updated successfully.");
    } else {
      log("Failed to update feedback.");
    }
  }

  Future<void> removeReaction(BuildContext context) async {
    if (feedbackId == null) {
      log("No feedback ID provided for removal.");
      return;
    }

    final service = FeedbackService();

    final success = await service.deleteFeedbackById(feedbackId!);

    if (success) {
      log("Reaction removed successfully.");
    } else {
      log("Failed to remove reaction.");
    }
  }
}
