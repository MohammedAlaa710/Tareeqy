import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

class BusTrackingScreen extends StatefulWidget {
  final String busId;

  const BusTrackingScreen(this.busId, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BusTrackingScreenState createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  late GoogleMapController _mapController;
  LocationData? _currentLocation;
  final Location _locationService = Location();
  BitmapDescriptor? _userLocationIcon;
  BitmapDescriptor? _busIcon;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCustomMarkers() async {
    _userLocationIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/placeholder.png');
    _busIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/images/bus-icon-marker.png');
  }

  Future<void> _requestLocationPermission() async {
    var permissionStatus = await _locationService.requestPermission();
    if (permissionStatus == PermissionStatus.granted) {
      _locationSubscription =
          _locationService.onLocationChanged.listen((locationData) {
        if (mounted) {
          setState(() {
            _currentLocation = locationData;
          });
        }
      });
    }
  }

  LatLng _getBoundsCenter(LatLngBounds bounds) {
    final double centerLat =
        (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    final double centerLng =
        (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(centerLat, centerLng);
  }

  double _calculateDistance(
      double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Tracking'),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Drivers')
                .where('busId', isEqualTo: widget.busId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Marker> markers = [];
              LatLngBounds? bounds;

              if (snapshot.data!.docs.isNotEmpty) {
                double? minLat, maxLat, minLng, maxLng;

                for (var doc in snapshot.data!.docs) {
                  bool work = doc['work'];
                  if (!work) continue;

                  double latitude = doc['latitude'].toDouble();
                  double longitude = doc['longitude'].toDouble();
                  int facesNumber = doc['facesnumber'];
                  int availableSeats = 24 - facesNumber;
                  markers.add(
                    Marker(
                      markerId: MarkerId(doc.id),
                      position: LatLng(latitude, longitude),
                      icon: _busIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: InfoWindow(
                        title: doc['busId'],
                        snippet: 'Available Seats: $availableSeats',
                      ),
                    ),
                  );

                  if (minLat == null || latitude < minLat) minLat = latitude;
                  if (maxLat == null || latitude > maxLat) maxLat = latitude;
                  if (minLng == null || longitude < minLng) minLng = longitude;
                  if (maxLng == null || longitude > maxLng) maxLng = longitude;
                }

                if (_currentLocation != null) {
                  markers.add(
                    Marker(
                      markerId: const MarkerId('userLocation'),
                      position: LatLng(_currentLocation!.latitude!,
                          _currentLocation!.longitude!),
                      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
                      infoWindow: const InfoWindow(title: 'You are here'),
                    ),
                  );
                  if (minLat == null || _currentLocation!.latitude! < minLat) {
                    minLat = _currentLocation!.latitude!;
                  }
                  if (maxLat == null || _currentLocation!.latitude! > maxLat) {
                    maxLat = _currentLocation!.latitude!;
                  }
                  if (minLng == null || _currentLocation!.longitude! < minLng) {
                    minLng = _currentLocation!.longitude!;
                  }
                  if (maxLng == null || _currentLocation!.longitude! > maxLng) {
                    maxLng = _currentLocation!.longitude!;
                  }
                }

                if (minLat != null &&
                    maxLat != null &&
                    minLng != null &&
                    maxLng != null) {
                  bounds = LatLngBounds(
                    southwest: LatLng(minLat, minLng),
                    northeast: LatLng(maxLat, maxLng),
                  );
                }
              } else {
                bounds = LatLngBounds(
                  southwest: const LatLng(0, 0),
                  northeast: const LatLng(0, 0),
                );
              }

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: bounds != null
                      ? _getBoundsCenter(bounds)
                      : const LatLng(0, 0),
                  zoom: 10.0,
                ),
                markers: Set<Marker>.of(markers),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  if (bounds != null) {
                    Future.delayed(const Duration(milliseconds: 500)).then((_) {
                      _mapController.animateCamera(
                          CameraUpdate.newLatLngBounds(bounds!, 50));
                    });
                  }
                },
              );
            },
          ),
          if (_currentLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Drivers')
                      .where('busId', isEqualTo: widget.busId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<Map<String, dynamic>> busData = [];

                    for (var doc in snapshot.data!.docs) {
                      bool work = doc['work'];
                      if (!work) continue;

                      double latitude = doc['latitude'].toDouble();
                      double longitude = doc['longitude'].toDouble();
                      int facesNumber = doc['facesnumber'];
                      int availableSeats = 24 - facesNumber;
                      double distance = _calculateDistance(
                          _currentLocation!.latitude!,
                          _currentLocation!.longitude!,
                          latitude,
                          longitude);

                      busData.add({
                        'busId': doc['busId'],
                        'latitude': latitude,
                        'longitude': longitude,
                        'availableSeats': availableSeats,
                        'distance': distance,
                      });
                    }

                    busData
                        .sort((a, b) => a['distance'].compareTo(b['distance']));

                    return ListView.builder(
                      itemCount: busData.length,
                      itemBuilder: (context, index) {
                        return BusInfoCard(
                          busId: busData[index]['busId'],
                          availableSeats: busData[index]['availableSeats'],
                          distance: busData[index]['distance'],
                          onTap: () {
                            _mapController.animateCamera(
                              CameraUpdate.newLatLng(
                                LatLng(busData[index]['latitude'],
                                    busData[index]['longitude']),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BusInfoCard extends StatelessWidget {
  final String busId;
  final int availableSeats;
  final double distance;
  final VoidCallback onTap;

  const BusInfoCard({
    super.key,
    required this.busId,
    required this.availableSeats,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_bus, size: 40.0, color: Colors.blue),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    busId,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Available Seats: $availableSeats'),
                  Text('Distance: ${distance.toStringAsFixed(2)} meters'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
