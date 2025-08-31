import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:geolocator/geolocator.dart';

class SetLocation extends StatefulWidget {
  const SetLocation({super.key});

  @override
  State<SetLocation> createState() => _SetLocationState();
}

class _SetLocationState extends State<SetLocation> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(
    27.7172,
    85.3240,
  ); // Kathmandu default
  LatLng _tempSelectedLocation = LatLng(27.7172, 85.3240);
  final bool _selectingOnMap = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToUserLocation();
    });
  }

  Future<void> _goToUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enable location services')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permissions are permanently denied'),
          ),
        );
      }
      return;
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _selectedLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_selectedLocation, 15.0);
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
                urlTemplate:
                    "https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.jpg?key=7cvVQJWrkuxmQg34BCzg",
                tileProvider: NetworkTileProvider(),
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
