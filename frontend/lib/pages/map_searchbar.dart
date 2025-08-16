import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapSearchBar extends StatefulWidget {
  final MapController mapController;
  final Function(LatLng) onLocationSelected;

  const MapSearchBar({
    super.key,
    required this.mapController,
    required this.onLocationSelected,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {'User-Agent': 'FlutterMapSearchApp/1.0'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final picked = LatLng(lat, lon);

        widget.mapController.move(picked, 15.0);
        widget.onLocationSelected(picked);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location not found')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search location',
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _searchLocation(_searchController.text),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: _searchLocation,
    );
  }
}
