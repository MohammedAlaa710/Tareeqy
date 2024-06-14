// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/firebasebus/busSeats.dart';
import 'package:tareeqy_metro/firebasebus/busTracking.dart';

class BusDetails extends StatelessWidget {
  final String busNumber;
  final List<String> regions;

  const BusDetails({
    Key? key,
    required this.busNumber,
    required this.regions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final QRservices qrServices = QRservices();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1D3557), // Dark Blue
        title: Text(
          busNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: const Color(0xFFE63946), // Red
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Text(
                    "Get a Ticket",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: () async {
                    String docId =
                        await qrServices.busTicket(context, busNumber);
                    if (docId.isNotEmpty) {
                      await qrServices.addBusQRCodeToUser(context, docId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRcode(qrData: docId),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: const Color(0xFFE63946), // Red
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Text(
                    "Available seats",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusSeats(busNumber),
                      ),
                    );
                  },
                ),
                SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor: const Color(0xFFE63946), // Red
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: const Text(
                    "Track buses",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusTrackingScreen(busNumber),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF1FAEE),
              Color(0xFFA8DADC),
            ], // Light gradient background
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemCount: regions.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    regions[index],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D3557), // Dark Blue
                    ),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE63946), // Red
                    child: Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}