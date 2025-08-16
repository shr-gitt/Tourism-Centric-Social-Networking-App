import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final MapController _mapController = MapController();
  LatLng _pickedLocation = LatLng(27.7172, 85.3240); // Default to Kathmandu

  void _confirmLocation() {
    log("Confirmed: $_pickedLocation");
  }

  void _updateLocation(LatLng newLocation) {
    setState(() {
      _pickedLocation = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Map Picker')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pickedLocation,
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  _updateLocation(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.map_picker_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _confirmLocation,
            child: const Text('Confirm Location'),
          ),
        ],
      ),
    );
  }
}
