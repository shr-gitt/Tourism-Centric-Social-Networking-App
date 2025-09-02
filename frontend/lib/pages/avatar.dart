import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/report_apiservice.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Userpages/view_user.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Postpages/deletepost.dart';
import 'package:frontend/pages/Postpages/editpost.dart';

class Avatar extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool isPost;
  final bool selfPost;

  const Avatar({
    super.key,
    required this.data,
    required this.isPost,
    required this.selfPost,
  });

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

  void _onReported(String postId) async {
    String? selectedReason;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Why are you reporting this post?'),
                  RadioListTile<String>(
                    title: const Text('Wrong Community'),
                    value: 'Wrong Community',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Spam'),
                    value: 'Spam',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text(
                    'Report',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    if (selectedReason != null) {
                      Navigator.of(context).pop(true);
                    } else {
                      // Show alert to select a reason
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a reason')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      String? userId = await AuthStorage.getUserName();
      // Send the reason to your API (if supported)
      final success = await ReportApiservice().reportPost(
        userId: userId,
        postId: postId,
        reason: selectedReason,
      );

      if (context.mounted) {
        //Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Post reported for "$selectedReason"'
                  : 'Failed to report post',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPost = widget.isPost;
    final data = widget.data;
    final selfPost = widget.selfPost;
    String? imageUrl;
    if (user != null &&
        user!['image'] != null &&
        user!['image'].toString().isNotEmpty) {
      imageUrl = 'https://localhost:5259${user!['image']}';
    } else {
      imageUrl = 'https://localhost:5259/Images/profile_placeholder.jpg';
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewUser(username: user?['userName']),
              ),
            );
          },
          child: GFAvatar(
            radius: isPost ? 20 : 15,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),

        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ViewUser(username: user?['userName']),
                  ),
                ),

                child: Text(
                  user?['userName'] ?? "No username",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              if (isPost)
                Text(
                  user?['name'] ?? "No name",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
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

        if (isPost && !selfPost)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              final String? postId = data['postId'];
              if (postId == null) return;

              _onReported(postId);
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem<String>(value: 'report', child: Text('Report')),
            ],
          ),
      ],
    );
  }
}
