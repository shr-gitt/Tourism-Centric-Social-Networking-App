import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Postpages/displaymultiplepost.dart';
import 'package:frontend/pages/search.dart';

class PostsPage extends StatefulWidget {
  final bool state;
  final Map<String, dynamic>? post;

  const PostsPage({super.key, this.state = false, this.post});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final ApiService api = ApiService();
  late Future<List<dynamic>> postsFuture;

  @override
  void initState() {
    super.initState();
    postsFuture = api.fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.state
          ? null
          : AppBar(
              title: const Text('Posts'),
              actions: [
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Search()),
                    );
                  },
                ),
              ],
            ),
      body: FutureBuilder<List<dynamic>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data!;

          // Sort newest first by date (assuming ISO8601 format)
          posts.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['created'] ?? '') ?? DateTime(2000);
            final bDate =
                DateTime.tryParse(b['created'] ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate); // descending: newest first
          });

          return FutureBuilder<String?>(
            future: AuthStorage.getUserName(),
            builder: (context, userIdSnapshot) {
              if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userIdSnapshot.hasError) {
                return Center(child: Text('Error: ${userIdSnapshot.error}'));
              }
              final String? uid = userIdSnapshot.data;
              final bool state = widget.state;
              List<Map<String, dynamic>> filteredPosts = posts
                  .where((post) {
                    final String? postUserId = post['userId'];
                    log('userId:$postUserId and uid:$uid');
                    return state ? postUserId == uid : postUserId != uid;
                  })
                  .cast<Map<String, dynamic>>()
                  .toList();

              return ListView.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  return Displaymultiplepost(
                    post: filteredPosts[index],
                    state: widget.state,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
