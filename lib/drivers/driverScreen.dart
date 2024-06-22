import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tareeqy_metro/Auth/Login.dart';
import 'package:tareeqy_metro/drivers/FaceDetection.dart';
import 'package:tareeqy_metro/drivers/driverFunctions.dart';
import 'package:tareeqy_metro/drivers/driverService.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final DriverService _driverService = DriverService();
  bool isPressed = false;
  bool openCamera = false;
  String _locationMessage = "Location: unknown";
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLiveLocationUpdates() async {
    final position = await _driverService.getLiveLocationUpdates().first;
    setState(() {
      _locationMessage =
          "Location: ${position.latitude}, ${position.longitude}";
    });
    _positionStreamSubscription =
        _driverService.getLiveLocationUpdates().listen((Position position) {
      setState(() {
        _locationMessage =
            "Location: ${position.latitude}, ${position.longitude}";
      });
      // Optionally, send the location to Firestore
      _driverService.sendLocationToFirestore(position);
    }, onError: (e) {
      setState(() {
        _locationMessage = "Error: $e";
      });
    });
  }

  void _stopLiveLocationUpdates() {
    _positionStreamSubscription?.cancel();
    setState(() {
      _locationMessage = "Location updates stopped";
      _driverService.stopWork();
      openCamera = false;
    });
  }

  Future<void> _requestPermissionsAndStart() async {
    // Request location permission
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _startLiveLocationUpdates();
    } else {
      setState(() {
        _locationMessage = "Location permission denied";
      });
      return;
    }

    // Request camera permission
    status = await Permission.camera.request();
    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Camera(),
        ),
      );
    } else {
      setState(() {
        _locationMessage = "Camera permission denied";
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF073042),
            title: const Text(
              'Driver Screen',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _showLogoutDialog,
                  color: const Color(0xffAD3838),
                ),
              ),
            ]),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073042),
                  minimumSize: const Size(150, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const driverFunctions();
                      },
                    ),
                  );
                },
                child: const Text(
                  'Functions',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPressed
                      ? const Color(0xFFB31312)
                      : const Color(0xFF00796B),
                  minimumSize: const Size(150, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isPressed = !isPressed;
                  });
                  if (isPressed) {
                    _requestPermissionsAndStart();
                  } else {
                    _stopLiveLocationUpdates();
                  }
                },
                child: isPressed
                    ? const Text(
                        'Stop Work',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    : const Text(
                        'Start Work',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
              ),
              const SizedBox(height: 40),
              Text(
                _locationMessage,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }

  void _logout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xffAD3838),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
