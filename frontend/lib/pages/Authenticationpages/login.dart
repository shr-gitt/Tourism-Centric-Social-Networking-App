import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/status.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/mainscreen.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Authenticationpages/signup.dart';
import 'package:frontend/pages/Authenticationpages/forgot_password.dart';
import 'package:frontend/pages/Authenticationpages/guest_access.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isRememberMe = false;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    void showError(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter both email and password.");
      return;
    }

    final data = {
      "Email": email,
      "Password": password,
      "rememberMe": isRememberMe,
    };
    log(
      'Email:$email and Password:$password and remember me is : $isRememberMe',
    );

    final userId = await UserService().loginUser(data);
    /*{
      response => {

      }
    };*/
    log('Login userId: $userId');

    if (userId != null) {
      await AuthStorage.saveUserName(userId);
      log('Saving userId: $userId');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login successful")));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 0)),
      );
    } else {
      showError("Login failed. Check credentials.");
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
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GFTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            GFTextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GFButton(
                  onPressed: _handleLogin,
                  text: "Login",
                  textColor: Colors.black,
                  fullWidthButton: true,
                  size: GFSize.LARGE,
                  type: GFButtonType.solid,
                  color: const Color(0xFFF5E17A),
                ),

                Row(
                  children: [
                    GFCheckbox(
                      size: 22,
                      activeBgColor: const Color.fromARGB(255, 171, 175, 173),
                      type: GFCheckboxType.square,
                      onChanged: (value) {
                        setState(() {
                          isRememberMe = value;
                        });
                      },
                      value: isRememberMe,
                      inactiveIcon: null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Remember Me'),
                  ],
                ),
              ],
            ),

            // Forgot Password Button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                );
              },
              child: const Text("Forgot Password?"),
            ),

            // Guest Access Button
            GFButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GuestAccessPage()),
                );
              },
              text: "Continue as Guest",
              textColor: Colors.black,
              fullWidthButton: true,
              size: GFSize.LARGE,
              type: GFButtonType.outline,
              color: Colors.grey,
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
