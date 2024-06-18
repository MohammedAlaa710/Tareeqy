import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tareeqy_metro/Auth/Login.dart';
import 'package:tareeqy_metro/drivers/FaceDetection.dart';
import 'package:tareeqy_metro/drivers/driverService.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final DriverService _driverService = DriverService();
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

  void _startLiveLocationUpdates() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Screen'), actions: [
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text(
                  "Open Camera",
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  print("on pressed camer");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Camera(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startLiveLocationUpdates,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("Start Live Location Updates",
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _stopLiveLocationUpdates,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text("Stop Live Location Updates",
                    style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
              Text(
                _locationMessage,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
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
              Icon(Icons.logout, color: Color(0xffAD3838)),
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
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
                Navigator.of(context).pop(); // Dismiss the dialog
                _logout(context); // Call the logout method
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
