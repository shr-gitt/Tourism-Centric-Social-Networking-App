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
  final UserService _userService = UserService();
  final UsersettingsApiservice _settings = UsersettingsApiservice();

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
    final token = await AuthStorage.getToken();
    log('Token used for settings request: $token');

    final result = await _userService.getUserSettings();
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
  Widget build(BuildContext context) {
    log('Settings page reached');
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

                    DecorHelper().buildSettingCard(
                      title: 'Verify Email',
                      subtitle: 'Verify your email',
                      icon: Icons.lock_outline,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VerifyCodePage(),
                        ),
                      ),
                      iconColor: Colors.blue.shade600,
                    ),

                    const SizedBox(height: 20),

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
                      onTap: () {
                        if (settings?['twoFactorEnabled'] == true) {
                          _handleAction(
                            _settings.disableTwoFactor,
                            '2FA disabled.',
                          );
                        } else {
                          _handleAction(
                            _settings.enableTwoFactor,
                            '2FA enabled.',
                          );
                        }
                      },
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
