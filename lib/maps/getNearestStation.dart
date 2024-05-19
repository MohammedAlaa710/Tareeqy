import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearestMetroStationScreen extends StatefulWidget {
  const NearestMetroStationScreen({super.key});

  @override
  _NearestMetroStationScreenState createState() =>
      _NearestMetroStationScreenState();
}

class _NearestMetroStationScreenState extends State<NearestMetroStationScreen> {
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
              target: LatLng(30.0444, 31.2357), // Cairo coordinates
              zoom: 12.0,
            ),
            markers: _markers,
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            child: ElevatedButton(
              onPressed: () {
                print("hacall el func");
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
    print("inside the func");
    const String apiKey = 'AIzaSyBgNZPaH2U2ODReBKD-DVdPCrzDoZBw6QM';
    const String placesEndpoint =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    // Replace with your current location
    LatLng currentLocation =
        const LatLng(30.080944926478765, 31.24511076711392);

    // Make a request to the Places API
    final response = await http.get(
      Uri.parse(
        '$placesEndpoint?location=${currentLocation.latitude},${currentLocation.longitude}'
        '&radius=5000' // You can adjust the radius as needed
        '&type=subway_station' // Type for metro stations
        '&key=$apiKey',
      ),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      //test
      // Before decoding
      print('Response body: ${response.body}');

// Decode the JSON response
      final Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('Error decoding JSON: $e');
        return;
      }

// After decoding
      print('Decoded data: $data');

      //

      // Extract the nearest metro station from the response
      List<dynamic> results = data['results'];
      print(data['results']);
      print(results.isEmpty);
      print("ha5osh is empty");
      if (results.isNotEmpty) {
        double lat = results[0]['geometry']['location']['lat'];
        double lng = results[0]['geometry']['location']['lng'];
        String name = results[0]['name'];

        // Update the map with the nearest metro station marker
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
          print(nearestMetroStation);
        });
      } else {
        setState(() {
          nearestMetroStation = 'No metro stations found nearby.';
        });
      }
    } else {
      print('Error: ${response.reasonPhrase}');
    }
  }
}
