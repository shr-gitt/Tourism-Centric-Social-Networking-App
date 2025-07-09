import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/api_service.dart';
import 'package:frontend/pages/Service/api_service_user.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/feedbacks.dart';

class FullPostPage extends StatefulWidget {
  final String? postId;
  const FullPostPage({super.key, required this.postId});
  @override
  State<FullPostPage> createState() => _FullPostPageState();
}

class _FullPostPageState extends State<FullPostPage> {
  final ApiService api = ApiService();

  late Future<Map<String, dynamic>> postFuture;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;
  Map<String, dynamic>? post;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    postFuture = api.fetchPostById(widget.postId!);
    loadPostAndUser();
  }

  Future<void> loadPostAndUser() async {
    try {
      final fetchedPost = await api.fetchPostById(widget.postId!);
      final userId = fetchedPost['userId'];
      final fetchedUser = await userapi.fetchUserData(userId);

      setState(() {
        post = fetchedPost;
        user = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load post or user: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: postFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final post = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(post['title'] ?? 'Post Details')),
          body: ListView(
            padding: const EdgeInsets.all(5),
            children: [
              GFCard(
                boxFit: BoxFit.cover,
                image: Image.asset('assets/images/_MG_6890.jpeg'),
                title: GFListTile(
                  avatar: GFAvatar(
                    backgroundImage: AssetImage('assets/images/_MG_6890.jpeg'),
                  ),
                  title: Text(user?['userName'] ?? "No username"),
                  subTitle: Text(user?['name'] ?? "No name"),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['title'] ?? 'No Title'),
                    Text(post['location'] ?? 'No Location'),
                    Text(
                      post['content'] ?? 'No Content',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (post['image'] != null &&
                        post['image'] is List &&
                        (post['image'] as List).isNotEmpty)
                      ImageDisplayWithButtons(
                        imageUrls: List<String>.from(
                          (post['image'] as List).where(
                            (img) =>
                                img != null && img is String && img.isNotEmpty,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Feedbacks(post: post),
              const SizedBox(height: 10),

              Text(
                "Comments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
