import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/apiconnect.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Inputpost extends StatefulWidget {
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
  State<Inputpost> createState() => _InputpostState();
}

class _InputpostState extends State<Inputpost> {
  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Edit Post' : 'Create Post')),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border.all(width: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Title'),
              TextField(controller: widget.titleController),
              const SizedBox(height: 10),
              const Text('Location'),
              TextField(controller: widget.locationController),
              const SizedBox(height: 10),
              const Text('Content'),
              TextField(controller: widget.contentController, maxLines: null),
              const SizedBox(height: 20),
              const Text('Images'),
              ElevatedButton(
                onPressed: () async {
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (!mounted) return;
                  if (image != null) {
                    setState(() {
                      pickedImage = image;
                    });
                    if(!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected image: ${image.name}')),
                    );
                  }
                },
                child: const Text('Pick Image'),
              ),
              if (pickedImage != null) ...[
                const SizedBox(height: 10),
                Image.file(
                  File(pickedImage!.path),
                  height: 150,
                ),
              ],
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Apiconnect(
                    id: widget.id,
                    isEditing: widget.isEditing,
                    titleController: widget.titleController,
                    locationController: widget.locationController,
                    contentController: widget.contentController,
                    pickedImage: pickedImage,
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
