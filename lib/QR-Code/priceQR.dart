//past code ==============================================================================================//
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class priceQR extends StatefulWidget {
  const priceQR({super.key});

  @override
  State<priceQR> createState() => _priceQRState();
}

class _priceQRState extends State<priceQR> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String dropdownValue = '15 egp'; // Default dropdown value
  TextEditingController controller = TextEditingController();

  /*Future<void> addQRDocument(String price) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('QR').add({
          'fromStation': "none",
          'price': price,
          'userId': userId,
          'in': false,
          'out': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
    }
  }*/
  Future<String> addQRDocument(String price) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentReference docRef = await _firestore.collection('QR').add({
          'fromStation': "none",
          'price': price,
          'userId': userId,
          'in': false,
          'out': false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("price page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: dropdownValue,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                }
              },
              items: <String>['6 egp', '12 egp', '15 egp']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(
                height: 20), // Add some space between the dropdown and button
            ElevatedButton(
              onPressed: () async {
                int price;
                if (dropdownValue == '6 egp') {
                  price = 6;
                } else if (dropdownValue == '12 egp') {
                  price = 12;
                } else {
                  price = 15;
                }
                String docId = await addQRDocument('$price egp');
                if (docId.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRcode(qrData: docId),
                    ),
                  );
                }
              },
              child: Text('Add Document'),
            ),
          ],
        ),
      ),
    );
  }
}
