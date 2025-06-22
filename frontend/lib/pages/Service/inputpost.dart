import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/apiconnect.dart';

class Inputpost extends StatelessWidget {
  final String? id;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController locationController;
  final TextEditingController contentController;

  const Inputpost({
    super.key,
    this.id,
    required this.titleController,
    required this.locationController,
    required this.contentController,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Post' : 'Create Post')),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title'),
              TextField(controller: titleController),
              const SizedBox(height: 10),
              const Text('Location'),
              TextField(controller: locationController),
              const SizedBox(height: 10),
              const Text('Content'),
              TextField(controller: contentController, maxLines: null),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Apiconnect(
                    id: id,
                    isEditing: isEditing,
                    titleController: titleController,
                    locationController: locationController,
                    contentController: contentController,
                  ).submitPost(context);
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}