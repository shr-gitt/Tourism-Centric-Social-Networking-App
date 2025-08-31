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
  late Future<List<dynamic>> postsFuture;
  Timer? _pollingTimer;
  String _sortMode = 'Latest'; // 'Latest' or 'Explore'
  List<Map<String, dynamic>> _shuffledExplorePosts = [];
  bool _hasShuffledOnce = false;

  @override
  void initState() {
    super.initState();
    postsFuture = api.fetchPosts();
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final newPosts = await api.fetchPosts();
      log('Posts refreshed at ${DateTime.now()}');

      setState(() {
        postsFuture = Future.value(newPosts);

        if (_sortMode == 'Explore' && _hasShuffledOnce) {
          final fetchedPosts = newPosts.cast<Map<String, dynamic>>();
          final newFiltered = fetchedPosts.where((post) {
            final String? postUserId = post['userId'];
            return !(widget.ownProfile ||
                postUserId == widget.otheruserUsername);
          }).toList();

          // Add only new posts that aren't already in _shuffledExplorePosts
          final existingIds = _shuffledExplorePosts.map((e) => e['id']).toSet();
          final newOnes = newFiltered
              .where((post) => !existingIds.contains(post['id']))
              .toList();

          newOnes.shuffle(); // Shuffle only the new additions
          _shuffledExplorePosts.addAll(
            newOnes,
          ); // Add to existing shuffled list
        }
      });
    });
  }

  Future<void> _refreshPosts() async {
    final newPosts = await api.fetchPosts();

    setState(() {
      postsFuture = Future.value(newPosts);
      _hasShuffledOnce = false; // reset shuffle on manual refresh
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
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

              /// FILTERING LOGIC
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
              /*
              if (!widget.ownProfile) {
                filteredPosts.shuffle();
              }*/

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

              return filteredPosts.isEmpty
                  ? const Center(child: Text("No posts available"))
                  : RefreshIndicator(
                      onRefresh: _refreshPosts,
                      child: ListView.builder(
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return Displaymultiplepost(
                            post: filteredPosts[index],
                            state: widget.ownProfile,
                          );
                        },
                      ),
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
