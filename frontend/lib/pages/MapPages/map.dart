import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/MapPages/map_searchbar.dart';

class Map extends StatefulWidget {
  const Map({super.key});
  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(27.7172, 85.3240); //default to kathmandu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OSM Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13.0,
              onTap: (_, latLng) {
                setState(() {
                  _selectedLocation = latLng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                tileProvider: NetworkTileProvider(),
              ),

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

          /// Step 2 will add the Search bar here
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: LocationSearchBar(
              onLocationSelected: (LatLng position, String address) {
                setState(() {
                  _selectedLocation = position;
                  _mapController.move(position, 15.0);
                });
                log('Selected location: $address');
              },
              frompost: false,
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "zoomIn",
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
            child: Icon(Icons.zoom_in),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoomOut",
            onPressed: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
            child: Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
