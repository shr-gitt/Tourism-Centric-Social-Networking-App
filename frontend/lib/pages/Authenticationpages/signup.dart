import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/status.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:getwidget/getwidget.dart';

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

    final Map<String, dynamic> data = {
      "UserName": username,
      "Name": fullname,
      "Email": email,
      "Password": password,
    };
    log('Email:$email and Password:$password');

    final success = await UserService().registerUser(data);
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
      appBar: GFAppBar(title: const Text("Sign Up"), centerTitle: true),
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

                GFTextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                GFTextField(
                  controller: _fullnameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                GFTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                GFTextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

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
