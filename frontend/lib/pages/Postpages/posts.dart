import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Postpages/displaymultiplepost.dart';

class PostsPage extends StatefulWidget {
  final bool ownProfile;
  final bool otheruserProfile;
  final String? otheruserUsername;
  final Map<String, dynamic>? post;

  const PostsPage({
    super.key,
    this.ownProfile = false,
    this.otheruserProfile = false,
    this.otheruserUsername,
    this.post,
  });

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
      appBar: (widget.ownProfile || widget.otheruserProfile)
          ? null
          : AppBar(title: const Text('Posts')),
      body: FutureBuilder<List<dynamic>>(
        future: postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];

          // Sort newest first
          posts.sort((a, b) {
            final aDate =
                DateTime.tryParse(a['created'] ?? '') ?? DateTime(2000);
            final bDate =
                DateTime.tryParse(b['created'] ?? '') ?? DateTime(2000);
            return bDate.compareTo(aDate);
          });

          return FutureBuilder<String?>(
            future: AuthStorage.getUserName(), // stored uid from JWT
            builder: (context, userIdSnapshot) {
              if (userIdSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (userIdSnapshot.hasError) {
                return Center(child: Text('Error: ${userIdSnapshot.error}'));
              }

              final String? uid = userIdSnapshot.data;

              /// --- 🔎 FILTERING LOGIC ---
              List<Map<String, dynamic>> filteredPosts = posts
                  .cast<Map<String, dynamic>>()
                  .where((post) {
                    final String? postUserId = post['userId'];
                    log('Checking post: postUserId=$postUserId | uid=$uid');

                    if (widget.ownProfile) {
                      return postUserId == uid;
                    } else if (widget.otheruserProfile &&
                        widget.otheruserUsername != null) {
                      return postUserId == widget.otheruserUsername;
                    } else {
                      // Feed: exclude self’s posts
                      return postUserId != uid;
                    }
                  })
                  .toList();

              if (!widget.ownProfile) {
                filteredPosts.shuffle();
              }

              return filteredPosts.isEmpty
                  ? const Center(child: Text("No posts available"))
                  : ListView.builder(
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        return Displaymultiplepost(
                          post: filteredPosts[index],
                          state: widget.ownProfile,
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
