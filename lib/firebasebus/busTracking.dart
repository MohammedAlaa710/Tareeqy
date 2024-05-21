import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusTrackingScreen extends StatelessWidget {
  final String busId;

  BusTrackingScreen(this.busId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Tracking'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Drivers')
            .where('busId', isEqualTo: busId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Marker> markers = [];
          snapshot.data!.docs.forEach((doc) {
            double latitude = doc['latitude'];
            double longitude = doc['longitude'];
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: doc['busId']),
              ),
            );
          });

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(0, 0), // Initial position (e.g., center of the map)
              zoom: 10.0, // Initial zoom level
            ),
            markers: Set<Marker>.of(markers),
          );
        },
      ),
    );
  }
}
