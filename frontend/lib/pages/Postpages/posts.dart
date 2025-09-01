import 'package:flutter/material.dart';
import 'dart:async';
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

  List<Map<String, dynamic>> posts = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 5;

  final ScrollController _scrollController = ScrollController();

  String _sortMode = 'Latest'; // 'Latest' or 'Explore'
  List<Map<String, dynamic>> _shuffledExplorePosts = [];
  bool _hasShuffledOnce = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        log('In scroll controller, isloading:$isLoading and hasmore:$hasMore');
        // 100 to make it trigger a bit earlier
        if (!isLoading && hasMore) {
          log("Reached bottom of the list. Loading more posts...");
          _fetchPosts();
        }
      }
    });
  }

  Future<void> _fetchPosts() async {
    if (isLoading || !hasMore) {
      return; // Prevent fetch if already loading or no more posts
    }

    log('Fetching posts, currentPage: $currentPage');

    setState(() {
      isLoading = true;
    });

    try {
      final result = await api.fetchfewPosts(currentPage, pageSize);
      final newPosts =
          result['posts']; // assuming your response is structured like this
      final totalCount = result['totalCount'];

      log('Fetched ${newPosts.length} posts.');
      log('Total number of posts is $totalCount');

      if (!mounted) return;
      setState(() {
        posts.addAll(newPosts.cast<Map<String, dynamic>>());

        if (posts.length >= totalCount || newPosts.isEmpty) {
          hasMore = false;
          log('No more posts available.');
        } else {
          hasMore = true;
          currentPage++;
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log('Error fetching posts: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.ownProfile || widget.otheruserProfile)
          ? null
          : AppBar(
              title: const Text('Posts'),
              automaticallyImplyLeading: false,
              actions: [_buildSortDropdown()],
            ),
      body: FutureBuilder<String?>(
        future: AuthStorage.getUserName(),
        builder: (context, userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting ||
              isLoading && posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userIdSnapshot.hasError) {
            return Center(child: Text('Error: ${userIdSnapshot.error}'));
          }

          final String? uid = userIdSnapshot.data;

          // Filter the loaded posts
          List<Map<String, dynamic>> filteredPosts = posts.where((post) {
            final String? postUserId = post['userId'];
            if (widget.ownProfile) {
              return postUserId == uid;
            } else if (widget.otheruserProfile &&
                widget.otheruserUsername != null) {
              return postUserId == widget.otheruserUsername;
            } else {
              return postUserId != uid;
            }
          }).toList();

          // Sort or shuffle
          if (_sortMode == 'Latest') {
            filteredPosts.sort((a, b) {
              final aDate =
                  DateTime.tryParse(a['created'] ?? '') ?? DateTime(2000);
              final bDate =
                  DateTime.tryParse(b['created'] ?? '') ?? DateTime(2000);
              return bDate.compareTo(aDate);
            });
          } else if (_sortMode == 'Explore') {
            if (!_hasShuffledOnce) {
              _shuffledExplorePosts = List.from(filteredPosts)..shuffle();
              _hasShuffledOnce = true;
            }
            filteredPosts = _shuffledExplorePosts;
          }

          if (filteredPosts.isEmpty && !hasMore && !isLoading) {
            return const Center(child: Text("No posts available"));
          }

          return ListView.builder(
            key: const PageStorageKey<String>('postsList'),
            controller: _scrollController,
            itemCount: filteredPosts.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == filteredPosts.length) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Displaymultiplepost(
                post: filteredPosts[index],
                state: widget.ownProfile,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: _sortMode,
      underline: const SizedBox(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _sortMode = newValue;
            _hasShuffledOnce = false; // reset on mode switch
          });
        }
      },

      items: <String>['Latest', 'Explore'].map<DropdownMenuItem<String>>((
        String value,
      ) {
        return DropdownMenuItem<String>(
          value: value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(value),
          ),
        );
      }).toList(),
    );
  }
}
