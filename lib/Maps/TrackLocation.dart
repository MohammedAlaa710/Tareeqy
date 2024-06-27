import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tareeqy_metro/Maps/locationSevicePermission.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackLocation extends StatefulWidget {
  const TrackLocation({super.key});

  @override
  State<TrackLocation> createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {
  void showNearestStationInfo(String nearestStationName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            height: 100.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Nearest Station to Your Location is: $nearestStationName',
              style: const TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  late CameraPosition initialCameraPosition;
  GoogleMapController? googleMapController;
  late MyLocation myLocation = MyLocation();
  late Location location = Location();
  bool firstRun = true;
  Set<Marker> vmarkers = {};

  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
        zoom: 1, target: LatLng(30.05761362397355, 31.228222800194313));
    getMyLocation();
    super.initState();
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  Set<Polyline> _polylines = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: vmarkers,
            polylines: _polylines,
            onMapCreated: (controller) {
              googleMapController = controller;
            },
            initialCameraPosition: initialCameraPosition,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  void getLocationData() async {
    location.changeSettings(
      distanceFilter: 2,
    );
    var markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/images/placeholder.png',
    );
    location.onLocationChanged.listen((locationData) async {
      if (!firstRun) {
        return; // Prevents multiple listeners after the first run
      }
      firstRun = false;
      var myLocationMarker = Marker(
        icon: markerIcon,
        markerId: const MarkerId('currentID'),
        position: LatLng(locationData.latitude!, locationData.longitude!),
        infoWindow: const InfoWindow(
          title: 'My Location',
          snippet:
              'The location of this icon changes by changing your location',
        ),
      );
      vmarkers.add(myLocationMarker);

      var cameraPosition = CameraPosition(
        target: LatLng(locationData.latitude!, locationData.longitude!),
        zoom: 17,
      );
      googleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      // Get the nearest station
      var nearestStation = await getNearestStation(locationData);
      var data = nearestStation.data() as Map<String, dynamic>;
      String nearestStationName = data['name'];
      showNearestStationInfo(nearestStationName);
      GeoPoint? stationLocation = data['latlng'];
      if (stationLocation != null) {
        var stationMarker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          markerId: const MarkerId('stationID'),
          position: LatLng(stationLocation.latitude, stationLocation.longitude),
          infoWindow: InfoWindow(
            title: data['name'],
            snippet: 'Nearest Station',
          ),
        );
        vmarkers.add(stationMarker);
        var directions = await getDirections(
          LatLng(locationData.latitude!, locationData.longitude!),
          LatLng(stationLocation.latitude, stationLocation.longitude),
        );

        var polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: directions,
          width: 5,
        );
        _polylines.add(polyline);
        setState(() {
          vmarkers = vmarkers;
          _polylines = _polylines;
        });
      }
    });
  }

  void getMyLocation() async {
    await myLocation.caheckAndRqstLocService();
    var permStatus = await myLocation.caheckAndRqstLocPerm();
    if (permStatus) {
      getLocationData();
    } else {}
  }
}

Future<DocumentSnapshot> getNearestStation(LocationData currentLocation) async {
  var firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> allStations = [];

  for (var i = 1; i <= 3; i++) {
    var stations = await firestore.collection('Metro_Line_$i').get();
    allStations.addAll(stations.docs);
  }

  // Find the nearest station
  DocumentSnapshot? nearestStation;
  double smallestDistance = double.infinity;
  for (var station in allStations) {
    var data = station.data() as Map<String, dynamic>;
    GeoPoint? stationLocation = data['latlng'];

    if (stationLocation != null) {
      double distance = Geolocator.distanceBetween(
        currentLocation.latitude!,
        currentLocation.longitude!,
        stationLocation.latitude,
        stationLocation.longitude,
      );

      if (distance < smallestDistance) {
        smallestDistance = distance;
        nearestStation = station;
      }
    }
  }

  return nearestStation!;
}

Future<List<LatLng>> getDirections(
    LatLng startLocation, LatLng endLocation) async {
  var apiKey = 'AIzaSyCVPrGU9xGHdKiB6SQeGjrx8U2TYbaJDBk';
  var urlString = '${startLocation.latitude},${startLocation.longitude}';
  var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=$urlString&destination=${endLocation.latitude},${endLocation.longitude}&key=$apiKey&mode=walking');

  try {
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var routes = jsonResponse['routes'] as List;

      var overviewPolyline = routes[0]['overview_polyline']['points'];
      var points = decodePolyline(overviewPolyline);
      return points;
    } else {
      throw Exception('Failed to get directions: ${response.statusCode}');
    }
  } catch (error) {
    return [];
  }
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> points = <LatLng>[];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    LatLng p = LatLng(lat / 1E5, lng / 1E5);
    points.add(p);
  }

  return points;
}
