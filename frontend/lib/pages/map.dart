import 'dart:developer';
import 'package:frontend/pages/Userpages/user_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  late MapController controller;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();
    controller = MapController.withPosition(
      initPosition: GeoPoint(
        latitude: 27.7172,
        longitude: 85.3240,
      ), // Kathmandu
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
        actions: [
          IconButton(
            onPressed: () {
              log('Settings button pressed');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => UserSettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: OSMFlutter(
        controller: controller,
        osmOption: OSMOption(
          userTrackingOption: const UserTrackingOption(
            enableTracking: false,
            unFollowUser: false,
          ),
          zoomOption: const ZoomOption(
            initZoom: 12,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          roadConfiguration: const RoadOption(roadColor: Colors.yellowAccent),
        ),
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        onMapIsReady: (ready) {
          if (ready) {
            setState(() {
              isMapReady = true;
            });
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "zoomIn",
            onPressed: () {
              if (isMapReady) {
                controller.zoomIn();
              }
            },
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoomOut",
            onPressed: () {
              if (isMapReady) {
                controller.zoomOut();
              }
            },
            child: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
