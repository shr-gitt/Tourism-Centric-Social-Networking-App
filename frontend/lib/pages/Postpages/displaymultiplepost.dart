import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/community_banner.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:frontend/pages/Feedbackpages/feedbacks.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Postpages/fullpost.dart';
import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/Service/feedbacks_apiservice.dart';
import 'package:intl/intl.dart';

class Displaymultiplepost extends StatefulWidget {
  //final String? id;
  final Map<String, dynamic> post;
  final bool state;

  const Displaymultiplepost({
    super.key,
    required this.post,
    required this.state,
  });

  @override
  State<Displaymultiplepost> createState() => _DisplaymultiplepostState();
}

class _DisplaymultiplepostState extends State<Displaymultiplepost> {
  final FeedbackService api = FeedbackService();
  late Future<List<dynamic>> feedbacksFuture;
  String? id;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = widget.post['userId'];
    final userData = await userapi.fetchUserData(userId);
    if (userData != null) {
      if (!mounted) return;
      setState(() {
        user = userData;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    log('Full post object: $post');
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullPostPage(
              postId: post['postId'],
              scrollToComment: false,
              state: widget.state,
            ),
          ),
        );
      },

      child: GFCard(
        boxFit: BoxFit.cover,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommunityBanner(data: post['community'] ?? "", isPost: true),
            const SizedBox(height: 3),
            const Divider(height: 5, thickness: 1, color: Colors.grey),
            const SizedBox(height: 8),

            Avatar(data: post, isPost: true, selfPost: widget.state),
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  Text(
                    post['location'] ?? 'No Location',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Builder(
                    builder: (context) {
                      final rawDate = post['created'];
                      final parsedDate = DateTime.tryParse(rawDate);
                      final formattedDate = parsedDate != null
                          ? DateFormat('yyyy-MM-dd').format(parsedDate)
                          : 'Invalid date';
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  Text(
                    post['content'] ?? 'No Content',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullPostPage(
                            postId: post['postId'],
                            scrollToComment: false,
                            state: widget.state,
                          ),
                        ),
                      );
                    },
                    child: const Text("Show more"),
                  ),
                  if (post['image'] != null &&
                      post['image'] is List &&
                      (post['image'] as List).isNotEmpty) ...[
                    ImageDisplayWithButtons(
                      imageUrls: List<String>.from(
                        (post['image'] as List).where(
                          (img) =>
                              img != null && img is String && img.isNotEmpty,
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox.shrink(),

                  const SizedBox(height: 10),
                  const Divider(height: 0, thickness: 1, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),

        buttonBar: GFButtonBar(children: [Feedbacks(post: post)]),
      ),
    );
  }
}
