import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/pages/MapPages/set_location.dart';
import 'package:latlong2/latlong.dart';
import '../Service/map_apiservice.dart';

class LocationSearchBar extends StatelessWidget {
  final Function(LatLng position, String address) onLocationSelected;
  final bool enabled;
  final bool frompost;

  const LocationSearchBar({
    super.key,
    required this.onLocationSelected,
    this.enabled = true,
    this.frompost = false,
  });

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: 'Search location',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search),
            suffix: frompost
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SetLocation()),
                      );
                      log('Set on map tapped');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          SizedBox(width: 4),
                          Text(
                            "Set on map",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      suggestionsCallback: MapApiservice().fetchLocationSuggestions,
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: Icon(Icons.location_on),
          title: Text(suggestion['display_name']),
        );
      },

      onSelected: (suggestion) {
        final lat = double.tryParse(suggestion['lat'] ?? '');
        final lon = double.tryParse(suggestion['lon'] ?? '');
        if (lat != null && lon != null) {
          final position = LatLng(lat, lon);
          final address = suggestion['display_name'];
          onLocationSelected(position, address);
        }
      },
    );
  }
}
