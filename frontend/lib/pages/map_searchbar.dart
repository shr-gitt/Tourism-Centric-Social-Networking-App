import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class LocationSearchBar extends StatelessWidget {
  final Function(LatLng position, String address) onLocationSelected;

  const LocationSearchBar({super.key, required this.onLocationSelected});

  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(
    String query,
  ) async {
    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&accept-language=en",
    );
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'FlutterApp', 
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      suggestionsCallback: fetchLocationSuggestions,
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.location_on),
          title: Text(suggestion['display_name']),
        );
      },
      onSelected: (suggestion) {
        final lat = double.tryParse(suggestion['lat']);
        final lon = double.tryParse(suggestion['lon']);
        if (lat != null && lon != null) {
          final position = LatLng(lat, lon);
          final address = suggestion['display_name'];
          onLocationSelected(position, address);
        }
      },
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search location',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }
}
