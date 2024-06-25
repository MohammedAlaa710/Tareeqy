import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusTrackingScreen extends StatelessWidget {
  final String busId;

  const BusTrackingScreen(this.busId, {super.key});

  LatLng _getBoundsCenter(LatLngBounds bounds) {
    final double centerLat =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final double centerLng =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
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
            double? minLat, maxLat, minLng, maxLng;

            for (var doc in snapshot.data!.docs) {
              bool work = doc['work'];
              if (!work) continue; // Skip if work is false

              double latitude = doc['latitude'].toDouble();
              double longitude = doc['longitude'].toDouble();
              int facesNumber =
                  doc['facesnumber']; // Get the number of passengers
              int availableSeats = 24 - facesNumber;
              markers.add(
                Marker(
                  markerId: MarkerId(doc.id),
                  position: LatLng(latitude, longitude),
                  infoWindow: InfoWindow(
                    title: doc['busId'],
                    snippet:
                        'Available Seats: $availableSeats', // Display passengers
                  ),
                ),
              );

              if (minLat == null || latitude < minLat) minLat = latitude;
              if (maxLat == null || latitude > maxLat) maxLat = latitude;
              if (minLng == null || longitude < minLng) minLng = longitude;
              if (maxLng == null || longitude > maxLng) maxLng = longitude;

              print(
                  'hi: Marker added for driver lat: $latitude and lng: $longitude for ${doc.id}');
              print(
                  'hi: Marker added for driver with face numbers $facesNumber');
              print('hi: Marker added for driver with doc id ${doc.id}');
            }

            if (minLat != null &&
                maxLat != null &&
                minLng != null &&
                maxLng != null) {
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
                controller
                    .animateCamera(CameraUpdate.newLatLngBounds(bounds!, 50));
                print('hi: Camera animated to bounds');
              });
            },
          );
        },
      ),
    );
  }
}
