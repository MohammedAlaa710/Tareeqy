import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/firebasebus/busTracking.dart';

class BusDetails extends StatelessWidget {
  final String busNumber;
  final List<String> regions;
  final List<String> metroStations;

  const BusDetails({
    Key? key,
    required this.busNumber,
    required this.regions,
    required this.metroStations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final QRservices qrServices = QRservices();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF073042), // Dark Blue
        title: Text(
          'Bus Number: $busNumber',
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
                      String docId =
                          await qrServices.busTicket(context, busNumber);
                      if (docId.isNotEmpty) {
                        await qrServices.addBusQRCodeToUser(context, docId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRcode(
                              qrData: docId,
                              ticketType: 'Bus',
                              screen: "bus",
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
                      children: regions.map((region) {
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
                                color: Color(0xFF073042), // Dark Blue
                              ),
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFB31312), // Red
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
              if (metroStations.isNotEmpty)
                const SizedBox(
                  height: 10,
                ),
              if (metroStations.isNotEmpty)
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
                        children: metroStations.map((metroStation) {
                          return Card(
                            color: Color.fromARGB(255, 78, 167, 156),
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
                                  color: Color(0xFF073042), // Dark Blue
                                ),
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFB31312), // Red
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
