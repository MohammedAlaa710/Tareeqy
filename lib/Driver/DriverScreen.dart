import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tareeqy_metro/Driver/DriverFunctions.dart';
import 'package:tareeqy_metro/components/LogOutDialog.dart';
import 'package:tareeqy_metro/Driver/Camera.dart';
import 'package:tareeqy_metro/Driver/driverService.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final DriverService _driverService = DriverService();
  bool isPressed = false;
  bool openCamera = false;
  String _locationMessage = "Location: unknown";
  StreamSubscription<Position>? _positionStreamSubscription;
  final LogoutDialog logoutDialog = LogoutDialog();

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
    var status = await Permission.location.request();
    if (status.isGranted) {
      await _startLiveLocationUpdates();
    } else {
      setState(() {
        _locationMessage = "Location permission denied";
      });
      return;
    }

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
                  onPressed: () => logoutDialog.showLogoutDialog(context),
                  color: const Color.fromARGB(255, 252, 0, 0),
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
                        return const DriverFunctions();
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
}
