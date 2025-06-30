import 'package:flutter/material.dart';
import 'package:frontend/pages/posts.dart';
import 'package:frontend/pages/search.dart';
import 'package:frontend/pages/createpost.dart';
import 'package:frontend/pages/notification.dart';
import 'package:frontend/pages/profile.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  int index = 0;

  List pages = [PostsPage(), Search(), Createpost(), Notify(), Profile()];

  @override
  Widget build(BuildContext context) {
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'New Post'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
