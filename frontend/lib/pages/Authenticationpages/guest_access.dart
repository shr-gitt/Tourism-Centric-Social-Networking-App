import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:frontend/pages/Service/enhanced_user_apiservice.dart';
import 'package:frontend/pages/mainscreen.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/Authenticationpages/signup.dart';

class GuestAccessPage extends StatefulWidget {
  const GuestAccessPage({super.key});

  @override
  State<GuestAccessPage> createState() => _GuestAccessPageState();
}

class _GuestAccessPageState extends State<GuestAccessPage> {
  bool _isLoading = false;

  Future<void> _continueAsGuest() async {
    setState(() => _isLoading = true);

    try {
      final result = await EnhancedUserApiService().useAsGuest();
      
      if (result != null && result['success'] == true) {
        GFToast.showToast('Welcome! You\'re now browsing as a guest.', context);
        
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 0)),
        );
      } else {
        GFToast.showToast('Failed to create guest session. Please try again.', context);
      }
    } catch (e) {
      GFToast.showToast('An error occurred. Please check your connection.', context);
      log('Guest access error: $e');
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
        title: const Text('Guest Access'),
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
                const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Browse as Guest',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Explore TourSnap without creating an account. You can browse posts and discover new destinations.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Guest Access Features
                _buildFeatureItem(Icons.explore, 'Browse travel posts'),
                const SizedBox(height: 12),
                _buildFeatureItem(Icons.map, 'Discover destinations'),
                const SizedBox(height: 12),
                _buildFeatureItem(Icons.search, 'Search content'),
                
                const SizedBox(height: 30),
                
                GFButton(
                  onPressed: _isLoading ? null : _continueAsGuest,
                  text: _isLoading ? "Creating guest session..." : "Continue as Guest",
                  textColor: Colors.black,
                  fullWidthButton: true,
                  size: GFSize.LARGE,
                  type: GFButtonType.solid,
                  color: const Color(0xFFF5E17A),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Note: Guest sessions are temporary and limited. Create an account for full access.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text('Sign In'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      ),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}