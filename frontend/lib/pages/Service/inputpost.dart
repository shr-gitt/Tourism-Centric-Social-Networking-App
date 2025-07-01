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
  List<XFile> pickedImage = [];

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();

    if (!mounted || images.isEmpty) return;

    final maxCount = 5;
    final maxSizeInBytes = 5 * 1024 * 1024; // 5MB

    List<XFile> validImages = [];

    for (XFile image in images) {
      final file = File(image.path);
      final fileSize = await file.length();

      if (pickedImage.length >= maxCount) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum of $maxCount images allowed.')),
          );
        }
        return;
      }

      if (pickedImage.length + validImages.length >= maxCount) {
        break;
      }

      if (fileSize <= maxSizeInBytes) {
        validImages.add(image);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image "${image.name}" is larger than 5MB. Skipped.',
              ),
            ),
          );
        }
      }
    }

    if (validImages.isEmpty) return;

    setState(() {
      pickedImage.addAll(validImages);
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${validImages.length} image(s) added')),
    );
  }

  void _confirm(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit'),
        content: const Text('Are you sure you want to submit this post?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Submit', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (context.mounted) {
        Apiconnect(
          id: widget.id,
          isEditing: widget.isEditing,
          titleController: widget.titleController,
          locationController: widget.locationController,
          contentController: widget.contentController,
          pickedImage: pickedImage,
        ).submitPost(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Post' : 'Create Post'),
      ),
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
                onPressed: pickedImage.length >= 5 ? null : _pickImages,
                child: Text("Pick Image (${pickedImage.length}/5)"),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: pickedImage.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          child: Image.file(
                            File(pickedImage[index].path),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                pickedImage.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () => _confirm(context),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
