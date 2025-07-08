import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return GFCard(
      boxFit: BoxFit.cover,
      image: Image.asset('assets/images/_MG_6890.jpeg'),
      title: GFListTile(
        avatar: GFAvatar(
          backgroundImage: AssetImage('assets/images/_MG_6890.jpeg'),
          // or use the icon parameter if you want an icon:
          // icon: Icon(Icons.person),
        ),
        title: Text('Card Title'),
        subTitle: Text('Card Sub Title'),
      ),
    );
  }
}
