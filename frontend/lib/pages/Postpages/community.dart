import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Postpages/displaymultiplepost.dart';

class CommunityPage extends StatefulWidget {
  final String communityName;
  final bool state;
  final Map<String, dynamic>? post;

  const CommunityPage({
    super.key,
    required this.communityName,
    this.state = false,
    this.post,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
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
      appBar: widget.state ? null : AppBar(title: Text(widget.communityName)),
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
              List<Map<String, dynamic>> filteredPosts = posts
                  .where((post) {
                    final String? postUserId = post['userId'];
                    final String? postCommunity = post['community'];

                    // Filter out own posts and select posts only from the specified community
                    return postCommunity == widget.communityName &&
                        postUserId != uid; // Exclude the current user's posts
                  })
                  .cast<Map<String, dynamic>>()
                  .toList();

              filteredPosts.shuffle();

              if (filteredPosts.isEmpty) {
                return const Center(child: Text("No posts available"));
              }

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
