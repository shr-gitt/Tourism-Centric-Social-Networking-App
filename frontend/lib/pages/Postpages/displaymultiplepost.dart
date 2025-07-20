import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:frontend/pages/Feedbackpages/feedbacks.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Postpages/fullpost.dart';
import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/Service/feedbacks_apiservice.dart';

class Displaymultiplepost extends StatefulWidget {
  //final String? id;
  final Map<String, dynamic> post;
    final bool state;

  const Displaymultiplepost({super.key, required this.post, required this.state});

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
    final userData = await userapi.fetchUserData(userId); // cleaner
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullPostPage(postId: post['postId'], scrollToComment: false,state: widget.state,),
          ),
        );
      },

      child: GFCard(
        boxFit: BoxFit.cover,
        image: Image.asset('assets/images/_MG_6890.jpeg'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(data: post, isPost: true),
            ListTile(
              title: Text(
                post['title'] ?? 'No Title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['location'] ?? 'No Location'),
                  Text(
                    post['content'] ?? 'No Content',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullPostPage(
                            postId: post['postId'],
                            scrollToComment: false,
                            state:widget.state,
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
