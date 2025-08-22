import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/pages/Postpages/community.dart';
import 'package:frontend/pages/Service/map_apiservice.dart';
import 'package:frontend/pages/decorhelper.dart';
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
  // ignore: unused_field
  String _selectedLocationAddress = "Kathmandu, Nepal"; // Default address

  // Method to show bottom sheet
  void _showLocationDetails(LatLng position, String address, String city) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "${address.split(',')[0]},${address.split(',')[1]}",
                style: TextStyle(fontSize: 25),
              ),
              Text(city, style: TextStyle(fontSize: 20)),
              SizedBox(height: 10),
              DecorHelper().buildGradientButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommunityPage(communityName: city),
                    ),
                  );
                },
                child: const Text('Go to community'),
              ),
              SizedBox(height: 16),

              Text("Latitude: ${position.latitude}"),
              Text("Longitude: ${position.longitude}"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13.0,
              onTap: (_, latLng) async {
                setState(() {
                  _selectedLocation = latLng;
                });
                // You can use a geocoding service here to get the address
                _selectedLocationAddress =
                    "New Address for the tapped location";
                // Show bottom sheet with location details
                final data = await MapApiservice().fetchLocationDetails(
                  _selectedLocation,
                );
                final name = data['address'];

                _showLocationDetails(
                  _selectedLocation,
                  data['display_name'],
                  name['county'],
                );
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
              onLocationSelected:
                  (LatLng position, String address, String? county) {
                    setState(() {
                      _selectedLocation = position;
                      _mapController.move(position, 15.0);
                      _selectedLocationAddress = address;
                    });
                    log('Selected location: $address');
                    _showLocationDetails(
                      position,
                      address,
                      county ?? "",
                    ); // Show bottom sheet when search is used
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
