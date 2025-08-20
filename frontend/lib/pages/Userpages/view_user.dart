import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/posts.dart';
import 'package:frontend/pages/guest.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';

class ViewUser extends StatefulWidget {
  final String? username;
  const ViewUser({super.key, required this.username});

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  String? uid;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    Future.delayed(Duration(seconds: 2), () {
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Guest()),
        );
      }
    });
  }

  Future<void> _loadUserId() async {
    String? userId = widget.username;
    log('in ViewUser page, userId is $userId');

    if (userId != null) {
      final fetchedUser = await userapi.fetchUserData(userId);
      if (!mounted) return;
      setState(() {
        user = fetchedUser;
      });
    } else {
      setState(() {
        user = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        appBar: AppBar(title: Text('ViewUser')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: user?['image'] != null
                        ? NetworkImage(
                            'https://localhost:5259${user!['image']}',
                          )
                        : null,
                    child: user?['image'] == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?['userName'] ?? "No username",
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          user?['name'] ?? "No name",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 10, thickness: 2, color: Colors.black),
            Expanded(
              child: PostsPage(
                otheruserProfile: true,
                otheruserUsername: widget.username,
              ),
            ),
          ],
        ),
      );
    } else {
      // If user is null or loading, show loading indicator
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
