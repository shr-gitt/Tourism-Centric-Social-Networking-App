import 'package:flutter/material.dart';
import 'package:frontend/pages/createpost.dart';
import 'package:frontend/data/posts_data.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  // Method to build each post container
  Widget buildPost(post) {
    return Container(
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['title'] ?? 'No Title',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(post['content'] ?? 'No Content'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        leading: ElevatedButton(
          child: Text('<'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: postList.length,
        itemBuilder: (context, index) => buildPost(postList[index]),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Createpost()),
          );
        },
      ),
    );
  }
}
