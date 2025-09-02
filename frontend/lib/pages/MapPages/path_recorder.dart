import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class PathRecorderPage extends StatefulWidget {
  const PathRecorderPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PathRecorderPageState createState() => _PathRecorderPageState();
}

class _PathRecorderPageState extends State<PathRecorderPage> {
  // ignore: prefer_final_fields
  List<LatLng> _recordedPath = [];
  late StreamSubscription<Position> _positionStreamSubscription;
  bool _isRecording = false;
  late DateTime _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_isRecording) {
      _positionStreamSubscription.cancel();
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
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((Position position) {
          setState(() {
            _recordedPath.add(LatLng(position.latitude, position.longitude));
          });
        });

    setState(() {
      _isRecording = true;
    });
  }

  void _stopRecording() {
    _endTime = DateTime.now();
    _positionStreamSubscription.cancel();
    setState(() {
      _isRecording = false;
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
      appBar: AppBar(
        title: Text("Path Recorder"),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _stopRecording();
              Navigator.pop(context); // Go back to the previous page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _recordedPath.isNotEmpty
                    ? _recordedPath.last
                    : LatLng(27.678236, 85.316853), // Default to Kathmandu
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.jpg?key=7cvVQJWrkuxmQg34BCzg",
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _recordedPath,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Distance: ${totalDistance.toStringAsFixed(2)} meters"),
                Text("Duration: ${_formatDuration(totalDurationInSeconds)}"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isRecording) {
            _stopRecording();
          } else {
            _startLocationTracking();
          }
        },
        child: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
