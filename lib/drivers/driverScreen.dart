// ignore_for_file: file_names, library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
      appBar: AppBar(title: const Text('Driver Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                "             Open camera             ",
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Camera(),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: _startLiveLocationUpdates,
              child: const Text("Start Live Location Updates"),
            ),
            ElevatedButton(
              onPressed: _stopLiveLocationUpdates,
              child: const Text("Stop Live Location Updates"),
            ),
            const SizedBox(height: 20),
            Text(_locationMessage),
          ],
        ),
      ),
    );
  }
}