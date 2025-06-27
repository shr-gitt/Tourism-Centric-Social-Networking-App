import 'package:flutter/material.dart';
import 'package:frontend/pages/editpost.dart';
import 'package:frontend/pages/deletepost.dart';
import 'package:frontend/pages/Service/apiconnect_feedbacks.dart';
import 'dart:convert';

class Displaymultiplepost extends StatefulWidget {
  final String? id;
  final Map<String, dynamic> post;
  const Displaymultiplepost({super.key, this.id , required this.post});

  @override
  State<Displaymultiplepost> createState() => _DisplaymultiplepostState();
}

class _DisplaymultiplepostState extends State<Displaymultiplepost> {
  bool _isLiked = false;
  bool _isdisLiked = false;
  String? comment;

  bool? get likeStatus {
    if (_isLiked == true) return true;
    if (_isLiked == false && _isdisLiked == true) return false;
    return null;
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
                (post['image'] != null && post['image'] != '')
                    ? Image.memory(base64Decode(post['image']))
                    : const SizedBox.shrink(),
                Divider(height: 10, thickness: 2, color: Colors.black),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                          _isdisLiked = false;
                        });
                        ApiconnectFeedbacks(
                          widget.id,
                          post['id'],
                          likeStatus,
                          comment,
                        ).addLike(context);
                      },
                      icon: Icon(
                        _isLiked
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isdisLiked = !_isdisLiked;
                          _isLiked = false;
                        });
                        ApiconnectFeedbacks(
                          widget.id,
                          post['id'],
                          likeStatus,
                          comment,
                        ).adddisLike(context);
                      },
                      icon: Icon(
                        _isdisLiked
                            ? Icons.thumb_down_alt
                            : Icons.thumb_down_alt_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isLiked = !_isLiked;
                        });
                        ApiconnectFeedbacks(
                          widget.id,
                          post['id'],
                          likeStatus,
                          comment,
                        ).addLike(context);
                      },
                      icon: Icon(Icons.comment),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert), // triple dot icon
              onSelected: (String value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Editpost(id: post['id']),
                    ),
                  );
                } else if (value == 'delete') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Deletepost(id: post['id']),
                    ),
                  );
                }
              },

              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
