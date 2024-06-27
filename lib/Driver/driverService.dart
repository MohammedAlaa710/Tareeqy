import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tareeqy_metro/Maps/locationSevicePermission.dart';

class DriverService {
  Timer? _timer;
  final MyLocation _myLocation = MyLocation();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

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
        distanceFilter: 10,
      ),
    );
  }

  Future<void> sendLocationToFirestore(Position position) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .update({
        'work': true,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

////////////////////////////////////////////////////////////////
  Future<void> stopWork() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .update({
        'work': false,
        'facesnumber': 0,
        'latitude': 0.0,
        'longitude': 0.0,
      });
    }
  }

////////////////////////////////////////////////////////////////
  Future<void> sendFaceCountToFirestore(int faceCount) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection('Drivers').doc(userId);
          transaction.update(docRef, {'facesnumber': faceCount});
        });
      } catch (e) {
        print("Failed to update facesnumber: $e");
      }
    }
  }

  void startSendingLocation() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await getCurrentLocation();
        await sendLocationToFirestore(position);
      } catch (e) {
        print(e);
      }
    });
  }

  void stopSendingLocation() {
    _timer?.cancel();
  }
}
