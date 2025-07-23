import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/feedbacks_apiconnect.dart';
import 'package:frontend/pages/Service/feedbacks_apiservice.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/getwidget.dart';

class Comments extends StatefulWidget {
  final Map<String, dynamic> post;
  final FocusNode? focusNode;

  const Comments({super.key, required this.post, this.focusNode});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
  final FeedbackService api = FeedbackService();
  late Future<List<dynamic>> commentsFuture;
  final Map<String, bool> _isEditing = {};

  @override
  void initState() {
    super.initState();
    commentsFuture = api.fetchAllFeedbacks();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> sendComment(String comment) async {
    log("User comment: $comment");
    final postId = widget.post['postId'];
    final success = await ApiconnectFeedbacks(
      PostId: postId,
    ).addComment(comment);
    if (!mounted) return;
    if (success) {
      _commentController.clear();
      setState(() {
        commentsFuture = api.fetchFeedbacksByPostId(postId);
      });
    }
  }

  Future<void> _deleteComment(String commentId) async {
    log('Attempting to delete comment with id: $commentId');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiconnectFeedbacks(
        PostId: widget.post['postId'],
        feedbackId: commentId,
      ).remove();
      if (!mounted) return;
      setState(() {
        commentsFuture = api.fetchFeedbacksByPostId(widget.post['postId']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.post['postId'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          minLines: 1,
          maxLines: 10,
          focusNode: widget.focusNode,
          controller: _commentController,
          decoration: InputDecoration(
            hintText: "Add a comment...",
            border: const OutlineInputBorder(),
            suffixIcon: ElevatedButton(
              onPressed: () {
                final commentText = _commentController.text.trim();
                if (commentText.isNotEmpty) {
                  sendComment(commentText);
                  _commentController.clear();

                  setState(() {
                    commentsFuture = api.fetchAllFeedbacks();
                  });
                }
              },
              child: const Text("Submit"),
            ),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final comments = snapshot.data!;
            log('All comments: ${comments.toString()}');

            List<Map<String, dynamic>> filteredComments = comments
                .where((comment) {
                  final String? commentPostId = comment['postId'];
                  log('commentPostId is:$commentPostId and postId:$postId');
                  return commentPostId == postId && comment['comment'] != '';
                })
                .cast<Map<String, dynamic>>()
                .toList();

            log('Filtered comments: ${filteredComments.toString()}');

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredComments.length,
              itemBuilder: (context, index) {
                final comment = filteredComments[index];
                final commentId = comment['feedbackId'];
                final isEditing = _isEditing[commentId] ?? false;
                final TextEditingController editController =
                    TextEditingController(text: comment['comment']);

                return GFCard(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Avatar(
                              data: comment,
                              isPost: false,
                              selfPost: false,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (String value) async {
                              log('value=$value');
                              if (value == 'edit') {
                                setState(() {
                                  _isEditing[commentId] = true;
                                });
                              } else if (value == 'delete') {
                                await _deleteComment(commentId);
                              }
                            },
                            itemBuilder: (BuildContext context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      isEditing
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: editController,
                                  decoration: const InputDecoration(
                                    hintText: "Edit comment",
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: null,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isEditing[commentId] = false;
                                        });
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final updatedComment = editController
                                            .text
                                            .trim();
                                        if (updatedComment.isNotEmpty) {
                                          log(
                                            'Saving edited comment: $updatedComment',
                                          );
                                          await ApiconnectFeedbacks(
                                            PostId: postId,
                                            feedbackId: commentId,
                                          ).editComment(updatedComment);

                                          setState(() {
                                            _isEditing[commentId] = false;
                                            commentsFuture = api
                                                .fetchFeedbacksByPostId(postId);
                                          });
                                        }
                                      },
                                      child: const Text("Save"),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Text(
                              comment['comment'] ?? 'No comment',
                              style: const TextStyle(fontSize: 14),
                            ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
