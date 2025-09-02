import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/pages/MapPages/path_recorder.dart';
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
  }

  String generateLocationDescription(String city, String country) {
    if (city.toLowerCase() == 'kathmandu') {
      return '''Kathmandu, the capital of Nepal, is a vibrant city known for its rich history, temples, and cultural heritage. It is home to UNESCO World Heritage Sites like Swayambhunath (Monkey Temple) and Pashupatinath Temple. The city serves as a gateway to the Himalayas, attracting trekkers and mountaineers from around the world. Kathmandu is also a hub for arts, crafts, and traditional Nepali culture. It is the political, cultural, and economic center of Nepal.''';
    } else if (city.toLowerCase() == 'lalitpur') {
      return '''Lalitpur, also known as Patan, is one of the major cities of Nepal, located just south of Kathmandu. It is famous for its rich history, ancient temples, and Newar culture. Patan Durbar Square, a UNESCO World Heritage Site, showcases impressive architecture, art, and sculptures. The city is known for its craftsmanship, especially in metalwork and wood carving, and is home to the beautiful Patan Museum, which houses many religious and cultural artifacts.''';
    } else if (city.toLowerCase() == 'bhaktapur') {
      return '''Bhaktapur, an ancient city located east of Kathmandu, is renowned for its well-preserved medieval architecture and culture. The city is home to Bhaktapur Durbar Square, a UNESCO World Heritage Site, with stunning temples, courtyards, and shrines. Bhaktapur is famous for its festivals, arts, and crafts, particularly pottery. The city has a slower pace of life compared to Kathmandu, offering a glimpse into Nepal's traditional heritage.''';
    } else if (city.toLowerCase() == 'dhulikhel') {
      return '''Dhulikhel, a scenic town located about 30 kilometers east of Kathmandu, is known for its breathtaking views of the Himalayas, including peaks like Mount Everest and Langtang. It is a popular destination for trekking, hiking, and cultural experiences. Dhulikhel offers a glimpse of rural Nepali life, with its traditional Newar houses and temples. It is a peaceful getaway from the bustling Kathmandu Valley.''';
    } else if (city.toLowerCase() == 'pokhara') {
      return '''Pokhara, one of Nepal's most popular tourist destinations, is located in the central region of the country. Known for its stunning lakes like Phewa Lake and incredible views of the Annapurna mountain range, Pokhara is a hub for adventure tourism, including trekking, paragliding, and boating. The city is also famous for its vibrant atmosphere, with numerous restaurants, cafes, and shops catering to trekkers and tourists.''';
    } else if (city.toLowerCase() == 'lumbini') {
      return '''Lumbini, the birthplace of Lord Buddha, is located in the southwestern region of Nepal. It is a significant pilgrimage site for Buddhists from all over the world. The Lumbini Garden, where the Maya Devi Temple stands, is home to sacred monuments and peaceful surroundings. The site attracts thousands of visitors each year, who come to learn about Buddha's life and teachings.''';
    } else if (city.toLowerCase() == 'chitwan') {
      return '''Chitwan, located in the southern part of Nepal, is famous for the Chitwan National Park, a UNESCO World Heritage Site. The park is home to a diverse range of wildlife, including the endangered one-horned rhinoceros and Bengal tigers. Chitwan also offers opportunities for jungle safaris, bird watching, and canoeing in the Rapti River. It is a popular destination for nature lovers and wildlife enthusiasts.''';
    } else if (city.toLowerCase() == 'biratnagar') {
      return '''Biratnagar, located in the southeastern region of Nepal, is the second-largest city in the country. It is an industrial hub, with a growing economy based on agriculture, textiles, and manufacturing. Biratnagar is also known for its cultural diversity, with a mix of Hindu, Buddhist, and Muslim communities. The city is close to the border with India and serves as an important trade and commerce center.''';
    } else if (city.toLowerCase() == 'itahari') {
      return '''Itahari, a fast-growing city in the eastern region of Nepal, is known for its strategic location near the East-West Highway. It is an important commercial and transportation hub for the eastern part of the country. The city has a growing population and offers a range of services, including schools, hospitals, and shopping centers. Itahari is known for its pleasant climate and vibrant local markets.''';
    } else if (city.toLowerCase() == 'himalaya') {
      return '''The Himalayas, the world's highest mountain range, stretch across Nepal and several other countries in South Asia. Known for its towering peaks, including Mount Everest, the Himalayas are a paradise for trekkers, mountaineers, and nature enthusiasts. The region offers stunning landscapes, unique wildlife, and a rich cultural heritage, with many ethnic communities living in the foothills and valleys. The Himalayas attract adventurers from around the world.''';
    } else {
      return 'No detailed description available for this location.';
    }
  }

  // Method to show bottom sheet
  void _showLocationDetails(LatLng position, String address, String city) {
    String locationDescription = generateLocationDescription(
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
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((Position position) {
          setState(() {
            _recordedPath.add(LatLng(position.latitude, position.longitude));
            log('Adding in recordedpath');
          });
        });

    setState(() {
      log('In start recording before, $_isRecording');
      _isRecording = true;
      log('In start recording after, $_isRecording');
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

              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        "Distance: ${totalDistance.toStringAsFixed(2)} meters",
                      ),
                      Text(
                        "Duration: ${_formatDuration(totalDurationInSeconds)}",
                      ),
                    ],
                  ),
                ),
              if (_isRecording)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _recordedPath, // Recorded path
                      strokeWidth: 4,
                      color: Colors.red, // Color for the recording path
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
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              } else {
                _startLocationTracking();
              }
            },
            child: Icon(_isRecording ? Icons.stop : Icons.play_arrow),
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
