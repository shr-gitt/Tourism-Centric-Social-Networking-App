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
    String locationDescription = generateLocationDescription(city, "Nepal");

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

              Text(locationDescription),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map'), automaticallyImplyLeading: false),
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
