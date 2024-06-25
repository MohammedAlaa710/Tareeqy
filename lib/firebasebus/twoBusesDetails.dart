import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/firebasebus/busService.dart';
import 'package:tareeqy_metro/firebasebus/busTracking.dart';

class TwoBusesDetails extends StatefulWidget {
  final List<String> busNumbers;
  final List<String> regions1;
  final List<String> regions2;
  final List<String> commonRegions;
  final List<String> metroStations1;
  final List<String> metroStations2;
  const TwoBusesDetails({
    super.key,
    required this.busNumbers,
    required this.regions1,
    required this.regions2,
    required this.commonRegions,
    required this.metroStations1,
    required this.metroStations2,
  });

  @override
  State<TwoBusesDetails> createState() => _TwoBusesDetailsState();
}

class _TwoBusesDetailsState extends State<TwoBusesDetails> {
  late final QRservices qrServices;
  late final BusService _busService;
  late bool isSwitched = false;
  @override
  void initState() {
    isSwitched = false;
    qrServices = QRservices();
    _busService = BusService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF073042), // Dark Blue
        title: Text(
          'Buses Number:     ${widget.busNumbers[0]} , ${widget.busNumbers[1]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
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
              //for (int i = 0; i < 2; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF073042),
                          minimumSize: const Size(150, 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "Track Buses ${widget.busNumbers[0]}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () async {
                          bool busesAvailable = await _busService
                              .checkIfBusesAvailable(widget.busNumbers[0]);
                          if (busesAvailable) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusTrackingScreen(widget.busNumbers[0]),
                              ),
                            );
                          } else {
                            _busService.showNoBusesAvailableDialog(context);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Drivers')
                              .where('busId', isEqualTo: widget.busNumbers[0])
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
                  const SizedBox(width: 5),
                  ////////////////////////////
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF073042),
                          minimumSize: const Size(150, 50),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          "Track Buses ${widget.busNumbers[1]}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                        onPressed: () async {
                          bool busesAvailable = await _busService
                              .checkIfBusesAvailable(widget.busNumbers[1]);
                          if (busesAvailable) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BusTrackingScreen(widget.busNumbers[1]),
                              ),
                            );
                          } else {
                            _busService.showNoBusesAvailableDialog(context);
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Drivers')
                              .where('busId', isEqualTo: widget.busNumbers[1])
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
                ],
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF073042),
                  minimumSize: const Size(150, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          screen: "bus",
                        ),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSwitched
                      ? const Color(0xFFB31312)
                      : const Color(0xFF00796B),
                  minimumSize: const Size(150, 50),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isSwitched = !isSwitched;
                  });
                },
                child: isSwitched
                    ? const Text(
                        'Show Bus Regions',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )
                    : const Text(
                        'Show Metro Stations',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
              ),
              const SizedBox(height: 20),
              if (!isSwitched)
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
                      //for (int i = 0; i < 2; i++)
                      Column(
                        children: [
                          Text(
                            "Regions bus ${widget.busNumbers[0]} goes through:",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF073042),
                            ),
                          ),
                          Column(
                            children: widget.regions1.map((region) {
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
                          ////////////////////////////////////////////////////////////////////////////
                          const SizedBox(height: 13),
                          const Text(
                            "you can change buses in the following regions ",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF073042),
                            ),
                          ),
                          Column(
                            children: widget.commonRegions.map((region) {
                              return Card(
                                color: const Color.fromARGB(255, 179, 67, 67),
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
                                      color: Colors.white, // Dark Blue
                                    ),
                                  ),
                                  leading: const CircleAvatar(
                                    backgroundColor: Color(0xFF073042), // Red
                                    child: Icon(
                                      Icons.compare_arrows_outlined,
                                      color: Color.fromARGB(255, 232, 232, 232),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          ////////////////////////////////////////////////////////////////////////////
                          const SizedBox(height: 13),
                          Text(
                            "Regions bus ${widget.busNumbers[1]} goes through:",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF073042),
                            ),
                          ),
                          Column(
                            children: widget.regions2.map((region) {
                              return Card(
                                color: const Color.fromARGB(255, 45, 184, 168),
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
                      ///////////////////////////////////////////////////////////////////////
                    ],
                  ),
                ),

              if (isSwitched)
                if (widget.metroStations1.isNotEmpty)
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
                        Text(
                          "${widget.busNumbers[0]} : Nearby Metro Stations",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF073042),
                          ),
                        ),
                        Column(
                          children: widget.metroStations1.map((metroStation) {
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
                        ////////////////////////////////////////////////////////////////////////////
                        if (widget.metroStations2.isNotEmpty)
                          const SizedBox(
                            height: 15,
                          ),
                        if (widget.metroStations2.isNotEmpty)
                          Column(
                            children: [
                              Text(
                                "${widget.busNumbers[1]} : Nearby Metro Stations",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF073042),
                                ),
                              ),
                              Column(
                                children:
                                    widget.metroStations2.map((metroStation) {
                                  return Card(
                                    color:
                                        const Color.fromARGB(255, 78, 167, 156),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                        backgroundColor:
                                            Color(0xFFB31312), // Red
                                        child: Icon(
                                          Icons.subway,
                                          color: Color.fromARGB(
                                              255, 232, 232, 232),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          )
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
