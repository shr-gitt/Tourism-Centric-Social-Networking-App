import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapApiservice {
  Future<List<Map<String, dynamic>>> fetchLocationSuggestions(
    String query,
  ) async {
    final url = Uri.parse(
      //"https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query.toLowerCase())}&format=json&addressdetails=1&accept-language=en",
      "https://api.locationiq.com/v1/autocomplete?key=pk.1c1968f8d4c3b0690ae417a1735c6ce4&q=${Uri.encodeComponent(query.toLowerCase())}%20ne&limit=5&dedupe=1&",
    );
    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchLocationDetails(LatLng position) async {
    final url = Uri.parse(
      "https://us1.locationiq.com/v1/reverse?key=pk.1c1968f8d4c3b0690ae417a1735c6ce4&lat=${position.latitude}&lon=${position.longitude}&format=json&",
    );

    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});

    if (response.statusCode == 200) {
      final data = json.decode((response.body));
      log('Location details: $data');
      return data;
    } else {
      return throw (Exception("Failed to fetch location details"));
    }
  }

  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://us1.locationiq.com/v1/directions/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?alternatives=true&steps=true&annotations=distance,duration&geometries=geojson&key=pk.1c1968f8d4c3b0690ae417a1735c6ce4',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      // Convert to list of LatLng
      List<LatLng> routePoints = coords.map((point) {
        return LatLng(point[1], point[0]); // geojson is [lng, lat]
      }).toList();

      return routePoints;
    } else {
      throw Exception('Failed to load driving directions');
    }
  }
}
