import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/apiconnect_feedbacks.dart';
import 'package:frontend/pages/Service/api_service_feedbacks.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/getwidget.dart';

class Comments extends StatefulWidget {
  final Map<String, dynamic> post;
  final FocusNode? focusNode; // Add this

  const Comments({super.key, required this.post, this.focusNode});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController _commentController = TextEditingController();
  final FeedbackService api = FeedbackService();
  late Future<List<dynamic>> commentsFuture;

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
    final post = widget.post;
    final postId = post['postId'];
    await ApiconnectFeedbacks(PostId: postId).addComment(comment);
  }

  void _showEditDialog(Map<String, dynamic> comment) {
    final TextEditingController editController = TextEditingController(
      text: comment['comment'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Edit your comment"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedComment = editController.text.trim();
                log('editted comment is: $updatedComment');
                if (updatedComment.isNotEmpty) {
                  await ApiconnectFeedbacks(
                    PostId: widget.post['postId'],
                    feedbackId: comment['feedbackId'], // pass feedback ID!
                  ).editComment(updatedComment);
                  Navigator.pop(context);

                  setState(() {
                    commentsFuture = api.fetchAllFeedbacks();
                  });
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    await ApiconnectFeedbacks(
      PostId: widget.post['postId'],
      feedbackId: commentId,
    ).remove();
    log('Deleted the comment');

    setState(() {
      commentsFuture = api.fetchAllFeedbacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final postId = post['postId'];
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
            border: OutlineInputBorder(),
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
              child: Text("Submit"),
            ),
          ),
        ),
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
            /*return FutureBuilder<String?>(
              future: AuthStorage.getUserId(),
              builder: (context, userIdSnapshot) {
                if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (userIdSnapshot.hasError) {
                  return Center(child: Text('Error: ${userIdSnapshot.error}'));
                }*/
            List<Map<String, dynamic>> filteredComments = comments
                .where((comment) {
                  final String? commentPostId = comment['postId'];
                  log('commentPostId is:$commentPostId and postId:$postId');
                  return commentPostId == postId && comment['comment'] != '';
                })
                .cast<Map<String, dynamic>>()
                .toList();
            log('Filtered comments: ${filteredComments.toString()}');

            /*return ListView.builder(
              itemCount: filteredComments.length,
              itemBuilder: (context, index) {
                return GFCard(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: filteredComments.map((comment) {
                      return ListTile(
                        title: Text(comment['user'] ?? 'Unknown User'),
                        subtitle: Text(comment['text'] ?? 'comments'),
                      );
                    }).toList(),
                  ),
                );
              },
            );*/
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredComments.length,
              itemBuilder: (context, index) {
                final comment = filteredComments[index];

                return GFCard(
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Avatar(data: comment, isPost: false)),
                          PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'edit') {
                                log('value=$value');
                                _showEditDialog(comment);
                              } else if (value == 'delete') {
                                log('value=$value');
                                _deleteComment(comment['feedbackId']);
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
                      Text(
                        comment['comment'] ?? 'Cannot fetch comment',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          //);
          //},
        ),
      ],
    );
  }
}
