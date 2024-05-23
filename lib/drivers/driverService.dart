import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tareeqy_metro/maps/sevices_permissions.dart';

class DriverService {
  Timer? _timer;
  final MyLocation _myLocation = MyLocation();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Get the driver's current location
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await _myLocation.caheckAndRqstLocService();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    bool permissionGranted = await _myLocation.caheckAndRqstLocPerm();
    if (!permissionGranted) {
      throw const PermissionDeniedException('Location permission denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Get live location updates as a stream
  Stream<Position> getLiveLocationUpdates() async* {
    bool serviceEnabled = await _myLocation.caheckAndRqstLocService();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    bool permissionGranted = await _myLocation.caheckAndRqstLocPerm();
    if (!permissionGranted) {
      throw const PermissionDeniedException('Location permission denied');
    }
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update distance filter as needed
      ),
    );
  }

  // Send location to Firestore
  Future<void> sendLocationToFirestore(Position position) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      print("senlocationtofirestore error");
    }
  }

  // Start sending location updates periodically
  void startSendingLocation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await getCurrentLocation();
        await sendLocationToFirestore(position);
      } catch (e) {
        // Handle the exception, e.g., log it or show a message to the user
        print(e);
      }
    });
  }

  // Stop sending location updates
  void stopSendingLocation() {
    _timer?.cancel();
  }
}
