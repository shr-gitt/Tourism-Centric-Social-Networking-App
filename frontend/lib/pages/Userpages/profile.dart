import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
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

    Future.delayed(Duration(seconds: 2), () {
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage(asguest: true)),
        );
      }
    });
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthStorage.getUserName();
    log('in profile page, userId is $userId');

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
      String? imageUrl;
      if (user != null &&
          user!['image'] != null &&
          user!['image'].toString().isNotEmpty) {
        imageUrl = 'https://localhost:5259${user!['image']}';
      } else {
        imageUrl = 'https://localhost:5259/Images/profile_placeholder.jpg';
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          automaticallyImplyLeading: false,
        ),
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
                    backgroundImage: NetworkImage(imageUrl),
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
            Expanded(child: PostsPage(ownProfile: true)),
          ],
        ),
      );
    } else {
      // If user is null or loading, show loading indicator
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}
