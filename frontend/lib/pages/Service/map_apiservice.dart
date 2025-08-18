import 'dart:convert';
import 'package:http/http.dart' as http;

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
}
