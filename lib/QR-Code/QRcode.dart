import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tareeqy_metro/Bus/BusDetails.dart';
import 'package:tareeqy_metro/Bus/TwoBusesDetails.dart';
import 'package:tareeqy_metro/Metro/MetroScreen.dart';
import 'package:tareeqy_metro/HomePage.dart';
import 'package:vibration/vibration.dart';

class QRcode extends StatefulWidget {
  final String qrData;
  final String ticketType;
  final String screen;
  const QRcode(
      {super.key,
      required this.qrData,
      required this.ticketType,
      required this.screen});

  @override
  // ignore: library_private_types_in_public_api
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
    if (widget.ticketType == 'metro') {
      handleMetroQRData();
    } else {
      handleBusQRData();
    }
  }

//////////////////////////////////////////////////////////////////////////////
  void handleMetroQRData() {
    FirebaseFirestore.instance
        .collection('QR')
        .doc(widget.qrData)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        inStatus = snapshot.data()?['in'] ?? false;
        outStatus = snapshot.data()?['out'] ?? false;
        if (inStatus && !scanned) {
          setState(() {
            scanned = true;
          });
          Vibration.vibrate(duration: 200);
        }

        if (outStatus && !scanned) {
          setState(() {
            scanned = true;
          });
          Vibration.vibrate(duration: 200);
        }

        if (outStatus && inStatus) {
          setState(() {
            Vibration.vibrate(duration: 200);
            ticketNotUsable = true;
          });
        }
      }
    });
  }

  ///////////////////////////////////////////////////////////////////////////////
  void handleBusQRData() {
    bool scannedStatus = false;
    FirebaseFirestore.instance
        .collection('BusQRcodes')
        .doc(widget.qrData)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        scannedStatus = snapshot.data()?['scanned'] ?? false;
        if (scannedStatus) {
          setState(() {
            ticketNotUsable = true;
          });
          Vibration.vibrate(duration: 200);
        }
      }
    });
  }

  @override
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
              } else if (widget.screen == "busDetails") {
                Navigator.of(context).popUntil((route) {
                  return route.settings.name == null &&
                      route is MaterialPageRoute &&
                      route.builder(context) is BusDetails;
                });
              } else if (widget.screen == "twoBusDetails") {
                Navigator.of(context).popUntil((route) {
                  return route.settings.name == null &&
                      route is MaterialPageRoute &&
                      route.builder(context) is TwoBusesDetails;
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
            icon: const Icon(Icons.arrow_back)),
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
                            SizedBox(height: 20),
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
