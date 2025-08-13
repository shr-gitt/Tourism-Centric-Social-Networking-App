import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';
import 'package:frontend/pages/Userpages/edit_info.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:frontend/pages/settings.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({super.key});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final UserService userapi = UserService();
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? userId = await AuthStorage.getUserName();
    log('in profile page, userId is $userId');

    if (userId != null) {
      final fetchedUser = await userapi.fetchUserData(userId);
      if (!mounted) return;
      setState(() {
        user = fetchedUser;
      });
    } else {
      setState(() {
        user = null;
      });
    }
  }

  Map<String, dynamic>? settings;

  bool isLoading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                error!,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              /*ElevatedButton(
                onPressed: _loadSettings,
                child: const Text('Retry'),
              ),*/
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                      'Account Information',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(110, 0, 0, 0),
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: user?['image'] != null
                            ? NetworkImage(
                                'https://localhost:5259${user!['image']}',
                              )
                            : null,
                        child: user?['image'] == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    DecorHelper().buildInfoCard(
                      title: 'Username',
                      value: user?['userName'] ?? '',
                      icon: Icons.person_outline,
                    ),

                    DecorHelper().buildInfoCard(
                      title: 'Name',
                      value: user?['name'] ?? '',
                      icon: Icons.person_outline,
                    ),

                    DecorHelper().buildInfoCard(
                      title: 'Email Address',
                      value: user?['email'] ?? '',
                      icon: Icons.email_outlined,
                    ),

                    DecorHelper().buildInfoCard(
                      title: 'Phone Number',
                      value: user?['phoneNumber'] ?? '',
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 32),

                    DecorHelper().buildGradientButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditInformationPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Edit Information',
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
