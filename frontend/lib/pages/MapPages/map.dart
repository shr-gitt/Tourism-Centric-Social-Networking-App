// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:frontend/pages/MapPages/path_recorder.dart';
import 'package:frontend/pages/Postpages/community.dart';
import 'package:frontend/pages/Service/map_apiservice.dart';
import 'package:frontend/pages/decorhelper.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/pages/MapPages/map_searchbar.dart';
import 'package:geolocator/geolocator.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  MapState createState() => MapState();
}

class MapState extends State<Map> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = LatLng(
    27.678236,
    85.316853,
  ); //default to kathmandu
  // ignore: unused_field
  String _selectedLocationAddress = "Kathmandu, Nepal"; // Default address
  List<LatLng> _routePoints = [];
  LatLng? _tempSelectedLocation;

  // ignore: prefer_final_fields
  List<LatLng> _recordedPath = [];
  late StreamSubscription<Position> _positionStreamSubscription;
  bool _isRecording = false;
  late DateTime _startTime;
  DateTime? _endTime;
  bool _showRecordingStats = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToUserLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_isRecording) {
      _positionStreamSubscription.cancel();
    }
    _updateTimer?.cancel();
  }

  // Method to show bottom sheet
  void _showLocationDetails(LatLng position, String address, String city) {
    String locationDescription = DecorHelper().generateLocationDescription(
      city.isNotEmpty ? city : "Unknown",
      "Nepal",
    );

    final parts = address.split(',');
    final displayAddress = parts.length >= 2
        ? "${parts[0]},${parts[1]}"
        : address;

    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.2,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(displayAddress, style: TextStyle(fontSize: 25)),
                  Text(
                    city.isNotEmpty ? city : "Nepal",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  DecorHelper().buildGradientButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityPage(
                            communityName: city.isNotEmpty ? city : "Nepal",
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to community'),
                  ),

                  SizedBox(height: 10),

                  DecorHelper().buildGradientButton(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                      _getRoute();
                    },
                    child: const Text('Drive to location'),
                  ),
                  SizedBox(height: 16),
                  Text(locationDescription),
                ],
              ),
            );
          },
        );
      },
    );
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
      _tempSelectedLocation = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_selectedLocation, 15.0);
  }

  void _getRoute() async {
    if (_tempSelectedLocation == null) {
      log('Start or destination is null');
      return;
    }

    try {
      final route = await MapApiservice().fetchRoute(
        _selectedLocation,
        _tempSelectedLocation!,
      );
      setState(() {
        _routePoints = route;
      });
      _fitMapToRoute();
    } catch (e) {
      log('Error getting route: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch route. Please try again.')),
        );
      }
    }
  }

  void _fitMapToRoute() {
    if (_routePoints.length < 2) {
      log("Not enough route points to create bounds.");
      return;
    }

    try {
      final bounds = LatLngBounds.fromPoints(_routePoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: EdgeInsets.all(50)),
      );
    } catch (e) {
      log("Error fitting camera to bounds: $e");
    }
  }

  void _startLocationTracking() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }

    _startTime = DateTime.now();

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          setState(() {
            _recordedPath.add(LatLng(position.latitude, position.longitude));
            log('Adding point to recorded path');
          });
        });

    // Add timer to update UI every second
    _updateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          // This will trigger a rebuild and update the duration display
        });
      }
    });

    setState(() {
      _isRecording = true;
      _showRecordingStats = true;
      log('Started recording: $_isRecording');
    });
  }

  void _stopRecording() {
    _endTime = DateTime.now();
    _positionStreamSubscription.cancel();
    _updateTimer?.cancel(); // Stop the update timer

    setState(() {
      _isRecording = false;
      // Keep _showRecordingStats = true so stats remain visible
    });
  }

  // Add new method to clear/cancel the recording stats
  void _clearRecordingStats() {
    _updateTimer?.cancel(); // Make sure timer is cancelled

    setState(() {
      _showRecordingStats = false;
      _recordedPath.clear();
      _endTime = null;
    });
  }

  double _calculateTotalDistance() {
    double totalDistance = 0;
    for (int i = 1; i < _recordedPath.length; i++) {
      totalDistance += Geolocator.distanceBetween(
        _recordedPath[i - 1].latitude,
        _recordedPath[i - 1].longitude,
        _recordedPath[i].latitude,
        _recordedPath[i].longitude,
      );
    }
    return totalDistance;
  }

  String _formatDuration(int seconds) {
    int hours = (seconds / 3600).floor();
    int minutes = ((seconds % 3600) / 60).floor();
    int remainingSeconds = seconds % 60;
    return "$hours h $minutes m $remainingSeconds s";
  }

  @override
  Widget build(BuildContext context) {
    double totalDistance = _calculateTotalDistance();
    int totalDurationInSeconds = _isRecording
        ? DateTime.now().difference(_startTime).inSeconds
        : (_endTime != null ? _endTime!.difference(_startTime).inSeconds : 0);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 5),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onTap: (_, latLng) async {
                setState(() {
                  _selectedLocation = latLng;
                });
                // You can use a geocoding service here to get the address
                _selectedLocationAddress =
                    "New Address for the tapped location";
                // Show bottom sheet with location details
                try {
                  final data = await MapApiservice().fetchLocationDetails(
                    _selectedLocation,
                  );
                  final name = data['address'];
                  _showLocationDetails(
                    _selectedLocation,
                    data['display_name'],
                    name['county'],
                  );
                } catch (e) {
                  log('Failed to fetch location details: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to get location details. Please try again.',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.jpg?key=7cvVQJWrkuxmQg34BCzg",
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

              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points:
                          _routePoints, // The list you get from fetchRoute()
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),

              if (_showRecordingStats) // Changed from _isRecording
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _recordedPath,
                      strokeWidth: 4,
                      color: Colors.red,
                    ),
                  ],
                ),
            ],
          ),

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
          // Distance and Duration Display (Updated)
          if (_showRecordingStats)
            Positioned(
              top: 80,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecording
                              ? Icons.fiber_manual_record
                              : Icons.stop_circle,
                          color: _isRecording ? Colors.red : Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _isRecording ? "Recording..." : "Recording Complete",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _isRecording ? Colors.red : Colors.green,
                          ),
                        ),
                        SizedBox(width: 12),
                        // Clear button
                        GestureDetector(
                          onTap: _clearRecordingStats,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Distance: ${(totalDistance / 1000).toStringAsFixed(2)} km",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Duration: ${_formatDuration(totalDurationInSeconds)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*
          FloatingActionButton(
            heroTag: "Record",

            onPressed: () {
              // Navigate to PathRecorderPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PathRecorderPage(),
                ),
              );
            },
            child: Icon(
              Icons.radio_button_checked_rounded,
            ), // Use a custom icon for navigation
          ),
          SizedBox(height: 8),*/
          FloatingActionButton(
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              } else if (_showRecordingStats) {
                // If stats are showing but not recording, start new recording
                _clearRecordingStats(); // Clear previous stats first
                _startLocationTracking();
              } else {
                _startLocationTracking();
              }
            },
            child: Icon(
              _isRecording
                  ? Icons.stop
                  : _showRecordingStats
                  ? Icons.refresh
                  : Icons.play_arrow,
            ),
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoomIn",
            onPressed: () {
              double newZoom = _mapController.camera.zoom + 1;
              newZoom = newZoom.clamp(
                3.0,
                18.0,
              ); // Clamping zoom level between 3.0 and 18.0
              _mapController.move(_mapController.camera.center, newZoom);
            },
            child: Icon(Icons.zoom_in),
          ),

          SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoomOut",
            onPressed: () {
              double newZoom = _mapController.camera.zoom - 1;
              newZoom = newZoom.clamp(3.0, 18.0);
              _mapController.move(_mapController.camera.center, newZoom);
            },
            child: Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }
}
