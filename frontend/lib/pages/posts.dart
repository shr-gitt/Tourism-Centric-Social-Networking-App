import 'package:flutter/material.dart';
import 'package:frontend/pages/createpost.dart';

class posts extends StatelessWidget {
  const posts({super.key});

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
      body: Column(
        children: [
          Container(
            margin:EdgeInsets.all(15),
            padding:EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
              // styling container
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(children: [Text('1'), Text('2')]),
                    Column(children: [Text('1'), Text('2')]),
                  ],
                ),
                Row(
                  children: [
                    Column(children: [Text('1'), Text('2')]),
                    Column(children: [Text('1'), Text('2')]),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(15),
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            decoration: BoxDecoration(
              // styling container
              border: Border.all(width: 2),
              borderRadius: BorderRadius.circular(20)
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(height: 20),
                    Column(children: ([Text('Title',style: TextStyle(fontWeight: FontWeight.bold),)])),
                  ],
                ),
                Row(
                  children: [
                    Column(children: [Text('1'), Text('2')]),
                    Column(children: [Text('1'), Text('2')]),
                  ],
                ),
              ],
            ),
          ),
        ],
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
