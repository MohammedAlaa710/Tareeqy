import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearestMetroStation extends StatefulWidget {
  const NearestMetroStation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NearestMetroStationState createState() => _NearestMetroStationState();
}

class _NearestMetroStationState extends State<NearestMetroStation> {
  GoogleMapController? googleMapController;
  Set<Marker> _markers = {};
  String nearestMetroStation = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Metro Station'),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: (controller) => googleMapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(30.0444, 31.2357),
              zoom: 12.0,
            ),
            markers: _markers,
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: ElevatedButton(
              onPressed: () {
                _getNearestMetroStation();
              },
              child: const Text('Find Nearest Metro Station'),
            ),
          ),
        ],
      ),
    );
  }

  void _getNearestMetroStation() async {
    const String apiKey = 'AIzaSyBgNZPaH2U2ODReBKD-DVdPCrzDoZBw6QM';
    const String placesEndpoint =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    LatLng currentLocation =
        const LatLng(30.080944926478765, 31.24511076711392);

    final response = await http.get(
      Uri.parse(
        '$placesEndpoint?location=${currentLocation.latitude},${currentLocation.longitude}'
        '&radius=5000'
        '&type=subway_station'
        '&key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        return;
      }
      List<dynamic> results = data['results'];
      if (results.isNotEmpty) {
        double lat = results[0]['geometry']['location']['lat'];
        double lng = results[0]['geometry']['location']['lng'];
        String name = results[0]['name'];

        setState(() {
          _markers = {
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
            )
          };
          nearestMetroStation = 'Nearest metro station: $name';
          var cameraPosition = CameraPosition(
            target: LatLng(lat, lng),
            zoom: 17,
          );
          var controller = googleMapController;
          if (controller != null) {
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
          }
        });
      } else {
        setState(() {
          nearestMetroStation = 'No metro stations found nearby.';
        });
      }
    }
  }
}
