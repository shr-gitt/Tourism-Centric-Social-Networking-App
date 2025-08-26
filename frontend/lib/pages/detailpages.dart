import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Postpages/displaymultiplepost.dart';
import 'package:frontend/pages/Userpages/view_user.dart';
import 'package:frontend/pages/decorhelper.dart';

class DetailPage extends StatefulWidget {
  final String searchQuery;

  const DetailPage({super.key, required this.searchQuery});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final UserService userService = UserService();
  final ApiService postService = ApiService();

  late Future<List<Map<String, dynamic>>> usersFuture;
  late Future<List<Map<String, dynamic>>> postsFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = userService.fetchAllUsers();
    postsFuture = postService.fetchPosts().then(
      (posts) => posts.cast<Map<String, dynamic>>().toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.searchQuery.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text('Results for "${widget.searchQuery}"')),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: Future.wait([usersFuture, postsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data![0];
          final posts = snapshot.data![1];

          final filteredUsers = users.where((user) {
            final name = (user['name'] ?? '').toLowerCase();
            final username = (user['userName'] ?? '').toLowerCase();
            return name.contains(query) || username.contains(query);
          }).toList();

          final filteredPosts = posts.where((post) {
            final title = (post['title'] ?? '').toLowerCase();
            final content = (post['content'] ?? '').toLowerCase();
            return title.contains(query) || content.contains(query);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (filteredUsers.isNotEmpty) ...[
                  const Text(
                    'Users',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...filteredUsers.map(
                    (user) => DecorHelper().buildSettingCard(
                      title: user['name'] ?? 'No Name',
                      subtitle: user['userName'] ?? '',
                      icon: Icons.person,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewUser(username: query.trim()),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (filteredPosts.isNotEmpty) ...[
                  const Text(
                    'Posts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...filteredPosts.map(
                    (post) => Displaymultiplepost(post: post, state: false),
                  ),
                ],
                if (filteredUsers.isEmpty && filteredPosts.isEmpty)
                  const Center(child: Text('No results found')),
              ],
            ),
          );
        },
      ),
    );
  }
}
