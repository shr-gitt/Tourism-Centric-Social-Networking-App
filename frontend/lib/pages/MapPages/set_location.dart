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
  final LatLng _selectedLocation = LatLng(27.7172, 85.3240); // Kathmandu default
  LatLng _tempSelectedLocation = LatLng(27.7172, 85.3240);
  final bool _selectingOnMap = true;

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
              interactionOptions: _selectingOnMap
                  ? const InteractionOptions(flags: InteractiveFlag.all)
                  : const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
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
            ],
          ),

          // Fixed center marker while selecting on map
          if (_selectingOnMap)
            const Center(
              child: Icon(Icons.location_on_sharp, size: 40, color: Colors.red),
            ),

          // Confirm button bottom-right (only while selecting)
          Positioned(
            bottom: 50,
            right: 140,
            child: DecorHelper().buildGradientButton(
              onPressed: () {
                Navigator.pop(context, _tempSelectedLocation);
              },
              child: const Text('    Confirm Location    '),
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
