import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/Authenticationpages/verifycode.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/usersettings_apiservice.dart';
import 'package:frontend/pages/Userpages/change_password.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:frontend/pages/help_center.dart';
import 'package:frontend/pages/mainscreen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic>? settings;
  bool isLoading = false;
  String? error;

  Future<void> _logoutUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Log out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Log out',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    bool isSubmitting = false;
    if (confirmed == true && !isSubmitting && mounted) {
      setState(() {
        isSubmitting = true;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator()),
      );

      try {
        await UserService().logoutUser();
        await AuthStorage.logout();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          log('Error: $e');
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    setState(() => isLoading = true);
    //final token = await AuthStorage.getToken();
    //log('Token used for settings request: $token');

    String userId = await AuthStorage.getUserName() ?? "";
    final result = await UserService().fetchUserData(userId);
    log('In load settings, result is $result');
    setState(() {
      settings = result;
      isLoading = false;
      error = result == null ? 'Failed to load settings' : null;
    });
  }

  Future<void> _handleAction(
    Future<bool> Function() action,
    String successMsg,
  ) async {
    final result = await action();
    if (result) {
      _showSnackBar(successMsg);
      await _loadSettings(); // Refresh settings
    } else {
      _showSnackBar('Action failed');
    }
  }

  Future<void> _verifyemail(String email) async {
    log("Settings info: $settings");
    try {
      final success = await UserService().requestVerifyEmail(email);

      if (success) {
        _showSnackBar('Code verified!');
      } else {
        _showSnackBar(
          'Failed to verify email. Please check your code and try again.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        'An error occurred while trying to verify email. Please try again.',
        isError: true,
      );
      log('Verify email error: $e');
    } finally {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            purpose: "VerifyEmail",
            email: email,
            onVerified: () async {
              _showSnackBar("Email verified successfully!");
              await _loadSettings();
            },
          ),
        ),
      );
    }
  }

  Future<void> _toggle2FA(String email, bool state) async {
    log("Settings info: $settings");

    try {
      final success = await UserService().requestVerifyEmail(email);

      if (!success) {
        _showSnackBar('Failed to send verification code.', isError: true);
        return;
      }

      _showSnackBar('Verification code sent to email.');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyCodePage(
            purpose: "TwoFactor",
            email: email,
            onVerified: () async {
              await _handleAction(
                () => UsersettingsApiservice().twoFactor(
                  email: email,
                  state: !state, // Toggle
                ),
                state ? '2FA enabled.' : '2FA disabled.',
              );
            },
          ),
        ),
      ).then((_) {
        _loadSettings(); 
      });
    } catch (e) {
      _showSnackBar(
        'An error occurred while sending the verification code.',
        isError: true,
      );
      log('2FA error: $e');
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    log('Settings page reached');
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 4)),
          ),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    const SizedBox(height: 20),
                    DecorHelper().buildSettingCard(
                      title: 'Account Details',
                      subtitle: 'View your information',
                      icon: Icons.person,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserSettingsPage(),
                        ),
                      ),
                      iconColor: Colors.blue.shade600,
                    ),

                    const SizedBox(height: 20),
                    if (settings?['emailConfirmed'] != true) ...[
                      DecorHelper().buildSettingCard(
                        title: 'Verify Email',
                        subtitle: 'Verify your email',
                        icon: Icons.lock_outline,
                        onTap: () => _verifyemail(settings?['email']),
                        iconColor: Colors.blue.shade600,
                      ),
                      const SizedBox(height: 20),
                    ],
                    DecorHelper().buildSettingCard(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                      iconColor: Colors.blue.shade600,
                    ),

                    const SizedBox(height: 20),

                    DecorHelper().buildSettingCard(
                      title: 'Two-Factor Authentication',
                      subtitle: settings?['twoFactorEnabled'] == true
                          ? 'Enabled - Your account is protected'
                          : 'Disabled - Enhance your security',
                      icon: Icons.security_outlined,
                      onTap: () => _toggle2FA(
                        settings?['email'],
                        settings?['twoFactorEnabled'],
                      ),
                      iconColor: settings?['twoFactorEnabled'] == true
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                    ),

                    const SizedBox(height: 20),

                    DecorHelper().buildSettingCard(
                      title: 'Help Center',
                      subtitle: 'Frequently asked questions',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterPage(),
                        ),
                      ),
                      iconColor: Colors.blue.shade600,
                    ),

                    const SizedBox(height: 20),

                    DecorHelper().buildSettingCard(
                      title: 'Delete Account',
                      subtitle: 'Delete your account',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterPage(),
                        ),
                      ),
                      iconColor: Colors.blue.shade600,
                    ),

                    const SizedBox(height: 20),

                    DecorHelper().buildGradientButton(
                      onPressed: _logoutUser,
                      child: const Text(
                        'Log Out',
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
      ),
    );
  }
}
