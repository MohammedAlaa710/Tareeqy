import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';

class myProfile_Screen extends StatefulWidget {
  const myProfile_Screen({Key? key}) : super(key: key);

  @override
  State<myProfile_Screen> createState() => _myProfile_ScreenState();
}

class _myProfile_ScreenState extends State<myProfile_Screen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  dynamic _wallet;
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    _fetchUserData();
    super.initState();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc.data()!['userName'];
          _wallet = userDoc.data()!['wallet'];
        });
        final ticketIds = List<String>.from(userDoc.data()!['qrCodes']);
        _fetchTickets(ticketIds);
      }
    }
  }

  Future<void> _fetchTickets(List<String> ticketIds) async {
    List<Map<String, dynamic>> tickets = [];
    for (String ticketId in ticketIds) {
      final ticketDoc = await _firestore.collection('QR').doc(ticketId).get();
      if (ticketDoc.exists) {
        Map<String, dynamic> ticketData = ticketDoc.data()!;
        ticketData['id'] =
            ticketId; // Include the document ID in the ticket data
        if (!ticketData['out']) {
          tickets.add(ticketData);
        }
      }
    }
    // Separate tickets in use and sort them
    List<Map<String, dynamic>> ticketsInUse =
        tickets.where((ticket) => ticket['in']).toList();
    List<Map<String, dynamic>> otherTickets =
        tickets.where((ticket) => !ticket['in']).toList();
    ticketsInUse.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    otherTickets.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    setState(() {
      _tickets = [...ticketsInUse, ...otherTickets];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          if (_username != null && _wallet != null)
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    _username!,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '\$$_wallet',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _tickets.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = _tickets[index];
                      return Card(
                        color: ticket['in']
                            ? const Color.fromARGB(255, 143, 255, 15)
                            : null,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: ListTile(
                          title: Text('Time: ${ticket['timestamp']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Price: \$${ticket['price']}'),
                              if (ticket['in'])
                                const Text('This ticket is in use',
                                    style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QRcode(qrData: ticket['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
