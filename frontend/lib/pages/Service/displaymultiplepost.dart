import 'package:flutter/material.dart';
import 'package:frontend/pages/editpost.dart';
import 'package:frontend/pages/deletepost.dart';
import 'package:frontend/pages/Service/apiconnect_feedbacks.dart';
import 'package:frontend/pages/api_service_feedbacks.dart';
import 'dart:convert';

class Displaymultiplepost extends StatefulWidget {
  final String? id;
  final Map<String, dynamic> post;
  const Displaymultiplepost({super.key, this.id, required this.post});

  @override
  State<Displaymultiplepost> createState() => _DisplaymultiplepostState();
}

class _DisplaymultiplepostState extends State<Displaymultiplepost> {
  final FeedbackService api = FeedbackService();
  late Future<List<dynamic>> feedbacksFuture;
  bool _isLiked = false;
  bool _isdisLiked = false;

  String? _feedbackId;

  @override
  void initState() {
    super.initState();
    _refreshFeedbacks();
  }

  void _refreshFeedbacks() {
    setState(() {
      feedbacksFuture = api.fetchAllFeedbacks().then((feedbacks) {
        final postFeedbacks = feedbacks
            .where((f) => f['postId'] == widget.post['id'])
            .toList();

        _isLiked = postFeedbacks.any((f) => f['like'] == true);
        _isdisLiked = postFeedbacks.any((f) => f['like'] == false);

        if (postFeedbacks.isNotEmpty) {
          _feedbackId = postFeedbacks[0]['id'] ?? postFeedbacks[0]['_id'];
        } else {
          _feedbackId = null;
        }

        return feedbacks;
      });
    });
  }

  Future<void> _edit(bool? like) async {
    
    if (_feedbackId == null) return;

    if (like == null) {
      await ApiconnectFeedbacks(
        feedbackId: _feedbackId!,
      ).removeReaction(context);
    } else {
      await ApiconnectFeedbacks(
        feedbackId: _feedbackId!,
        like: like,
      ).editReaction(context);
    }
    _refreshFeedbacks();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              post['title'] ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['location'] ?? 'No Location'),
                Text(post['content'] ?? 'No Content'),
                if (post['image'] != null && post['image'] != '')
                  Image.memory(base64Decode(post['image'])),
                const Divider(height: 10, thickness: 2, color: Colors.black),
                FutureBuilder<List<dynamic>>(
                  future: feedbacksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if (_isLiked) {
                                setState(() {
                                  _isLiked = false;
                                  _isdisLiked = false;
                                });
                                await _edit(null);
                              } else if (!_isLiked && _isdisLiked) {
                                setState(() {
                                  _isLiked = true;
                                  _isdisLiked = false;
                                });
                                await _edit(true);
                              } else {
                                setState(() {
                                  _isLiked = true;
                                  _isdisLiked = false;
                                });
                                if (mounted) {
                                  await ApiconnectFeedbacks(
                                    postId: post['id'],
                                    like: true,
                                  ).addLike(context);
                                }
                                _refreshFeedbacks();
                              }
                            },
                            icon: Icon(
                              _isLiked
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_alt_outlined,
                              color: (_isLiked || _isdisLiked)
                                  ? Colors.grey
                                  : Theme.of(context).iconTheme.color,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              if (_isdisLiked) {
                                setState(() {
                                  _isLiked = false;
                                  _isdisLiked = false;
                                });
                                await _edit(null);
                              } else if (!_isdisLiked && _isLiked) {
                                setState(() {
                                  _isLiked = false;
                                  _isdisLiked = true;
                                });
                                await _edit(false);
                              } else {
                                setState(() {
                                  _isLiked = false;
                                  _isdisLiked = true;
                                });
                                if (mounted) {
                                  await ApiconnectFeedbacks(
                                    postId: post['id'],
                                    like: false,
                                  ).adddisLike(context);
                                }
                                _refreshFeedbacks();
                              }
                            },
                            icon: Icon(
                              _isdisLiked
                                  ? Icons.thumb_down_alt
                                  : Icons.thumb_down_alt_outlined,
                              color: (_isLiked || _isdisLiked)
                                  ? Colors.grey
                                  : Theme.of(context).iconTheme.color,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (String value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Editpost(id: post['_id']),
                    ),
                  );
                } else if (value == 'delete') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Deletepost(id: post['_id']),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => const [
                PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
