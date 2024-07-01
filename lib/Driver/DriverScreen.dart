import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
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
  String? _username;
  String? _busNumber;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _fetchUserData();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _firestore
            .collection('Drivers')
            .doc(user.uid)
            .snapshots()
            .listen((userDoc) {
          if (userDoc.exists) {
            if (mounted) {
              setState(() {
                _username = userDoc.data()!['userName'];
                _busNumber = userDoc.data()!['busId'];
              });
            }
          }
        });
      } catch (e) {
        print('Error fetching user document: $e');
      }
    }
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
      ),
      body: SafeArea(
        child: PageView(
          children: [
            _buildHomePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 240,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF073042),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello Driver,',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_username',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Center(
                      child: Text(
                        'Driver of Bus ${_busNumber ?? ""}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => logoutDialog.showLogoutDialog(context),
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 150),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isPressed ? const Color(0xFFB31312) : const Color(0xFF00796B),
              minimumSize: const Size(150, 50),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
