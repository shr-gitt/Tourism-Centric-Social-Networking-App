import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/decorhelper.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({super.key});

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(27.7172, 85.3240); // Kathmandu default
  LatLng _tempSelectedLocation = LatLng(27.7172, 85.3240);
  bool _selectingOnMap = true;

  void _onLocationSelected(LatLng position, String address) {
    setState(() {
      _selectedLocation = position;
      _tempSelectedLocation = position;
      _selectingOnMap = false;
    });
    _mapController.move(position, 15.0);
    log('Selected location from search: $address');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location on Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectingOnMap
                  ? _tempSelectedLocation
                  : _selectedLocation,
              initialZoom: 13,
              interactiveFlags: _selectingOnMap
                  ? InteractiveFlag.all
                  : InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              onPositionChanged: (pos, hasGesture) {
                if (_selectingOnMap && pos.center != null) {
                  setState(() {
                    _tempSelectedLocation = pos.center!;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),

              // Show fixed marker only when NOT selecting on map
              if (!_selectingOnMap)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
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

          // Fixed center marker while selecting on map
          if (_selectingOnMap)
            const Center(
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Colors.blueAccent,
              ),
            ),

          // Confirm button bottom-right (only while selecting)
          if (_selectingOnMap)
            Positioned(
              bottom: 40,
              right: 16,
              child: DecorHelper().buildGradientButton(
                onPressed: () {
                  setState(() {
                    _selectedLocation = _tempSelectedLocation;
                    _selectingOnMap = false;
                  });
                  _mapController.move(_selectedLocation, 15.0);
                  log('Location confirmed on map: $_selectedLocation');
                },
                child: const Text('    Confirm Location    '),
              ),
            ),
        ],
      ),
    );
  }
}
