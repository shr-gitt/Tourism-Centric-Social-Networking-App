import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/feedbacks_apiconnect.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/feedbacks_apiservice.dart';
import 'package:frontend/pages/Postpages/fullpost.dart';
import 'package:getwidget/getwidget.dart';

class Feedbacks extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onCommentPressed; // <-- add this

  const Feedbacks({super.key, required this.post, this.onCommentPressed});

  @override
  State<Feedbacks> createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {
  final api = FeedbackService();
  Future<List<dynamic>> feedbacksFuture = Future.value([]);

  bool _isLiked = false;
  bool _isDisLiked = false;
  String? feedbackId;

  @override
  void initState() {
    super.initState();
    final postId = widget.post['postid'] ?? widget.post['postId'];

    AuthStorage.getUserId().then((userId) {
      feedbacksFuture = api.fetchAllFeedbacks().then((feedbacks) {
        final postFeedbacks = feedbacks.where((f) {
          return (f['postId'] == postId || f['PostId'] == postId) &&
              (f['userId'] == userId);
        }).toList();
        if (!mounted) return feedbacks;
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

        return feedbacks;
      });
    });
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
          return GFButtonBar(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GFButton(
                    onPressed: () async {
                      String? uid = await AuthStorage.getUserId();
                      log('post:$post');
                      log('postid:$postId');
                      if (_isLiked) {
                        setState(() {
                          _isLiked = false;
                        });
                        edit('remove', uid, postId);
                      } else if (!_isLiked && _isDisLiked) {
                        setState(() {
                          _isLiked = true;
                          _isDisLiked = false;
                        });
                        edit('like', uid, postId);
                      } else {
                        setState(() {
                          _isLiked = true;
                        });
                        try {
                          final success = await ApiconnectFeedbacks(
                            UserId: uid,
                            PostId: postId,
                          ).addLike();
                          if (success) {
                            log('Like added');
                          }
                        } catch (e) {
                          log('Could not add like');
                        }
                      }
                    },
                    text: "",
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
                      String? uid = await AuthStorage.getUserId();
                      if (_isDisLiked) {
                        setState(() {
                          _isDisLiked = false;
                        });
                        edit('remove', uid, postId);
                      } else if (!_isDisLiked && _isLiked) {
                        setState(() {
                          _isDisLiked = true;
                          _isLiked = false;
                        });
                        edit('dislike', uid, postId);
                      } else {
                        setState(() {
                          _isDisLiked = true;
                        });
                        try {
                          String? uid = await AuthStorage.getUserId();
                          log('post:$post');
                          log('postid:$postId');
                          final success = await ApiconnectFeedbacks(
                            UserId: uid,
                            PostId: postId,
                          ).adddisLike();
                          if (success) {
                            log('Dislike added');
                          }
                        } catch (e) {
                          log('Could not add dislike');
                        }
                      }
                    },
                    text: "",
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
                    text: "",
                    icon: Icon(Icons.comment_outlined),
                    type: GFButtonType.transparent,
                  ),
                  GFButton(
                    onPressed: () {},
                    text: "",
                    icon: Icon(Icons.share),
                    type: GFButtonType.transparent,
                  ),
                ],
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
