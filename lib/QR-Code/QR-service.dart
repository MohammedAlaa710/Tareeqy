import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';

class QRservices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String dropdownValue = '15 egp'; // Default dropdown value
  TextEditingController controller = TextEditingController();
  final metroService _metroService = metroService();

  Future<void> addQRCodeToUser(BuildContext context, String docId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'qrCodes': FieldValue.arrayUnion([docId]),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code added to user')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add QR code to user: $e')),
      );
    }
  }

  Future<String> addQRWithPrice(BuildContext context, String price) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentReference docRef = await _firestore.collection('QR').add({
          'fromStation': "none",
          'price': price,
          'userId': userId,
          'in': false,
          'out': false,
          'timestamp': Timestamp.now(),
        });
        String docId = docRef.id; // Get the document ID
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document added successfully')),
        );
        return docId; // Return the document ID
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return ''; // Return an empty string if user is not found
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return ''; // Return an empty string if an error occurs
    }
  }

  Future<String> addQRWithStationsNu(
      BuildContext context, int stationsNumber) async {
    print(stationsNumber);
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        String price;
        if (stationsNumber < 10) {
          price = '6 egp';
        } else if (stationsNumber < 17) {
          price = '8 egp';
        } else if (stationsNumber < 24) {
          price = '12 egp';
        } else {
          price = '15 egp';
        }
        DocumentReference docRef = await _firestore.collection('QR').add({
          'fromStation': "none",
          'price': price,
          'userId': userId,
          'in': false,
          'out': false,
          'timestamp': Timestamp.now(),
        });
        String docId = docRef.id; // Get the document ID
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document added successfully')),
        );
        return docId; // Return the document ID
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return ''; // Return an empty string if user is not found
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return ''; // Return an empty string if an error occurs
    }
  }

  Future<String> addQRWithSrcandDst(
      BuildContext context, String from, String to) async {
    print("from " + from);
    print("to " + to);
    print("hello");
    try {
      String? userId = _auth.currentUser?.uid;
      print("before user");
      if (userId != null) {
        print("inside the user");
        String price = _metroService.calculatePrice(from, to);
        print(price);
        DocumentReference docRef = await _firestore.collection('QR').add({
          'fromStation': "none",
          'price': price,
          'userId': userId,
          'in': false,
          'out': false,
          'timestamp': Timestamp.now(),
        });
        String docId = docRef.id; // Get the document ID
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document added successfully')),
        );
        return docId; // Return the document ID
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return ''; // Return an empty string if user is not found
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return ''; // Return an empty string if an error occurs
    }
  }
}
