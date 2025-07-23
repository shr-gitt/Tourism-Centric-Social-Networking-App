import 'package:flutter/material.dart';
import 'package:frontend/pages/Authenticationpages/login.dart';
import 'package:frontend/pages/Authenticationpages/signup.dart';
import 'package:frontend/pages/mainscreen.dart';

class Guest extends StatefulWidget {
  const Guest({super.key});

  @override
  State<Guest> createState() => _GuestState();
}

class _GuestState extends State<Guest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Tourism-Centric Social Networking App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainScreen(currentIndex: 0)),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Sign In'),
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
          ],
        ),
      ),
    );
  }
}
