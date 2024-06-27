import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/Bus/busService.dart';
import 'package:tareeqy_metro/maps/BusTracking.dart';

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
        backgroundColor: const Color(0xFF073042),
        title: Text(
          'Buses Number: ${widget.busNumbers[0]} , ${widget.busNumbers[1]}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTrackButton(widget.busNumbers[0]),
                  _buildTrackButton(widget.busNumbers[1]),
                ],
              ),
              const SizedBox(height: 15),
              _buildGetTicketButton(),
              const SizedBox(height: 15),
              _buildSwitchButton(),
              const SizedBox(height: 20),
              if (!isSwitched) ...[
                _buildRegionsList(widget.busNumbers[0], widget.regions1),
                _buildChangeBusRegions(),
                _buildRegionsList(widget.busNumbers[1], widget.regions2,
                    isSecondBus: true),
              ],
              if (isSwitched) ...[
                if (widget.metroStations1.isNotEmpty)
                  _buildMetroStationsList(
                      widget.busNumbers[0], widget.metroStations1),
                if (widget.metroStations2.isNotEmpty)
                  _buildMetroStationsList(
                      widget.busNumbers[1], widget.metroStations2),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackButton(String busNumber) {
    return Flexible(
      child: Column(
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF073042),
              minimumSize: const Size(150, 50),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "Track $busNumber",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () async {
              bool busesAvailable =
                  await _busService.checkIfBusesAvailable(busNumber);
              if (busesAvailable) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusTrackingScreen(busNumber),
                  ),
                );
              } else {
                _busService.showNoBusesAvailableDialog(context);
              }
            },
          ),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Drivers')
                .where('busId', isEqualTo: busNumber)
                .where('work', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error fetching bus data');
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
        ],
      ),
    );
  }

  Widget _buildGetTicketButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF073042),
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                screen: "twoBusDetails",
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSwitchButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSwitched ? const Color(0xFFB31312) : const Color(0xFF00796B),
        minimumSize: const Size(150, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: () {
        setState(() {
          isSwitched = !isSwitched;
        });
      },
      child: Text(
        isSwitched ? 'Show Bus Regions' : 'Show Metro Stations',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  Widget _buildRegionsList(String busNumber, List<String> regions,
      {bool isSecondBus = false}) {
    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Regions bus $busNumber goes through:",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073042),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: regions.map((region) {
              return Card(
                color: isSecondBus
                    ? const Color.fromARGB(255, 109, 184, 176)
                    : const Color.fromARGB(255, 148, 194, 214),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    region,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          isSecondBus ? Colors.black : const Color(0xFF073042),
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSecondBus
                        ? const Color(0xFF073042)
                        : const Color(0xFF073042),
                    child: Icon(
                      isSecondBus ? Icons.location_on : Icons.location_on,
                      color: isSecondBus ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeBusRegions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 13),
        const Text(
          "Change buses in these regions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF073042),
          ),
        ),
        const SizedBox(height: 10),
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(
                  region,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF073042),
                  child: Icon(
                    Icons.compare_arrows_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 13),
      ],
    );
  }

  Widget _buildMetroStationsList(String busNumber, List<String> metroStations) {
    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "$busNumber : Metro Stations",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073042),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: metroStations.asMap().entries.map((entry) {
              String metroStation = entry.value;
              Color cardColor = busNumber == widget.busNumbers[0]
                  ? const Color.fromARGB(255, 148, 194, 214)
                  : const Color.fromARGB(255, 109, 184, 176);
              Color textColor = busNumber == widget.busNumbers[0]
                  ? const Color(0xFF073042)
                  : Colors.black;
              return Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 5,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  title: Text(
                    metroStation,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF073042),
                    child: Icon(
                      Icons.directions_subway_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
