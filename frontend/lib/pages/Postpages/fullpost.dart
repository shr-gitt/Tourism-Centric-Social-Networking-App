import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/community_banner.dart';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:frontend/pages/Feedbackpages/feedbackscomments.dart';
import 'package:frontend/pages/mainscreen.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';

import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/Feedbackpages/feedbacks.dart';

class FullPostPage extends StatefulWidget {
  final String? postId;
  final bool scrollToComment;
  final bool state;

  const FullPostPage({
    super.key,
    required this.postId,
    required this.scrollToComment,
    required this.state,
  });
  @override
  State<FullPostPage> createState() => _FullPostPageState();
}

class _FullPostPageState extends State<FullPostPage> {
  final GlobalKey _commentKey = GlobalKey();
  final ApiService api = ApiService();

  late Future<Map<String, dynamic>> postFuture;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;
  Map<String, dynamic>? post;
  bool isLoading = true;
  String? errorMessage;
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    postFuture = api.fetchPostById(widget.postId!);
    loadPostAndUser();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.scrollToComment) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (_commentKey.currentContext != null) {
          Scrollable.ensureVisible(
            _commentKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
        if (!mounted) return;
        FocusScope.of(context).requestFocus(_commentFocusNode);
      }
    });
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

  void focusCommentInput() {
    FocusScope.of(context).requestFocus(_commentFocusNode);
    if (_commentKey.currentContext != null) {
      Scrollable.ensureVisible(
        _commentKey.currentContext!,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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
          appBar: AppBar(
            title: Text(post['title'] ?? 'Post Details'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MainScreen(currentIndex: widget.state ? 4 : 0),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(1),
            children: [
              GFCard(
                boxFit: BoxFit.cover,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommunityBanner(
                      data: post['community'] ?? "",
                      isPost: true,
                    ),
                    const SizedBox(height: 3),

                    const Divider(height: 0, thickness: 1, color: Colors.grey),
                    const SizedBox(height: 10),

                    Avatar(data: post, isPost: true, selfPost: widget.state),
                    Text(
                      post['title'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      post['location'] ?? 'No Location',
                      style: TextStyle(fontSize: 12),
                    ),
                    Builder(
                      builder: (context) {
                        final rawDate = post['created'];
                        final parsedDate = DateTime.tryParse(rawDate);
                        final formattedDate = parsedDate != null
                            ? DateFormat('yyyy-MM-dd').format(parsedDate)
                            : 'Invalid date';
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formattedDate,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

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

              const SizedBox(height: 2),

              Feedbacks(post: post, onCommentPressed: focusCommentInput),
              const SizedBox(height: 1),

              Column(
                key: _commentKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "   Comments",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Comments(post: post, focusNode: _commentFocusNode),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
