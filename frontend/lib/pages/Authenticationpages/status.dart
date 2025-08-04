import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/Authenticationpages/signup.dart';
import 'package:frontend/pages/mainscreen.dart';

class Status extends StatefulWidget {
  const Status({super.key, required this.title});
  final String title;

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  @override
  Widget build(BuildContext context) {
    log('In status page');
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.grey, title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Sign Up'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Log In'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Use as Guest User'),
              onPressed: () async {
                log('Guest');
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainScreen(currentIndex: 0),
                  ),
                );
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text('Continue with Google'),
              onPressed: () {
                // Call your external login API, or open the OAuth URL
              },
            ),
          ],
        ),
      ),
    );
  }
}
