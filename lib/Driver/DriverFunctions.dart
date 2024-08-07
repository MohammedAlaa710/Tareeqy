import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tareeqy_metro/Driver/Camera.dart';
import 'package:tareeqy_metro/Driver/driverService.dart';

// ignore: camel_case_types
class DriverFunctions extends StatefulWidget {
  const DriverFunctions({super.key});

  @override
  State<DriverFunctions> createState() => _DriverFunctionsState();
}

class _DriverFunctionsState extends State<DriverFunctions> {
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
      appBar: AppBar(
        title: const Text(
          "Driver",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF073042),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073042),
                  minimumSize: const Size(250, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  "Open Camera",
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startLiveLocationUpdates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073042),
                  minimumSize: const Size(250, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text("Start Live Location Updates",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _stopLiveLocationUpdates,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073042),
                  minimumSize: const Size(250, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text("Stop Live Location Updates",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
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
}
