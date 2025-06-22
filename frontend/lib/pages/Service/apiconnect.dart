import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Apiconnect {
  final String? id;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController locationController;
  final TextEditingController contentController;

  Apiconnect({
    this.id,
    required this.isEditing,
    required this.titleController,
    required this.locationController,
    required this.contentController,
  });

  Future<void> submitPost(BuildContext context) async {
    final postData = {
      "id": id,
      "title": titleController.text,
      "location": locationController.text,
      "content": contentController.text,
    };

    try {
      final response = isEditing
          ? await http.put(
              Uri.parse('http://localhost:5259/api/posts/$id'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(postData),
            )
          : await http.post(
              Uri.parse('http://localhost:5259/api/posts'),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(postData),
            );

      if (!context.mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post submitted!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}