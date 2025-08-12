import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/password_apiservice.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:frontend/pages/settings.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordApiService = PasswordApiservice();

  bool _isLoading = false;
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage("Please fill in all fields", isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage("New passwords do not match", isError: true);
      return;
    }

    if (newPassword.length < 6) {
      _showMessage(
        "New password must be at least 6 characters long",
        isError: true,
      );
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage(
        "New password must be different from current password",
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      log('Trying to change password');
      final success = await _passwordApiService.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      setState(() => _isLoading = false);

      if (success) {
        _showMessage("Password changed successfully", isError: false);
        // Clear form
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        // Navigate back after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const UserSettingsPage()),
            );
          }
        });
      } else {
        _showMessage(
          "Failed to change password. Please check your current password.",
          isError: true,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage("An error occurred. Please try again.", isError: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 24),
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Settings()),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    const Expanded(
                      child: Text(
                        'Change Password',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // Title
                      const Text(
                        'Update your password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Enter your current password and choose a new secure password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Current password input
                      DecorHelper().buildModernTextField(
                        controller: _currentPasswordController,
                        label: 'Current password',
                        icon: Icons.lock_outline,
                        obscureText: _isCurrentPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF718096),
                          ),
                          onPressed: () => setState(
                            () => _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // New password input
                      DecorHelper().buildModernTextField(
                        controller: _newPasswordController,
                        label: 'New password',
                        icon: Icons.lock_outline,
                        obscureText: _isNewPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF718096),
                          ),
                          onPressed: () => setState(
                            () =>
                                _isNewPasswordVisible = !_isNewPasswordVisible,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Confirm new password input
                      DecorHelper().buildModernTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm new password',
                        icon: Icons.lock_outline,
                        obscureText: _isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF718096),
                          ),
                          onPressed: () => setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password requirements
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password requirements:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '• At least 6 characters long\n• Different from your current password\n• Use a combination of letters, numbers, and symbols',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      // Change password button
                      DecorHelper().buildGradientButton(
                        onPressed: _isLoading ? null : _handleChangePassword,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Change Password',
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

              // Bottom section
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const UserSettingsPage()),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
