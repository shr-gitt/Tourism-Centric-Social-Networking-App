import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/posts.dart';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:frontend/pages/guest.dart';
import 'package:frontend/pages/settings.dart';
import 'package:frontend/pages/Service/user_apiservice.dart';
import 'package:frontend/pages/Service/authstorage.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  String? uid;
  final UserService userapi = UserService();
  Map<String, dynamic>? user;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUserId();

    Future.delayed(Duration(seconds: 2), () {
      if (user == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Guest()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Widget _buildProfileAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.blue.shade600,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile picture and info
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: user?['image'] != null
                                  ? NetworkImage(
                                      'https://localhost:5259${user!['image']}',
                                    )
                                  : null,
                              backgroundColor: Colors.grey.shade100,
                              child: user?['image'] == null
                                  ? Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?['userName'] ?? "No username",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?['name'] ?? "No name",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (user?['email'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    user!['email'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildProfileAction(
                              icon: Icons.edit_outlined,
                              label: 'Edit Profile',
                              onTap: () {
                                // TODO: Implement edit profile
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit profile coming soon!')),
                                );
                              },
                              iconColor: Colors.blue.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildProfileAction(
                              icon: Icons.security_outlined,
                              label: 'Account',
                              onTap: () {
                                log('Account settings button pressed');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserSettingsPage(),
                                  ),
                                );
                              },
                              iconColor: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildProfileAction(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onTap: () {
                                log('App settings button pressed');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => Settings()),
                                );
                              },
                              iconColor: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Posts section
                Container(
                  height: 8,
                  color: Colors.grey.shade100,
                ),
                
                // Posts header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.grid_on_outlined,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Posts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Posts content
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: PostsPage(state: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // If user is null or loading, show loading indicator
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
