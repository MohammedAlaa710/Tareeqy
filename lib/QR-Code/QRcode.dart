import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tareeqy_metro/firebasebus/BusDetails.dart';
import 'package:tareeqy_metro/firebasemetro/metroscreen.dart';
import 'package:tareeqy_metro/homepage.dart';
import 'package:vibration/vibration.dart';

class QRcode extends StatefulWidget {
  final String qrData;
  final String ticketType;
  final String screen;
  const QRcode(
      {Key? key,
      required this.qrData,
      required this.ticketType,
      required this.screen})
      : super(key: key);

  @override
  _QRcodeState createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcode> {
  bool scanned = false;
  bool showMessage = false;
  bool ticketNotUsable = false;
  bool inStatus = false;
  bool outStatus = false;
  @override
  void initState() {
    super.initState();
    // Listen for changes in Firestore
    if (widget.ticketType == 'metro') {
      print("inside if");
      handleMetroQRData();
    } else {
      print("inside else");

      handleBusQRData();
    }
  }

//////////////////////////////////////////////////////////////////////////////
  void handleMetroQRData() {
    /*FirebaseFirestore.instance
        .collection('QR') // Replace with your collection name
        .doc(widget.qrData) // Assuming qrData is the document ID
        .snapshots()
        .firstWhere((snapshot) =>
            snapshot.exists) // Ensure we only handle existing snapshots
        .then((snapshot) {
      inStatus = snapshot.data()?['in'] ?? false;
      outStatus = snapshot.data()?['out'] ?? false;
      if (inStatus) {
        setState(() {
          scanned = true;
          //showMessage = false;
        });
      }
    });*/
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
            //showMessage = true; // Show message
          });
          // Trigger vibration
          Vibration.vibrate(duration: 200);

          // Show dialog
          //_showScannedDialog();
        }

        // Handle outStatus similarly
        if (outStatus && !scanned) {
          setState(() {
            scanned = true;
            //showMessage = true; // Show message
          });
          // Trigger vibration
          Vibration.vibrate(duration: 200);

          // Show dialog
          //_showScannedDialog();
        }

        // If both inStatus and outStatus are true and scanned is true
        if (outStatus && inStatus) {
          setState(() {
            Vibration.vibrate(duration: 200);
            ticketNotUsable = true; // Show ticket not usable message
          });
        }
      }
    });
  }

  ///////////////////////////////////////////////////////////////////////////////
  void handleBusQRData() {
    bool scannedStatus = false;
    FirebaseFirestore.instance
        .collection('BusQRcodes') // Replace with your collection name
        .doc(widget.qrData) // Assuming qrData is the document ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        scannedStatus = snapshot.data()?['scanned'] ?? false;
        // Check if QR code has been scanned
        if (scannedStatus) {
          setState(() {
            //showMessage = true; // Show message
            ticketNotUsable = true;
          });
          // Trigger vibration
          Vibration.vibrate(duration: 200);

          // Show dialog
          //_showScannedDialog();
        }
      }
    });
  }

////////////////////////////////////////////////////////////////////////////////////////
  void _showScannedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF073042),
          title: const Text('Scanned', style: TextStyle(color: Colors.white)),
          content: const Text('QR code has been scanned!',
              style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFF00796B)),
              child: Text('OK', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  scanned = false;
                  showMessage = false; // Hide message
                });
                if (widget.screen == "metro") {
                  Navigator.of(context).popUntil((route) {
                    return route.settings.name == null &&
                        route is MaterialPageRoute &&
                        route.builder(context) is MetroScreen;
                  });
                } else if (widget.screen == "bus") {
                  Navigator.of(context).popUntil((route) {
                    return route.settings.name == null &&
                        route is MaterialPageRoute &&
                        route.builder(context) is BusDetails;
                  });
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                }
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
        leading: IconButton(
            onPressed: () {
              if (widget.screen == "metro") {
                Navigator.of(context).popUntil((route) {
                  return route.settings.name == null &&
                      route is MaterialPageRoute &&
                      route.builder(context) is MetroScreen;
                });
              } else if (widget.screen == "bus") {
                Navigator.of(context).popUntil((route) {
                  return route.settings.name == null &&
                      route is MaterialPageRoute &&
                      route.builder(context) is BusDetails;
                });
              } else if (widget.screen == "profile" &&
                  (inStatus || outStatus)) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.arrow_back)),
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
                  const Text(
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
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                color: Color(0xFFB31312), size: 80),
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
                  const Text(
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
                  if (widget.ticketType == "metro" && inStatus)
                    const SizedBox(height: 40),
                  if (widget.ticketType == "metro" && inStatus)
                    const Text(
                      "Ticket is Scanned Once",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
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
