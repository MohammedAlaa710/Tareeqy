import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/Metro/metroService.dart';
import 'package:tareeqy_metro/Payment/Screens/ChargeWallet_Screen.dart';

class QRservices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String dropdownValue = '15 egp';
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
          const SnackBar(
              content:
                  Text('The Ticket is added to your Profile Successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error in retrieving ticket')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('The Ticket FAILED to be added to your Profile.')),
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
          const SnackBar(
              content:
                  Text('The Ticket is added to your Profile Successfully.')),
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
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        double walletBalance = double.parse(userData['wallet'] ?? '0');
        double ticketPrice = double.parse(price.replaceAll(' egp', ''));

        if (walletBalance >= ticketPrice) {
          bool continueOperation = await showPurchaseConfirmationDialog(
              context, walletBalance, ticketPrice);
          if (continueOperation) {
            return await _performPurchase(
                context, userId, ticketPrice, walletBalance, "QR");
          } else {
            return '';
          }
        } else {
          await showWalletConfirmationDialog(
              context, walletBalance, ticketPrice);
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

  Future<String> addQRWithStationsNu(
      BuildContext context, int stationsNumber) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        double walletBalance = double.parse(userData['wallet'] ?? '0');

        String price = _calculatePriceForStations(stationsNumber);

        double ticketPrice = double.parse(price.replaceAll(' egp', ''));
        if (walletBalance >= ticketPrice) {
          bool continueOperation = await showPurchaseConfirmationDialog(
              context, walletBalance, ticketPrice);
          if (continueOperation) {
            return await _performPurchase(
                context, userId, ticketPrice, walletBalance, "QR");
          } else {
            return '';
          }
        } else {
          await showWalletConfirmationDialog(
              context, walletBalance, ticketPrice);
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

  Future<String> addQRWithSrcandDst(
      BuildContext context, String from, String to) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        double walletBalance = double.parse(userData['wallet'] ?? '0');
        String price = _metroService.calculatePrice(from, to);

        double ticketPrice = double.parse(price.replaceAll(' egp', ''));
        if (walletBalance >= ticketPrice) {
          bool continueOperation = await showPurchaseConfirmationDialog(
              context, walletBalance, ticketPrice);
          if (continueOperation) {
            return await _performPurchase(
                context, userId, ticketPrice, walletBalance, "QR");
          } else {
            return '';
          }
        } else {
          await showWalletConfirmationDialog(
              context, walletBalance, ticketPrice);
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

  Future<String> busTicket(BuildContext context) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(userId).get();
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        double walletBalance = double.parse(userData['wallet'] ?? '0');

        double ticketPrice = 10.0;
        if (walletBalance >= ticketPrice) {
          bool continueOperation = await showPurchaseConfirmationDialog(
              context, walletBalance, ticketPrice);
          if (continueOperation) {
            return await _busTicketPurchase(
                context, userId, ticketPrice, walletBalance, "BusQRcodes");
          } else {
            return '';
          }
        } else {
          await showWalletConfirmationDialog(
              context, walletBalance, ticketPrice);
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

  Future<bool> showWalletConfirmationDialog(
      BuildContext context, double walletBalance, double ticketPrice) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
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
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'You do not have enough funds in your wallet to make this purchase.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Would you like to charge your wallet?',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); 
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChargeWalletScreen()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Insufficient funds. Please charge your wallet.'),
                  ),
                );
                '';
              },
              child: const Text('Yes, Charge Wallet'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<bool> showPurchaseConfirmationDialog(
      BuildContext context, double walletBalance, double ticketPrice) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Purchase',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your current wallet balance is',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                '$walletBalance EGP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'The ticket price is',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                '$ticketPrice EGP',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Do you want to proceed with the purchase?',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); 
              },
              child: const Text(
                'Yes, Purchase Ticket',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<String> _performPurchase(BuildContext context, String userId,
      double ticketPrice, double walletBalance, String metroOrbus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'wallet': (walletBalance - ticketPrice).toString(),
      });

      DocumentReference docRef = await _firestore.collection(metroOrbus).add({
        'fromStation': "none",
        'price': '$ticketPrice egp',
        'userId': userId,
        'in': false,
        'out': false,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ticket purchased successfully. \nYour wallet balance is now ${(walletBalance - ticketPrice).toStringAsFixed(2)} EGP.'),
        ),
      );

      String docId = docRef.id;
      return docId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<String> _busTicketPurchase(BuildContext context, String userId,
      double ticketPrice, double walletBalance, String metroOrbus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'wallet': (walletBalance - ticketPrice).toString(),
      });

      // Add the QR to the collection
      DocumentReference docRef = await _firestore.collection(metroOrbus).add({
        'fromStation': "none",
        'price': '$ticketPrice egp',
        'userId': userId,
        'scanned': false,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ticket purchased successfully. \nYour wallet balance is now ${(walletBalance - ticketPrice).toStringAsFixed(2)} EGP.'),
        ),
      );

      String docId = docRef.id;
      return docId;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add document: $e')),
      );
      return '';
    }
  }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  String _calculatePriceForStations(int stationsNumber) {
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
    return price;
  }
}
