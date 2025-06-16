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
            margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(border: Border.all(width: 2)),
            child: Column(
              children: [
                Text('Title'),
                TextField(keyboardType: TextInputType.numberWithOptions()),
                Text('Location'),
                TextField(),
                Text('Content',softWrap: true,),
                TextField(maxLines: null,),
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