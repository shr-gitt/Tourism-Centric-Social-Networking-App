import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';

class EditInformationPage extends StatefulWidget {
  const EditInformationPage({super.key});

  @override
  State<EditInformationPage> createState() => _EditInformationPageState();
}

class _EditInformationPageState extends State<EditInformationPage> {
  String? uid;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  // Controllers initialized once
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _emailController = TextEditingController();

  // Image picker variables
  final ImagePicker _picker = ImagePicker();
  NetworkImage? _previmage;
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    // Dispose controllers when widget removed
    _usernameController.dispose();
    _fullnameController.dispose();
    _phonenumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthStorage.getUserName();
    log('in profile page, userId is $userId');

    if (userId != null) {
      final fetchedUser = await userapi.fetchUserData(userId);
      if (!mounted) return;
      setState(() {
        user = fetchedUser;

        // Initialize controllers with fetched user data
        _usernameController.text = user?['userName'] ?? '';
        _fullnameController.text = user?['name'] ?? '';
        _phonenumberController.text = user?['phoneNumber'] ?? '';
        _emailController.text = user?['email'] ?? '';

        if (user?['image'] != null && user!['image'].toString().isNotEmpty) {
          _previmage = NetworkImage('https://localhost:5259/${user!['image']}');
        } else {
          _previmage = null;
        }
      });
    } else {
      setState(() {
        user = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget buildProfileImage() {
    if (_image != null) {
      return GFAvatar(radius: 75, backgroundImage: FileImage(_image!));
    } else if (_previmage != null) {
      return GFAvatar(radius: 75, backgroundImage: _previmage);
    } else {
      return GFAvatar(
        radius: 75,
        backgroundImage: const NetworkImage(
          'https://localhost:5259/Images/profile_placeholder.jpg',
        ),
        child: const Icon(Icons.person, size: 50),
      );
    }
  }

  void _submitForm() async {
    final username = _usernameController.text.trim();
    final fullname = _fullnameController.text.trim();
    final phonenumber = _phonenumberController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty &&
        fullname.isEmpty &&
        phonenumber.isEmpty &&
        email.isEmpty &&
        _image == null) {
      GFToast.showToast(
        'Please make at least one change to update',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      return;
    }

    final Map<String, dynamic> data = {};

    if (username.isNotEmpty && username != (user?['userName'] ?? '')) {
      data["UserName"] = username;
    }
    if (fullname.isNotEmpty && fullname != (user?['name'] ?? '')) {
      data["Name"] = fullname;
    }
    if (phonenumber.isNotEmpty && phonenumber != (user?['phoneNumber'] ?? '')) {
      data["PhoneNumber"] = phonenumber;
    }
    if (email.isNotEmpty && email != (user?['email'] ?? '')) {
      data["Email"] = email;
    }

    if (data.isEmpty && _image == null) {
      GFToast.showToast(
        'No changes detected to update',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      return;
    }

    final success = await UserService().updateUser(username, data, _image);

    if (!mounted) return;
    if (success) {
      GFToast.showToast(
        'Information updated successfully!',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      Navigator.pop(context);
    } else {
      GFToast.showToast(
        'Update failed. Please try again.',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserSettingsPage()),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                children: [
                  const Text(
                    'Edit User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edit your details below',
                    style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  buildProfileImage(),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pick Profile Image"),
                  ),
                  const SizedBox(height: 20),

                  DecorHelper().buildModernTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.person_2_outlined,
                  ),

                  const SizedBox(height: 16),

                  DecorHelper().buildModernTextField(
                    controller: _fullnameController,
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  DecorHelper().buildModernTextField(
                    controller: _phonenumberController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 16),

                  DecorHelper().buildModernTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 24),

                  DecorHelper().buildGradientButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'Update Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
