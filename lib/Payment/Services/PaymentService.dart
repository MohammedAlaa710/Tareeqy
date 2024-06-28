import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/homepage.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addAmountToUserWallet(
      BuildContext context, String amount) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      DocumentReference walletRef =
          _firestore.collection('users').doc(user.uid);

      DocumentSnapshot walletSnapshot = await walletRef.get();
      double currentAmount = 0.0;

      if (walletSnapshot.exists && walletSnapshot.data() != null) {
        Map<String, dynamic> walletData =
            walletSnapshot.data() as Map<String, dynamic>;
        if (walletData.containsKey('wallet')) {
          currentAmount =
              double.tryParse(walletData['wallet'].toString()) ?? 0.0;
        }
      }

      double amountToAdd = double.tryParse(amount) ?? 0.0;
      double newTotalAmount = currentAmount + amountToAdd;

      await walletRef.update({'wallet': newTotalAmount.toString()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wallet Charged Successfully!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to Charge Wallet: ${e.toString()}")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }
}
