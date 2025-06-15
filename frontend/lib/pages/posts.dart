import 'package:flutter/material.dart';

class posts extends StatelessWidget {
  const posts({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
        leading: ElevatedButton(
          child: Text('Back'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5), // padding inside container
            decoration: BoxDecoration(
              // styling container
              border: Border.all(width: 5),
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
            padding: EdgeInsets.all(5), // padding inside container
            decoration: BoxDecoration(
              // styling container
              border: Border.all(width: 5),
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
        ],
      ),
      
    );
  }
}
