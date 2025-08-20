import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/constants.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'dart:developer';

class Apiconnect {
  final String? id;
  final String? userId;
  final bool isEditing;
  final TextEditingController titleController;
  final TextEditingController locationController;
  final String community;
  final TextEditingController contentController;
  final List<XFile>? pickedImage;

  Apiconnect({
    this.id,
    this.userId,
    required this.isEditing,
    required this.titleController,
    required this.locationController,
    required this.community,
    required this.contentController,
    required this.pickedImage,
  });

  Future<void> submitPost(BuildContext context) async {
    String posturl=Constants.posturl;
    try {
      final uri = isEditing
          ? Uri.parse('$posturl/edit/${id!}')
          : Uri.parse('$posturl/create');

      final method = 'POST';

      final request = http.MultipartRequest(method, uri);

      request.fields['UserId'] = userId ?? '';
      request.fields['title'] = titleController.text;
      request.fields['location'] = locationController.text;
      request.fields['county'] = community;
      request.fields['content'] = contentController.text;
      log('post title:${request.fields['title']}');
      if (pickedImage != null && pickedImage!.isNotEmpty) {
        for (final image in pickedImage!) {
          final fileName = basename(image.path);
          final ext = extension(image.path).toLowerCase();
          final mimeType = ext == '.png'
              ? 'image/png'
              : ext == '.gif'
              ? 'image/gif'
              : 'image/jpeg'; // default

          request.files.add(
            await http.MultipartFile.fromPath(
              'Images',
              image.path,
              contentType: MediaType.parse(mimeType),
              filename: fileName,
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        log('Response body: ${response.body}');
        throw Exception(
          '${isEditing ? 'Update' : 'Creation'} failed: ${response.body}',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Post ${isEditing ? 'updated' : 'created'} successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
