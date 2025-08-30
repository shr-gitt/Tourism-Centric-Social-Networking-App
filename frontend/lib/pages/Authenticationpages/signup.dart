import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  final _confirmpasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isconfirmPasswordVisible = false;

  //String? _completePhoneNumber;
  String? _countryCode;
  String? _purePhoneNumber;

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
    final confirmpassword = _confirmpasswordController.text;

    if (_purePhoneNumber == null || _purePhoneNumber!.length != 10) {
      GFToast.showToast(
        'Enter a valid 10-digit phone number',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      return;
    }

    if (username.isEmpty ||
        fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmpassword.isEmpty) {
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
      "PhoneNumber": '$_countryCode$_purePhoneNumber',
      "Email": email,
      "Password": password,
      "ConfirmPassword": confirmpassword,
    };

    log('Email:$email');

    final success = await UserService().registerUser(data, _image);

    if (!mounted) return;
    if (success) {
      GFToast.showToast(
        'Sign up successful!',
        context,
        toastPosition: GFToastPosition.BOTTOM,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage(asguest: false)),
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
            MaterialPageRoute(builder: (_) => LoginPage(asguest: false)),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 179, 151, 208),

        //title: const Text("Sign Up"),
        //centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            const SizedBox(height: 45),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'New User? Create Account',
                      style: TextStyle(fontSize: 14, color: Color(0xFF718096)),
                      textAlign: TextAlign.center,
                    ),
                    //const Text("Create Account", style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 20),

                    // Username Field
                    DecorHelper().buildModernTextField(
                      controller: _usernameController,
                      label: 'Username',
                      icon: Icons.person_2_outlined,
                    ),

                    const SizedBox(height: 16),

                    // Full Name Field
                    DecorHelper().buildModernTextField(
                      controller: _fullnameController,
                      label: 'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    // Phone Number Field
                    IntlPhoneField(
                      initialCountryCode: 'IN',
                      dropdownIcon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color.fromARGB(255, 113, 128, 150),
                        ),
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          borderSide: BorderSide(
                            color: Color(0xFF667eea),
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red.shade400),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red.shade400,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (phone) {
                        setState(() {
                          //_completePhoneNumber = phone.completeNumber;
                          _countryCode = phone.countryCode;
                          _purePhoneNumber = phone.number;
                        });
                      },
                      validator: (phone) {
                        if (phone == null || phone.number.length != 10) {
                          return 'Phone number must be exactly 10 digits';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    DecorHelper().buildModernTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    DecorHelper().buildModernTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF718096),
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password is required';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Confirm Password Field
                    DecorHelper().buildModernTextField(
                      controller: _confirmpasswordController,
                      label: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: !_isconfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isconfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF718096),
                        ),
                        onPressed: () => setState(
                          () => _isconfirmPasswordVisible =
                              !_isconfirmPasswordVisible,
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password is required';
                        }
                        if (value!.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Image Picker Button
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          Color.fromARGB(255, 208, 199, 218),
                        ),
                        foregroundColor: WidgetStateProperty.all<Color>(
                          Colors.black,
                        ),
                        textStyle: WidgetStateProperty.all<TextStyle>(
                          const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
                    DecorHelper().buildGradientButton(
                      onPressed: _submitForm,
                      child: const Text(
                        'Sign Up',
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
            ),
          ],
        ),
      ),
    );
  }
}
