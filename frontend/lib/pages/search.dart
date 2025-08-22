import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:frontend/pages/mainscreen.dart';
import 'package:getwidget/getwidget.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    List list = ["Kathmandu", "Lalitpur", "Bhaktapur", "Pokhara"];
    return Scaffold(
      appBar: AppBar(title: Text('Search Page')),
      body: GFSearchBar(
        searchList: list,
        searchQueryBuilder: (query, list) {
          return list
              .where((item) => item.toLowerCase().contains(query.toLowerCase()))
              .toList();
        },
        overlaySearchListItemBuilder: (item) {
          return Container(
            padding: const EdgeInsets.all(5),
            child: Text(item, style: const TextStyle(fontSize: 18)),
          );
        },
        onItemSelected: (item) {
          setState(() {
            log('$item');
          });
        },
      ),
    );
  }
}
