import 'package:flutter/material.dart';
import 'package:frontend/pages/posts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
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
                Icon(Icons.person, size: 80),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Username", style: TextStyle(fontSize: 18)),
                      Text("Name", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Icon(Icons.settings),
              ],
            ),
          ),
          const Divider(height: 10, thickness: 2, color: Colors.black),
          Expanded(child: PostsPage()),
        ],
      ),
    );
  }
}
