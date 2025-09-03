// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/displayReportedPost.dart';
import 'dart:async';
import 'dart:developer';
import 'package:frontend/pages/Service/report_apiservice.dart';
import 'package:frontend/pages/Service/posts_apiservice.dart';

class ReportedPostsPage extends StatefulWidget {
  const ReportedPostsPage({super.key});

  @override
  State<ReportedPostsPage> createState() => _ReportedPostsPageState();
}

class _ReportedPostsPageState extends State<ReportedPostsPage> {
  final ReportApiservice reportApi = ReportApiservice();
  final ApiService postApi = ApiService();

  List<Map<String, dynamic>> reportedPosts = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchReportedPosts();
  }

  Future<void> _fetchReportedPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      log('Fetching all reports...');
      final reports = await reportApi.fetchReports();
      log('Fetched ${reports.length} reports');

      // Group reports by postId and get the latest report for each post
      Map<String, dynamic> latestReportsByPost = {};
      for (var report in reports) {
        final postId = report['postId'];
        final reportDate =
            DateTime.tryParse(report['created'] ?? '') ?? DateTime(2000);

        if (postId != null) {
          if (!latestReportsByPost.containsKey(postId) ||
              reportDate.isAfter(
                DateTime.tryParse(
                      latestReportsByPost[postId]['created'] ?? '',
                    ) ??
                    DateTime(2000),
              )) {
            latestReportsByPost[postId] = report;
          }
        }
      }

      log('Found ${latestReportsByPost.length} unique reported posts');

      // Fetch post details for each reported post
      List<Map<String, dynamic>> fetchedPosts = [];
      for (var entry in latestReportsByPost.entries) {
        final postId = entry.key;
        final report = entry.value;

        try {
          log('Fetching post details for postId: $postId');
          final post = await postApi.fetchPostById(postId);

          // Add report information to the post
          post['reportReason'] = report['title'] ?? 'No reason provided';
          post['reportDate'] = report['created'];
          post['reportId'] = report['reportId'];

          fetchedPosts.add(post);
          log('Successfully fetched post: ${post['title']}');
        } catch (e) {
          log('Failed to fetch post with ID $postId: $e');
          // Handle case where reported post no longer exists
          // Still add report info for display purposes
          fetchedPosts.add({
            'postId': postId,
            'title': '[Post Deleted or Not Found]',
            'content': 'This post may have been deleted.',
            'location': 'Unknown',
            'community': 'Unknown',
            'userId': 'Unknown',
            'created': report['created'],
            'reportReason': report['title'] ?? 'No reason provided',
            'reportDate': report['created'],
            'reportId': report['reportId'],
            'isDeleted': true,
          });
        }
      }

      // Sort by newest report date first
      fetchedPosts.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['reportDate'] ?? '') ?? DateTime(2000);
        final bDate =
            DateTime.tryParse(b['reportDate'] ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      setState(() {
        reportedPosts = fetchedPosts;
        isLoading = false;
      });

      log('Successfully loaded ${reportedPosts.length} reported posts');
    } catch (e) {
      log('Error fetching reported posts: $e');
      setState(() {
        errorMessage = 'Failed to load reported posts: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _refreshReportedPosts() async {
    await _fetchReportedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Posts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReportedPosts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Reports',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshReportedPosts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (reportedPosts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.report_off, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No Reported Posts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Great! There are currently no reported posts.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshReportedPosts,
      child: ListView.builder(
        itemCount: reportedPosts.length,
        itemBuilder: (context, index) {
          return DisplayReportedPost(post: reportedPosts[index],);
        },
      ),
    );
  }
}
