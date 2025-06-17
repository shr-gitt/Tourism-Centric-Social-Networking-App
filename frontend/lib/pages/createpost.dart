import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Createpost extends StatefulWidget {
  const Createpost({super.key});

  @override
  State<Createpost> createState() => _CreatepostState();
}

class _CreatepostState extends State<Createpost> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> submitPost() async {
  final postData = {
    "title": titleController.text,
    "location": locationController.text,
    "content": contentController.text,
  };

  final url = Uri.parse('http://localhost:5259/api/posts'); // or 10.0.2.2 if Android emulator

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(postData),
    );

    if (!mounted) return; // 👈 add this after await

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Post submitted!')),
      );
      Navigator.pop(context); // also uses context, so safe only if mounted
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed: ${response.statusCode}')),
      );
    }
  } catch (e, stack) {
    log('❌ Exception: $e');
    log('📍 Stack trace: $stack');
    if (!mounted) return; // 👈 again, check before using context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title'),
              TextField(controller: titleController),
              SizedBox(height: 10),
              Text('Location'),
              TextField(controller: locationController),
              SizedBox(height: 10),
              Text('Content'),
              TextField(controller: contentController, maxLines: null),
              SizedBox(height: 20),
              ElevatedButton(onPressed: submitPost, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
