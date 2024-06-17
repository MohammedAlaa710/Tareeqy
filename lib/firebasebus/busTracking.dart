import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusTrackingScreen extends StatelessWidget {
  final String busId;

  const BusTrackingScreen(this.busId, {super.key});

  LatLng _getBoundsCenter(LatLngBounds bounds) {
    final double centerLat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final double centerLng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(centerLat, centerLng);
  }

  @override
  Widget build(BuildContext context) {
    print('hi: BusTrackingScreen build method called');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Tracking'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Drivers')
            .where('busId', isEqualTo: busId)
            .snapshots(),
        builder: (context, snapshot) {
          print('hi: StreamBuilder builder method called');
          if (!snapshot.hasData) {
            print('hi: No data in snapshot');
            return const Center(child: CircularProgressIndicator());
          }

          List<Marker> markers = [];
          LatLngBounds? bounds;

          if (snapshot.data!.docs.isNotEmpty) {
            double minLat = snapshot.data!.docs.first['latitude'];
            double maxLat = snapshot.data!.docs.first['latitude'];
            double minLng = snapshot.data!.docs.first['longitude'];
            double maxLng = snapshot.data!.docs.first['longitude'];

            for (var doc in snapshot.data!.docs) {
              double latitude = doc['latitude'];
              double longitude = doc['longitude'];
              int facesNumber = doc['facesnumber']; 
              // Get the number of passengers

              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: doc['busId'],
                    snippet: 'Passengers: $facesNumber', // Display passengers
                  ),
                ),
              );
if
              if (latitude < minLat) minLat = latitude;
              if (latitude > maxLat) maxLat = latitude;
              if (longitude < minLng) minLng = longitude;
              if (longitude > maxLng) maxLng = longitude;
              print('hi: Marker added for driver lat :  ${latitude} and lng : ${longitude} for ${doc.id}');
              print('hi: Marker added for driver with face numbers ${facesNumber}');
              print('hi: Marker added for driver with doc id ${doc.id}');
            }

            bounds = LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            );
          } else {
            bounds = LatLngBounds(
              southwest: LatLng(0, 0),
              northeast: LatLng(0, 0),
            );
          }

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getBoundsCenter(bounds),
              zoom: 10.0, // Initial zoom level
            ),
            markers: Set<Marker>.of(markers),
            onMapCreated: (GoogleMapController controller) {
              print('hi: GoogleMap onMapCreated called');
              Future.delayed(const Duration(milliseconds: 500)).then((_) {
                controller.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 50));
                print('hi: Camera animated to bounds');
              });
            },
          );
        },
      ),
    );
  }
}
