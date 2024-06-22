import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/admin/adminHomePage.dart';
import 'package:tareeqy_metro/drivers/driverScreen.dart';
import 'package:tareeqy_metro/homepage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void storeUserData(String userName, String email, BuildContext context,
      {String? collection = "users", String? busId}) {
    String? userId = _auth.currentUser?.uid;
    if (collection == 'users') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
            'userName': userName,
            'email': email,
            'isAdmin': false,
            'qrCodes': [],
            'busTickets': [],
            'wallet': "0.0",
          })
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Registration Succeeded, Welcome to Tareeqy!")),
              ))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registration Failed!")),
              ));
    } else if (collection == 'Drivers') {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .set({
            'userName': userName,
            'email': email,
            'busId': busId,
            'latitude': 0.0,
            'longitude': 0.0,
            'facesnumber': 0,
            'work': false,
          })
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Driver is added successfully!")),
              ))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Driver is not added successfully!")),
              ));
    }
  }

  Future<bool?> checkIsAdmin() async {
    String? userId = _auth.currentUser?.uid;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (snapshot.exists) {
        return snapshot.get('isAdmin');
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting user field: $e');
      return null;
    }
  }

  Future<bool> checkIsDriver() async {
    print("Hi from check driver");
    String? userId = _auth.currentUser?.uid;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .doc(userId)
          .get();
      print("Hi from check driver 2${snapshot.exists}");
      print("Hi from check driver userid {$userId}");
      return snapshot.exists;
    } catch (e) {
      print('Error checking if user is a driver: $e');
      return false;
    }
  }

  void checkCurrentUser(BuildContext context) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        bool? isAdmin = await checkIsAdmin();
        if (isAdmin != null) {
          if (isAdmin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          bool isDriver = await checkIsDriver();
          if (isDriver) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DriverScreen()),
            );
          } else {
            print('isAdmin and isDriver not found or null');
            // Handle case where isAdmin field is not found or null
          }
        }
      } catch (e) {
        print('Error checking user admin status: $e');
        // Handle error
      }
    }
  }
}
