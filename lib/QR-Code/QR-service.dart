import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';
import 'package:tareeqy_metro/Payment/Screens/ChargeWallet_Screen.dart';

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

  Future<void> addBusQRCodeToUser(BuildContext context, String docId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'busTickets': FieldValue.arrayUnion([docId]),
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
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        double walletBalance =
            double.parse(userData['wallet'] ?? '0');

        bool continueOperation = await showWalletConfirmationDialog(context, walletBalance);
        if (!continueOperation) return '';

        double ticketPrice = double.parse(price.replaceAll(' egp', ''));
        if (walletBalance >= ticketPrice) {
          DocumentReference docRef = await _firestore.collection('QR').add({
            'fromStation': "none",
            'price': price,
            'userId': userId,
            'in': false,
            'out': false,
            'timestamp': Timestamp.now(),
          });
          String docId = docRef.id;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document added successfully')),
          );
          return docId;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChargeWalletScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient funds. Please charge your wallet.'),
            ),
          );
          return '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }

  Future<String> addQRWithStationsNu(BuildContext context, int stationsNumber) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        double walletBalance =
            double.parse(userData['wallet'] ?? '0');

        bool continueOperation = await showWalletConfirmationDialog(context, walletBalance);
        if (!continueOperation) return '';

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

        double ticketPrice = double.parse(price.replaceAll(' egp', ''));
        if (walletBalance >= ticketPrice) {
          DocumentReference docRef = await _firestore.collection('QR').add({
            'fromStation': "none",
            'price': price,
            'userId': userId,
            'in': false,
            'out': false,
            'timestamp': Timestamp.now(),
          });
          String docId = docRef.id;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document added successfully')),
          );
          return docId;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChargeWalletScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient funds. Please charge your wallet.'),
            ),
          );
          return '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }

  Future<String> addQRWithSrcandDst(BuildContext context, String from, String to) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        double walletBalance =
            double.parse(userData['wallet'] ?? '0');

        bool continueOperation = await showWalletConfirmationDialog(context, walletBalance);
        if (!continueOperation) return '';

        String price = _metroService.calculatePrice(from, to);

        double ticketPrice = double.parse(price.replaceAll(' egp', ''));
        if (walletBalance >= ticketPrice) {
          DocumentReference docRef = await _firestore.collection('QR').add({
            'fromStation': "none",
            'price': price,
            'userId': userId,
            'in': false,
            'out': false,
            'timestamp': Timestamp.now(),
          });
          String docId = docRef.id;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document added successfully')),
          );
          return docId;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChargeWalletScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient funds. Please charge your wallet.'),
            ),
          );
          return '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }

  Future<String> busTicket(BuildContext context, String busNumber) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
        double walletBalance =
            double.parse(userData['wallet'] ?? '0');

        bool continueOperation = await showWalletConfirmationDialog(context, walletBalance);
        if (!continueOperation) return '';

        double ticketPrice = 10.0; // Price of bus ticket
        if (walletBalance >= ticketPrice) {
          DocumentReference docRef =
              await _firestore.collection('BusQRcodes').add({
            'fromStation': "none",
            'price': '10 egp',
            'userId': userId,
            'in': false,
            'out': false,
            'timestamp': Timestamp.now(),
            'Bus_Number': busNumber
          });
          String docId = docRef.id;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document added successfully')),
          );
          return docId;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChargeWalletScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient funds. Please charge your wallet.'),
            ),
          );
          return '';
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }




Future<bool> showWalletConfirmationDialog(BuildContext context, double walletBalance) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            SizedBox(width: 10),
            Text(
              'Insufficient Funds',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your current wallet balance is $walletBalance EGP.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'You do not have enough funds in your wallet to make this purchase.',
            ),
            SizedBox(height: 10),
            Text(
              'Would you like to charge your wallet?',
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Do not continue operation
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Continue operation
            },
            child: Text('Yes, Charge Wallet'),
          ),
        ],
      );
    },
  );

  return result ?? false; // Return false if result is null
}


  }



