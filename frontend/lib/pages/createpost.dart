import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/inputpost.dart';

class Createpost extends StatelessWidget {
  const Createpost({super.key, String? id});

  @override
  Widget build(BuildContext context) {
    return Inputpost(
      titleController: TextEditingController(),
      locationController: TextEditingController(),
      contentController: TextEditingController(),
      isEditing: false,
    );
  }
}