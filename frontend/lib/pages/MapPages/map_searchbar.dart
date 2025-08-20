import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:frontend/pages/MapPages/set_location.dart';
import 'package:latlong2/latlong.dart';
import '../Service/map_apiservice.dart';

class LocationSearchBar extends StatefulWidget {
  final Function(LatLng position, String address, String? county)
  onLocationSelected;
  final bool enabled;
  final bool frompost;

  const LocationSearchBar({
    super.key,
    required this.onLocationSelected,
    this.enabled = true,
    this.frompost = false,
  });

  @override
  State<LocationSearchBar> createState() => _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<Map<String, dynamic>>(
      controller: _controller,
      focusNode: _focusNode,
      builder: (context, _, _) {
        return TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.frompost ? 'Location' : 'Search location',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            suffix: widget.frompost
                ? InkWell(
                    onTap: () async {
                      log('Set on map tapped');
                      _focusNode.unfocus();

                      final LatLng? selectedPosition = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SetLocation(),
                        ),
                      );

                      if (selectedPosition != null) {
                        final data = await MapApiservice().fetchLocationDetails(
                          selectedPosition,
                        );

                        _controller.text = data['display_name'];
                        log(
                          'In set on map, $selectedPosition, ${data['display_name']}, ${data['address']['county']}',
                        );
                        widget.onLocationSelected(
                          selectedPosition,
                          data['display_name'],
                          data['address']['county'],
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
          leading: const Icon(Icons.location_on),
          title: Text(suggestion['display_name']),
        );
      },
      onSelected: (suggestion) {
        final lat = double.tryParse(suggestion['lat'] ?? '');
        final lon = double.tryParse(suggestion['lon'] ?? '');
        if (lat != null && lon != null) {
          final position = LatLng(lat, lon);
          final address = suggestion['display_name'];
          _controller.text = address;
          log(
            'In search bar, $position, $address, ${suggestion['address']['county']}',
          );
          widget.onLocationSelected(
            position,
            address,
            suggestion['address']['county'],
          );
        }
      },
    );
  }
}
