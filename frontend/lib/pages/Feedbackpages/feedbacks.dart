import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/feedbacks_apiconnect.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/feedbacks_apiservice.dart';
import 'package:frontend/pages/Postpages/fullpost.dart';
import 'package:getwidget/getwidget.dart';

class Feedbacks extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onCommentPressed;

  const Feedbacks({super.key, required this.post, this.onCommentPressed});

  @override
  State<Feedbacks> createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {
  final api = FeedbackService();
  Future<List<dynamic>> feedbacksFuture = Future.value([]);
  Timer? _pollingTimer;

  bool _isLiked = false;
  bool _isDisLiked = false;
  String? feedbackId;

  @override
  void initState() {
    super.initState();
    _refreshPosts();
    //feedbackinfo();
    _startPolling();
  }

  // Change feedbackinfo to return the updated feedbacks list
  Future<List<dynamic>> feedbackinfo() async {
    final postId = widget.post['postid'] ?? widget.post['postId'];
    String? userId = await AuthStorage.getUserName();
    if (userId == null) {
      return [];
    }

    final feedbacks = await api.fetchAllFeedbacks();

    final postFeedbacks = feedbacks.where((f) {
      return (f['postId'] == postId || f['PostId'] == postId) &&
          (f['userId'] == userId);
    }).toList();

    if (mounted) {
      setState(() {
        if (postFeedbacks.isNotEmpty) {
          final userFeedback = postFeedbacks[0];
          _isLiked = userFeedback['like'] == true;
          _isDisLiked = userFeedback['like'] == false;
          feedbackId = userFeedback['feedbackId'];
        } else {
          _isLiked = false;
          _isDisLiked = false;
          feedbackId = null;
        }
      });
    }

    return feedbacks;
  }

  // Update _startPolling
  void _startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      final refreshedFeedbacks = await feedbackinfo();
      log('Feedbacks refreshed at ${DateTime.now()}');

      setState(() {
        feedbacksFuture = Future.value(refreshedFeedbacks); // Update the future
      });
    });
  }

  Future<void> _refreshPosts() async {
    final refreshedFeedbacks = await feedbackinfo();
    if (mounted) {
      setState(() {
        feedbacksFuture = Future.value(refreshedFeedbacks); // Update the future
      });
    }
  }

  Future<void> edit(String state, String? uid, String? pid) async {
    final feedbacks = await feedbacksFuture;

    log('For editting, postId is $pid and userId is $uid');
    final postFeedbacks = feedbacks
        .where((f) => (f['postId'] == pid && (f['userId'] == uid)))
        .toList();
    log('postfeedback info:$postFeedbacks');
    if (postFeedbacks.isNotEmpty) {
      feedbackId = postFeedbacks[0]['feedbackId'];
    } else {
      feedbackId = null;
      log('Feedbackid null');
    }
    log('feedback id is : $feedbackId');

    if (state == 'remove') {
      try {
        final success = await ApiconnectFeedbacks(
          feedbackId: feedbackId,
        ).remove();
        if (success) {
          log('Like removed');
        }
      } catch (e) {
        log('Could not remove like');
      }
    } else if (state == 'like') {
      try {
        final success = await ApiconnectFeedbacks(
          feedbackId: feedbackId,
        ).editReaction(true);
        if (success) {
          log('Editted to like');
        }
      } catch (e) {
        log('Could not edit to like');
      }
    } else if (state == 'dislike') {
      try {
        final success = await ApiconnectFeedbacks(
          feedbackId: feedbackId,
        ).editReaction(false);
        if (success) {
          log('Editted to dislike');
        }
      } catch (e) {
        log('Could not edit to dislike');
      }
    }
    final updatedFeedbacks = await api.fetchAllFeedbacks();
    setState(() {
      feedbacksFuture = Future.value(updatedFeedbacks);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final postId = post['postId'];

    return FutureBuilder<List<dynamic>>(
      future: feedbacksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var feedbacks = snapshot.data!;

          // Find the feedback for the current post
          var postFeedback = feedbacks
              .where((f) => f['postId'] == postId)
              .toList();

          int likeCount = postFeedback.fold(
            0,
            (sum, f) => sum + (f['like'] == true ? 1 : 0),
          );
          int dislikeCount = postFeedback.fold(
            0,
            (sum, f) => sum + (f['like'] == false ? 1 : 0),
          );
          /*int commentCount = postFeedback.isNotEmpty
              ? postFeedback[0]['commentCount'] ?? 0
              : 0;

          int likeCount = post['feedback']?['likeCount'] ?? 0;
          int dislikeCount = post['feedback']?['dislikeCount'] ?? 0;*/

          int commentCount = post['feedback']?['commentCount'] ?? 0;
          return GFButtonBar(
            children: [
              RefreshIndicator(
                onRefresh: _refreshPosts,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    GFButton(
                      onPressed: () async {
                        String? uid = await AuthStorage.getUserName();
                        log('post:$post');
                        log('postid:$postId');
                        if (uid != null) {
                          if (_isLiked) {
                            setState(() {
                              _isLiked = false;
                              likeCount--;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            edit('remove', uid, postId);
                          } else if (!_isLiked && _isDisLiked) {
                            setState(() {
                              _isLiked = true;
                              _isDisLiked = false;
                              likeCount++;
                              dislikeCount--;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            edit('like', uid, postId);
                          } else {
                            setState(() {
                              _isLiked = true;
                              likeCount++;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            try {
                              final success = await ApiconnectFeedbacks(
                                UserId: uid,
                                PostId: postId,
                              ).addLike();
                              if (success) {
                                log('Like added');
                                final updatedFeedbacks = await api
                                    .fetchAllFeedbacks();
                                setState(() {
                                  feedbacksFuture = Future.value(
                                    updatedFeedbacks,
                                  );
                                });
                              }
                            } catch (e) {
                              log('Could not add like');
                            }
                          }
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login to interact")),
                          );
                        }
                      },
                      text: "$likeCount",
                      icon: Icon(
                        _isLiked
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        color: _isLiked
                            ? Colors.grey
                            : Theme.of(context).iconTheme.color,
                      ),
                      type: GFButtonType.transparent,
                    ),
                    GFButton(
                      onPressed: () async {
                        String? uid = await AuthStorage.getUserName();
                        if (uid != null) {
                          if (_isDisLiked) {
                            setState(() {
                              _isDisLiked = false;
                              dislikeCount--;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            edit('remove', uid, postId);
                          } else if (!_isDisLiked && _isLiked) {
                            setState(() {
                              _isDisLiked = true;
                              _isLiked = false;
                              dislikeCount++;
                              likeCount--;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            edit('dislike', uid, postId);
                          } else {
                            setState(() {
                              _isDisLiked = true;
                              dislikeCount++;
                              log(
                                'like count is $likeCount and dislike is $dislikeCount',
                              );
                            });
                            try {
                              String? uid = await AuthStorage.getUserName();
                              log('post:$post');
                              log('postid:$postId');
                              final success = await ApiconnectFeedbacks(
                                UserId: uid,
                                PostId: postId,
                              ).adddisLike();
                              if (success) {
                                log('Dislike added');
                                final updatedFeedbacks = await api
                                    .fetchAllFeedbacks();
                                setState(() {
                                  feedbacksFuture = Future.value(
                                    updatedFeedbacks,
                                  );
                                });
                              }
                            } catch (e) {
                              log('Could not add dislike');
                            }
                          }
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login to interact")),
                          );
                        }
                      },
                      text: "$dislikeCount",
                      icon: Icon(
                        _isDisLiked
                            ? Icons.thumb_down_alt
                            : Icons.thumb_down_alt_outlined,
                        color: _isDisLiked
                            ? Colors.grey
                            : Theme.of(context).iconTheme.color,
                      ),
                      type: GFButtonType.transparent,
                    ),
                    GFButton(
                      onPressed: () {
                        if (widget.onCommentPressed != null) {
                          widget.onCommentPressed!();
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullPostPage(
                                postId: post['postId'],
                                scrollToComment: true,
                                state: false,
                              ),
                            ),
                          );
                        }
                      },
                      text: "$commentCount",
                      icon: Icon(Icons.comment_outlined),
                      type: GFButtonType.transparent,
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
