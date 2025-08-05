import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/Authenticationpages/status.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phonenumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();

  // Add Image Picker related variables
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _phonenumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

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

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Submit the form
  void _submitForm() async {
    final username = _usernameController.text.trim();
    final fullname = _fullnameController.text.trim();
    final phonenumber = _phonenumberController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmpassword = _confirmpasswordController.text;

    if (username.isEmpty ||
        fullname.isEmpty ||
        phonenumber.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmpassword.isEmpty) {
      _showMessage('Please fill in all fields', isError: true);
      return;
    }

    if (password != confirmpassword) {
      _showMessage('Passwords do not match', isError: true);
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters long', isError: true);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Prepare the data for submission
    final Map<String, dynamic> data = {
      "UserName": username,
      "Name": fullname,
      "PhoneNumber": phonenumber,
      "Email": email,
      "Password": password,
      "ConfirmPassword": confirmpassword,
    };

    log('Email:$email');

    final success = await UserService().registerUser(data, _image);

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      _showMessage('Sign up successful!', isError: false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      _showMessage('Sign up failed. Please try again.', isError: true);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool? isPasswordVisible,
    VoidCallback? toggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText && !(isPasswordVisible ?? false),
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: toggleVisibility != null
              ? IconButton(
                  icon: Icon(
                    (isPasswordVisible ?? false) ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: toggleVisibility,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 24.0, right: 24.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              Status(title: 'Tourism-Centric Social Networking App'),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const Expanded(
                      child: Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Profile image picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: _image != null
                              ? ClipOval(
                                  child: Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt_outlined,
                                      size: 32,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Welcome text
                      const Text(
                        'Join us today',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Create your account to get started',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Username input
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Username',
                        icon: Icons.person_outline,
                      ),
                      
                      // Full name input
                      _buildTextField(
                        controller: _fullnameController,
                        hintText: 'Full name',
                        icon: Icons.badge_outlined,
                      ),
                      
                      // Phone number input
                      _buildTextField(
                        controller: _phonenumberController,
                        hintText: 'Phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      
                      // Email input
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      
                      // Password input
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        isPasswordVisible: _isPasswordVisible,
                        toggleVisibility: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      
                      // Confirm password input
                      _buildTextField(
                        controller: _confirmpasswordController,
                        hintText: 'Confirm password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        toggleVisibility: () {
                          setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Sign in link
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            children: [
                              const TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Sign in",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
