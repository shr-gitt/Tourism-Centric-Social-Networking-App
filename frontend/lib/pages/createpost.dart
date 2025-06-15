import 'package:flutter/material.dart';

class Createpost extends StatelessWidget {
  const Createpost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(border: Border.all(width: 5)),
            child: Column(
              children: [
                Text('Title'),
                TextField(keyboardType: TextInputType.numberWithOptions()),
                Text('Location'),
                TextField(),
                Text('Content'),
                TextField(),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}