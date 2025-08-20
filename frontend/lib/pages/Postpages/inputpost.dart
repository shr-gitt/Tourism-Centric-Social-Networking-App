import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/Service/posts_apiconnect.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/guest.dart';
import 'package:frontend/pages/mainscreen.dart';
import 'package:frontend/pages/MapPages/map_searchbar.dart';
import 'package:latlong2/latlong.dart';

class Inputpost extends StatefulWidget {
  final String? id;
  final bool isEditing;
  final TextEditingController titleController;
  TextEditingController locationController;
  String communityController;
  final TextEditingController contentController;
  final List<String>? existingImageUrls;
  final String? uid;

  Inputpost({
    super.key,
    this.id,
    required this.titleController,
    TextEditingController? locationController,
    String? communityController,
    required this.contentController,
    this.existingImageUrls,
    required this.isEditing,
    this.uid,
  }) : locationController =
           locationController ?? TextEditingController(text: 'Nepal'),
       communityController = communityController ?? 'Nepal';

  @override
  State<Inputpost> createState() => _InputpostState();
}

class _InputpostState extends State<Inputpost> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> pickedImage = [];
  late List<String> existingImages;
  bool isSubmitting = false;
  String? uid;

  @override
  void initState() {
    super.initState();

    existingImages = widget.existingImageUrls ?? [];
    _initializeUid();
  }

  Future<void> _initializeUid() async {
    uid = await AuthStorage.getUserName();
    setState(() {});
    Future.delayed(Duration(seconds: 1), () {
      if (uid == null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Guest()),
        );
      }
    });
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (!mounted || images.isEmpty) return;

    const maxCount = 5;
    const maxSizeInBytes = 5 * 1024 * 1024;

    List<XFile> validImages = [];

    for (XFile image in images) {
      final file = File(image.path);
      final fileSize = await file.length();

      if (pickedImage.length + validImages.length >= maxCount) break;

      if (fileSize <= maxSizeInBytes) {
        validImages.add(image);
      } else {
        if (!mounted) return;
        GFToast.showToast(
          'Image "${image.name}" exceeds 5MB. Skipped.',
          context,
          toastPosition: GFToastPosition.BOTTOM,
        );
      }
    }

    if (validImages.isNotEmpty) {
      setState(() {
        pickedImage.addAll(validImages);
      });

      if (!mounted) return;
      GFToast.showToast(
        '${validImages.length} image(s) added',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
    }
  }

  Future<void> _confirmSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Submit Post'),
        content: Text('Are you sure you want to submit this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true && !isSubmitting && mounted) {
      setState(() {
        isSubmitting = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );
      log('in inputpost, title:${widget.titleController.text}');

      try {
        await Apiconnect(
          id: widget.id,
          userId: uid,
          isEditing: widget.isEditing,
          titleController: widget.titleController,
          locationController: widget.locationController,
          community: widget.communityController,
          contentController: widget.contentController,
          pickedImage: pickedImage,
        ).submitPost(context);
        log('in try block, community: ${widget.communityController},');

        if (mounted) {
          Navigator.pop(context); // Close loading
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 0)),
            (_) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          GFToast.showToast('Error: $e', context);
        }
      } finally {
        if (mounted) {
          setState(() {
            isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: GFAppBar(
        title: Text(widget.isEditing ? 'Edit Post' : 'Create Post'),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),

                DecorHelper().buildModernTextField(
                  controller: widget.titleController,
                  label: 'Title',
                  icon: Icons.subject,
                ),
                const SizedBox(height: 16),

                Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                LocationSearchBar(
                  onLocationSelected:
                      (LatLng position, String address, String? community) {
                        log('Selected location: $address');
                        widget.locationController.text = address;
                        widget.communityController = community ?? "";
                        log(
                          'In input post, community name is ${widget.communityController}',
                        );
                      },
                  frompost: true,
                ),

                const SizedBox(height: 16),

                Text('Content', style: TextStyle(fontWeight: FontWeight.bold)),
                DecorHelper().buildModernTextField(
                  controller: widget.contentController,
                  label: 'Content',
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Images',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    GFButton(
                      onPressed: pickedImage.length >= 5 ? null : _pickImages,
                      text: 'Pick Image (${pickedImage.length}/5)',
                      textColor: Colors.black,
                      color: const Color(0xFFF5E17A),
                      size: GFSize.SMALL,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pickedImage.length,
                    itemBuilder: (_, index) {
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
                const SizedBox(height: 20),

                GFButton(
                  onPressed: isSubmitting ? null : _confirmSubmission,
                  text: 'Submit',
                  color: const Color.fromARGB(255, 95, 92, 95),
                  blockButton: true,
                  fullWidthButton: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
