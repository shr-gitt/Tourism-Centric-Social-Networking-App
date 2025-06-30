import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/inputpost.dart';
import 'package:frontend/api_service.dart';

class Editpost extends StatefulWidget {
  final String id;
  const Editpost({super.key, required this.id});

  @override
  State<Editpost> createState() => _EditpostState();
}

class _EditpostState extends State<Editpost> {
  final ApiService api = ApiService();
  late Future<Map<String, dynamic>> postFuture;

  @override
  void initState() {
    super.initState();
    postFuture = api.fetchPostById(widget.id);
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
        return Inputpost(
          id: widget.id,
          titleController: TextEditingController(text: post['title'] ?? ''),
          locationController: TextEditingController(
            text: post['location'] ?? '',
          ),
          contentController: TextEditingController(text: post['content'] ?? ''),
          isEditing: true,
        );
      },
    );
  }
}
