import 'package:flutter/material.dart';
import 'package:frontend/api_service.dart';

class Deletepost extends StatefulWidget {
  final String id;
  const Deletepost({super.key, required this.id});

  @override
  State<Deletepost> createState() => _DeletepostState();
}

class _DeletepostState extends State<Deletepost> {
  final ApiService api = ApiService();
  late Future<Map<String, dynamic>> postFuture;

  @override
  void initState() {
    super.initState();
    postFuture = api.fetchPostById(widget.id);
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
      final success = await api.deletePost(widget.id);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Post deleted successfully' : 'Failed to delete post'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delete Post')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: postFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No post found'));
          }

          final post = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${post['title'] ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Location: ${post['location'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Content: ${post['content'] ?? 'N/A'}'),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _confirmDelete(context),
                    child: const Text('Delete Post'),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}