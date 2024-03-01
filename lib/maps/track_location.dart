import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:tareeqy_metro/maps/sevices_permissions.dart';

class TrackLocation extends StatefulWidget {
  const TrackLocation({super.key});

  @override
  State<TrackLocation> createState() => _TrackLocationState();
}

class _TrackLocationState extends State<TrackLocation> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
          markers: vmarkers,
          onMapCreated: (controller) {
            googleMapController = controller;
          },
          initialCameraPosition: initialCameraPosition),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop(); // Navigate back to MetroScreen
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
        const ImageConfiguration(), 'assets/images/placeholder.png');

    location.onLocationChanged.listen((locationData) {
      //Marker
      var myLocationMarker = Marker(
        icon: markerIcon,
        markerId: const MarkerId('currentID'),
        position: LatLng(locationData.latitude!, locationData.longitude!),
        infoWindow: const InfoWindow(
          title: 'My Location',
          snippet:
              'the location of this icon changes by changing your location',
        ),
      );
      vmarkers.add(myLocationMarker);
      setState(() {});

      //Camera
      if (firstRun) {
        //Camera position
        var cameraPosition = CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 17,
        );
        //navigate
        var controller = googleMapController;
        if (controller != null) {
          controller
              .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
        }
      } else {
        var controller = googleMapController;
        if (controller != null) {
          controller.animateCamera(CameraUpdate.newLatLng(
              LatLng(locationData.latitude!, locationData.longitude!)));
        }
      }
      firstRun = false;
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
