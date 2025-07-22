import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/status.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/mainscreen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<void> _logoutUser() async {
    await AuthStorage.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const Status(title: 'Tourism Centric Social Networking App'),
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Work in Progress....'),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _logoutUser, child: const Text('Logout')),
          ],
        ),
      ),
    );
  }
}
