import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vibration/vibration.dart';

class QRcode extends StatefulWidget {
  final String qrData;
  final String ticketType;

  const QRcode({Key? key, required this.qrData, required this.ticketType})
      : super(key: key);

  @override
  _QRcodeState createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcode> {
  bool scanned = false; // Track if QR code has been scanned
  bool showMessage = false; // Track if message is currently active
  bool ticketNotUsable = false; // Track if ticket is no longer usable

  @override
  void initState() {
    super.initState();
    // Listen for changes in Firestore
    bool inStatus = false;
    bool outStatus = false;
       FirebaseFirestore.instance
        .collection('QR') // Replace with your collection name
        .doc(widget.qrData) // Assuming qrData is the document ID
        .snapshots().firstWhere((snapshot) => snapshot.exists) // Ensure we only handle existing snapshots
      .then((snapshot) {
         inStatus = snapshot.data()?['in'] ?? false;
         outStatus = snapshot.data()?['out'] ?? false;
if (inStatus) {
          setState(() {
            scanned = true;
            showMessage = false;
        
});}});
    FirebaseFirestore.instance
        .collection('QR') // Replace with your collection name
        .doc(widget.qrData) // Assuming qrData is the document ID
        .snapshots()
        .listen((snapshot) {
      // Check if 'in' or 'out' fields have changed
      if (snapshot.exists) {

         inStatus = snapshot.data()?['in'] ?? false;
         outStatus = snapshot.data()?['out'] ?? false;
        // Check if QR code has been scanned
        if (inStatus && !scanned) {
          setState(() {
            scanned = true;
            showMessage = true; // Show message
          });
          // Trigger vibration
          Vibration.vibrate(duration: 200);

          // Show dialog
          _showScannedDialog();
        }

        // Handle outStatus similarly
        if (outStatus && !scanned) {
          setState(() {
            scanned = true;
            showMessage = true; // Show message
          });
          // Trigger vibration
          Vibration.vibrate(duration: 200);

          // Show dialog
          _showScannedDialog();
        }

        // If both inStatus and outStatus are true and scanned is true
        if (outStatus && inStatus) {
          setState(() {
            ticketNotUsable = true; // Show ticket not usable message
          });
        }
      }
    });
  }

  void _showScannedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF073042),
          title: Text('Scanned', style: TextStyle(color: Colors.white)),
          content: Text('QR code has been scanned!', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFF00796B)),
              child: Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  scanned = false;
                  showMessage = false; // Hide message
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: Navigator.of(context).pop, icon: Icon(Icons.arrow_back)),
        backgroundColor: const Color(0xFF073042),
        title: Text(
          widget.ticketType == 'metro' ? 'Metro Ticket' : 'Bus Ticket',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ticketNotUsable
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ticket is no longer in your profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB31312),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Color(0xFFB31312), size: 80),
                            const SizedBox(height: 20),
                            Text(
                              'Ticket is no longer usable',
                              style: TextStyle(
                                color: Color(0xFFB31312),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ticket is stored in your profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Scan this QR code for your ${widget.ticketType} ticket',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF073042),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: QrImageView(
                      data: widget.qrData,
                      version: QrVersions.auto,
                      size: 280,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
