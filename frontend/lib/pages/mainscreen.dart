import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/Postpages/posts.dart';
import 'package:frontend/pages/MapPages/map.dart';
import 'package:frontend/pages/Postpages/createpost.dart';
import 'package:frontend/pages/notification.dart';
import 'package:frontend/pages/Userpages/profile.dart';

// ignore: must_be_immutable
class MainScreen extends StatefulWidget {
  int currentIndex;
  MainScreen({super.key, required this.currentIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;
  late int currentIndex;

  List pages = [PostsPage(), Map(), Createpost(), Notify(), Profile()];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex; // Initialize from parent
    log('In MainScreen, initial tab: $currentIndex');
  }

  @override
  Widget build(BuildContext context) {
    log('In mainscreen');
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Post'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        backgroundColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
