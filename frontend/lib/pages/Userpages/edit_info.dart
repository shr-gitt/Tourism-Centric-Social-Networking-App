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
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthStorage.getUserName();
    log('in profile page, userId is $userId');

    if (userId != null) {
      final fetchedUser = await userapi.fetchUserData(userId);
      if (!mounted) return;
      setState(() {
        user = fetchedUser;
        if (user?['image'] != null) {
          _previmage = NetworkImage('https://localhost:5259${user!['image']}');
        }
      });
    } else {
      setState(() {
        user = null;
      });
    }
  }

  // Add Image Picker related variables
  final ImagePicker _picker = ImagePicker();
  NetworkImage? _previmage;
  File? _image;

  // Pick an image
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
      return GFAvatar(
        radius: 75, 
        backgroundImage: FileImage(_image!),
      );
    } else if (_previmage != null) {
      return GFAvatar(radius: 75, backgroundImage: _previmage);
    } else {
      return GFAvatar(
        radius: 75,
        backgroundImage: NetworkImage(
          'https://localhost:5259/Images/profile_placeholder.jpg',
        ),
        child: Icon(Icons.person, size: 50),
      );
    }
  }

  // Submit the form
  void _submitForm() async {
    final username = _usernameController.text.trim();
    final fullname = _fullnameController.text.trim();
    final phonenumber = _phonenumberController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty ||
        fullname.isEmpty ||
        phonenumber.isEmpty ||
        email.isEmpty) {
      GFToast.showToast(
        'Please fill in all fields',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      return;
    }

    // Prepare the data for submission
    final Map<String, dynamic> data = {
      "UserName": username,
      "Name": fullname,
      "PhoneNumber": phonenumber,
      "Email": email,
    };

    log('Email:$email');

    final success = await UserService().updateUser(username, data, _image);

    if (!mounted) return;
    if (success) {
      GFToast.showToast(
        'Post updated successfully!',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      // Navigate to the previous page or wherever you need
      Navigator.pop(context);
    } else {
      GFToast.showToast(
        'Post update failed. Please try again.',
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
                  //const SizedBox(height: 10),
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

                  // Display the picked image
                  buildProfileImage(),
                  const SizedBox(height: 20),

                  // Image Picker Button
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text("Pick Profile Image"),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  DecorHelper().buildModernTextField(
                    controller: TextEditingController(
                      text: user?['userName'] ?? '',
                    ),
                    label: 'Username',
                    icon: Icons.person_2_outlined,
                  ),

                  const SizedBox(height: 16),

                  // Full Name Field
                  DecorHelper().buildModernTextField(
                    controller: TextEditingController(
                      text: user?['name'] ?? '',
                    ),
                    label: 'Full Name',
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  DecorHelper().buildModernTextField(
                    controller: TextEditingController(
                      text: user?['phoneNumber'] ?? '',
                    ),
                    label: 'Phone Number',
                    icon: Icons.phone,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  DecorHelper().buildModernTextField(
                    controller: TextEditingController(
                      text: user?['email'] ?? '',
                    ),
                    label: 'Email',
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 24),

                  // Update Post Button
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
