// ignore_for_file: file_names

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/community_banner.dart';
import 'package:frontend/pages/Postpages/reportedPosts.dart';
import 'package:frontend/pages/Service/posts_apiservice.dart';
import 'package:frontend/pages/Service/report_apiservice.dart';
import 'package:frontend/pages/avatar.dart';
import 'package:frontend/pages/Feedbackpages/feedbacks.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Postpages/fullpost.dart';
import 'package:frontend/pages/imagedisplaywithbuttons.dart';
import 'package:frontend/pages/Postpages/editpost.dart';
import 'package:intl/intl.dart';

class DisplayReportedPost extends StatefulWidget {
  final Map<String, dynamic> post;

  const DisplayReportedPost({super.key, required this.post});

  @override
  State<DisplayReportedPost> createState() => _DisplayReportedPostState();
}

class _DisplayReportedPostState extends State<DisplayReportedPost> {
  final UserService userapi = UserService();
  Map<String, dynamic>? user;
  final ApiService api = ApiService();
  final ReportApiservice reportApi = ReportApiservice();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = widget.post['userId'];
    if (userId != null && userId != 'Unknown') {
      final userData = await userapi.fetchUserData(userId);
      if (userData != null && mounted) {
        setState(() {
          user = userData;
        });
      }
    }
  }

  Widget _buildReportBanner() {
    final reportReason = widget.post['reportReason'] ?? 'No reason provided';
    final reportDate = widget.post['reportDate'];
    String formattedReportDate = 'Unknown date';

    if (reportDate != null) {
      final parsedDate = DateTime.tryParse(reportDate);
      if (parsedDate != null) {
        formattedReportDate = DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border(left: BorderSide(color: Colors.red[400]!, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.report, size: 20, color: Colors.red[600]),
              const SizedBox(width: 8),
              Text(
                'REPORTED',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.red[700],
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Reason: $reportReason',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red[800],
            ),
          ),
          Text(
            'Reported on: $formattedReportDate',
            style: TextStyle(fontSize: 12, color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveReport(BuildContext context) async {
    final reportId = widget.post['reportId'];

    if (reportId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No report ID available')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Report'),
        content: const Text(
          'Are you sure you want to mark this report as resolved?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Resolve', style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await reportApi.deleteReportById(reportId);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReportedPostsPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Report resolved successfully'
                  : 'Failed to resolve report',
            ),
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await api.deletePost(widget.post['postId']);
      if (context.mounted) {
        await _resolveReport(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Post deleted successfully' : 'Failed to delete post',
            ),
          ),
        );
      }
    }
  }

  Widget _buildModeratorActions() {
    final postId = widget.post['postId'];
    final isDeleted = widget.post['isDeleted'] ?? false;

    if (isDeleted || postId == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Post no longer available',
          style: TextStyle(
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editpost(postId: postId),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                foregroundColor: Colors.blue[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete, size: 16),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _resolveReport(context),
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Resolve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                foregroundColor: Colors.green[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDeleted = post['isDeleted'] ?? false;

    log('Displaying reported post: ${post['title']}');

    return GestureDetector(
      onTap: isDeleted
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullPostPage(
                    postId: post['postId'],
                    scrollToComment: false,
                    state: false,
                  ),
                ),
              );
            },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportBanner(),

            if (!isDeleted) ...[
              const SizedBox(height: 8),

              // Community banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CommunityBanner(
                  data: post['community'] ?? "Unknown",
                  isPost: true,
                ),
              ),

              const SizedBox(height: 8),
              const Divider(height: 0, thickness: 1, color: Colors.grey),
              const SizedBox(height: 8),

              // User avatar and info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Avatar(data: post, isPost: true, selfPost: false),
              ),

              const SizedBox(height: 8),

              // Post content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post['location'] ?? 'No Location',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    // Post creation date
                    Builder(
                      builder: (context) {
                        final rawDate = post['created'];
                        final parsedDate = DateTime.tryParse(rawDate ?? '');
                        final formattedDate = parsedDate != null
                            ? DateFormat('yyyy-MM-dd').format(parsedDate)
                            : 'Invalid date';
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                    Text(
                      post['content'] ?? 'No Content',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    ),

                    // Show more button (only if not deleted)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPostPage(
                              postId: post['postId'],
                              scrollToComment: false,
                              state: false,
                            ),
                          ),
                        );
                      },
                      child: const Text("Show more"),
                    ),

                    // Images (if any)
                    if (post['image'] != null &&
                        post['image'] is List &&
                        (post['image'] as List).isNotEmpty) ...[
                      ImageDisplayWithButtons(
                        imageUrls: List<String>.from(
                          (post['image'] as List).where(
                            (img) =>
                                img != null && img is String && img.isNotEmpty,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Feedback buttons (for context, but maybe disable in moderation)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Feedbacks(post: post),
              ),
            ],

            const Divider(height: 8, thickness: 1, color: Colors.grey),

            // Moderator actions
            _buildModeratorActions(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
