import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Postpages/deletepost.dart';
import 'package:frontend/pages/Postpages/editpost.dart';

class Avatar extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isPost;
  final bool selfPost;

  const Avatar({super.key, required this.data, required this.isPost, required this.selfPost});

  @override
  State<Avatar> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = widget.data['userId'];
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
    final isPost = widget.isPost;
    final data = widget.data;
    final selfPost=widget.selfPost;

    return Row(
      children: [
        GFAvatar(
          radius: isPost ? 25 : 15,
          backgroundImage: user?['image'] != null
              ? NetworkImage('https://localhost:5259${user!['image']}')
              : null,

          child: user?['image'] == null
              ? Icon(Icons.person, size: isPost ? 30 : 20)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?['userName'] ?? "No username",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              if (isPost)
                Text(
                  user?['name'] ?? "No name",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ],
          ),
        ),
        if (isPost && selfPost)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              final String? postId = data['postId'];
              if (postId == null) return;

              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editpost(postId: postId),
                  ),
                );
              } else if (value == 'delete') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Deletepost(id: postId),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
            ],
          ),
      ],
    );
  }
}
