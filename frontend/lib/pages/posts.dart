import 'package:flutter/material.dart';
import 'package:frontend/api_service.dart';
import 'package:frontend/pages/Service/displaymultiplepost.dart';
import 'package:frontend/pages/search.dart';

class PostsPage extends StatefulWidget {
  final bool state;
  const PostsPage({super.key, this.state = false});

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
              Search();
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
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Displaymultiplepost(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}
