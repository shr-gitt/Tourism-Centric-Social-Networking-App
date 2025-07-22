import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/Authenticationpages/status.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Add Image Picker related variables
  final ImagePicker _picker = ImagePicker();
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

  // Submit the form
  void _submitForm() async {
    final username = _usernameController.text.trim();
    final fullname = _fullnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty ||
        fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
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
      "Email": email,
      "Password": password,
    };

    // Add the image to the data (if available)
    //if (_image != null) {
      //data['image'] = _image; // This will be handled in the API call
    //}

    log('Email:$email and Password:$password');

    final success = await UserService().registerUser(data,_image);

    if (!mounted) return;
    if (success) {
      GFToast.showToast(
        'Sign up successful!',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Status(title: 'Tourism Centric Social Networking App'),
        ),
      );
    } else {
      GFToast.showToast(
        'Sign up failed. Please try again.',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  Status(title: 'Tourism-Centric Social Networking App'),
            ),
          ),
        ),
        title: const Text("Sign Up"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text("Create Account", style: TextStyle(fontSize: 22)),
                const SizedBox(height: 20),

                // Username Field
                GFTextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Full Name Field
                GFTextField(
                  controller: _fullnameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                GFTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                GFTextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Image Picker Button
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Profile Image"),
                ),
                const SizedBox(height: 10),

                // Display the picked image
                _image != null
                    ? Image.file(
                        _image!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 24),

                // Sign Up Button
                GFButton(
                  onPressed: _submitForm,
                  text: "Sign Up",
                  color: Colors.blueGrey,
                  blockButton: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
