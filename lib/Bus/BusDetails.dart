import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/Bus/busService.dart';
import 'package:tareeqy_metro/maps/BusTracking.dart';

class BusDetails extends StatefulWidget {
  final String busNumber;
  final List<String> regions;
  final List<String> metroStations;

  const BusDetails({
    super.key,
    required this.busNumber,
    required this.regions,
    required this.metroStations,
  });

  @override
  State<BusDetails> createState() => _BusDetailsState();
}

class _BusDetailsState extends State<BusDetails> {
  late final QRservices qrServices;
  late final BusService _busService;

  @override
  void initState() {
    qrServices = QRservices();
    _busService = BusService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF073042),
        title: Text(
          'Bus Number: ${widget.busNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB31312),
                      minimumSize: const Size(150, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      "Get a Ticket",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () async {
                      String docId = await qrServices.busTicket(context);
                      if (docId.isNotEmpty) {
                        await qrServices.addBusQRCodeToUser(context, docId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRcode(
                              qrData: docId,
                              ticketType: 'Bus',
                              screen: "busDetails",
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB31312),
                      minimumSize: const Size(150, 50),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      "Track Buses",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () async {
                      bool busesAvailable = await _busService
                          .checkIfBusesAvailable(widget.busNumber);
                      if (busesAvailable) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BusTrackingScreen(widget.busNumber),
                          ),
                        );
                      } else {
                        _busService.showNoBusesAvailableDialog(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Drivers')
                          .where('busId', isEqualTo: widget.busNumber)
                          .where('work', isEqualTo: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error fetching bus data');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text(
                            'No buses available now',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB31312),
                            ),
                          );
                        } else {
                          int busCount = snapshot.data!.docs.length;
                          return Text(
                            'Available Buses Now: $busCount',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB31312),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
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
                child: Column(
                  children: [
                    const Text(
                      "Regions this bus goes through:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF073042),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: widget.regions.map((region) {
                        return Card(
                          color: const Color.fromARGB(255, 148, 194, 214),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            title: Text(
                              region,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF073042),
                              ),
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFB31312),
                              child: Icon(
                                Icons.location_on,
                                color: Color.fromARGB(255, 232, 232, 232),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              if (widget.metroStations.isNotEmpty)
                const SizedBox(
                  height: 10,
                ),
              if (widget.metroStations.isNotEmpty)
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
                  child: Column(
                    children: [
                      const Text(
                        "Nearby Metro Stations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00796B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: widget.metroStations.map((metroStation) {
                          return Card(
                            color: const Color.fromARGB(255, 78, 167, 156),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              title: Text(
                                metroStation,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF073042),
                                ),
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFB31312),
                                child: Icon(
                                  Icons.subway,
                                  color: Color.fromARGB(255, 232, 232, 232),
                                  size: 30,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
