import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Service/enhanced_user_apiservice.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCodeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (_emailController.text.trim().isEmpty) {
      GFToast.showToast('Please enter your email address', context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await EnhancedUserApiService().forgotPassword(_emailController.text.trim());
      
      if (success) {
        setState(() => _isCodeSent = true);
        GFToast.showToast('Reset code sent to your email!', context);
      } else {
        GFToast.showToast('Failed to send reset code. Please try again.', context);
      }
    } catch (e) {
      GFToast.showToast('An error occurred. Please check your connection.', context);
      log('Forgot password error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_codeController.text.trim().isEmpty) {
      GFToast.showToast('Please enter the reset code', context);
      return;
    }
    if (_newPasswordController.text.isEmpty) {
      GFToast.showToast('Please enter a new password', context);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      GFToast.showToast('Passwords do not match', context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await EnhancedUserApiService().resetPassword(
        _emailController.text.trim(),
        _codeController.text.trim(),
        _newPasswordController.text,
      );

      if (success) {
        GFToast.showToast('Password reset successful! Please sign in with your new password.', context);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        GFToast.showToast('Failed to reset password. Please check your code and try again.', context);
      }
    } catch (e) {
      GFToast.showToast('An error occurred. Please try again.', context);
      log('Reset password error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GFAppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isCodeSent ? 'Reset Password' : 'Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_isCodeSent) ...[
                  // Email Step
                  const Text(
                    "Enter your email address and we'll send you a reset code",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  GFTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  GFButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    text: _isLoading ? "Sending..." : "Send Reset Code",
                    textColor: Colors.black,
                    fullWidthButton: true,
                    size: GFSize.LARGE,
                    type: GFButtonType.solid,
                    color: const Color(0xFFF5E17A),
                  ),
                ] else ...[
                  // Reset Password Step
                  Text(
                    'Reset code sent to ${_emailController.text}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  GFTextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Reset Code',
                      prefixIcon: Icon(Icons.security),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GFTextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  GFTextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  GFButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    text: _isLoading ? "Resetting..." : "Reset Password",
                    textColor: Colors.black,
                    fullWidthButton: true,
                    size: GFSize.LARGE,
                    type: GFButtonType.solid,
                    color: const Color(0xFFF5E17A),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  TextButton(
                    onPressed: () => setState(() => _isCodeSent = false),
                    child: const Text('Didn\'t receive the code? Try again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}