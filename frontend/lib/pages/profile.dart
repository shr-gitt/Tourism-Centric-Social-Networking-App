import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/posts.dart';
import 'package:frontend/pages/settings.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? uid;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthStorage.getUserId();
    log('userId is $userId');
    final fetchedUser = await userapi.fetchUserData(userId!);
    if (!mounted) return;
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
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
                      ? NetworkImage(user!['image'])
                      : null,
                  child: user?['image'] == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                //Icon(Icons.person, size: 80),
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
                IconButton(
                  onPressed: () {
                    log('Settings button pressed');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Settings()),
                    );
                  },
                  icon: Icon(Icons.settings),
                ),
              ],
            ),
          ),
          const Divider(height: 10, thickness: 2, color: Colors.black),
          Expanded(child: PostsPage(state: true)),
        ],
      ),
    );
  }
}
