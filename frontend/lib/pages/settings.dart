import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Userpages/change_password.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:frontend/pages/mainscreen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> _logoutUser() async {
    try {
      await UserService().logoutUser();
      await AuthStorage.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
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
      body: Center(
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

                  ElevatedButton(
                    onPressed: _logoutUser,
                    child: const Text('Logout'),
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
