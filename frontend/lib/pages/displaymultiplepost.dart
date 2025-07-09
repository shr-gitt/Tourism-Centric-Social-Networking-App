import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/feedbacks.dart';
import 'package:frontend/pages/Service/api_service_user.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/editpost.dart';
import 'package:frontend/pages/deletepost.dart';
import 'package:frontend/pages/fullpost.dart';
import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/Service/api_service_feedbacks.dart';

class Displaymultiplepost extends StatefulWidget {
  //final String? id;
  final Map<String, dynamic> post;
  const Displaymultiplepost({super.key, required this.post});

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
            builder: (context) => FullPostPage(postId: post['postId']),
          ),
        );
      },

      child: GFCard(
        boxFit: BoxFit.cover,
        image: Image.asset('assets/images/_MG_6890.jpeg'),
        title: GFListTile(
          avatar: GFAvatar(
            backgroundImage: AssetImage('assets/images/_MG_6890.jpeg'),
          ),
          title: Text(user?['userName'] ?? "No username"),
          subTitle: Text(user?['name'] ?? "No name"),
          icon: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              final String? postId = post['postId'];
              if (postId == null) {
                log("Error: post['_id'] is null");
                return;
              }
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editpost(postId: post['postId']),
                  ),
                );
              } else if (value == 'delete') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Deletepost(id: post['postId']),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
