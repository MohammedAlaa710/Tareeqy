import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:tareeqy_metro/Payment/Screens/ChargeWallet_Screen.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:intl/intl.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _username;
  dynamic _wallet;
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));
    setState(() {
      _tickets.clear();
      _isLoading = true;
      _fetchUserData();
    });
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((userDoc) async {
        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _username = userDoc.data()!['userName'];
              _wallet = userDoc.data()!['wallet'];
            });
          }
          final metroTicketIds = List<String>.from(userDoc.data()!['qrCodes']);
          final busTicketIds = List<String>.from(userDoc.data()!['busTickets']);
          await _fetchMetroTickets(metroTicketIds);
          await _fetchBusTickets(busTicketIds);
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _fetchMetroTickets(List<String> ticketIds) async {
    List<Map<String, dynamic>> tickets = [];
    final List<Future<DocumentSnapshot>> futures = [];

    for (String ticketId in ticketIds) {
      futures.add(_firestore.collection('QR').doc(ticketId).get());
    }

    final List<DocumentSnapshot> snapshots = await Future.wait(futures);

    for (DocumentSnapshot snapshot in snapshots) {
      if (snapshot.exists) {
        Map<String, dynamic> ticketData =
            snapshot.data() as Map<String, dynamic>;
        ticketData['id'] = snapshot.id;
        ticketData['type'] = 'metro';
        if (!ticketData['out']) {
          tickets.add(ticketData);
        }
      }
    }

    _processAndSetTickets(tickets);
  }

  Future<void> _fetchBusTickets(List<String> ticketIds) async {
    List<Map<String, dynamic>> tickets = [];
    final List<Future<DocumentSnapshot>> futures = [];

    for (String ticketId in ticketIds) {
      futures.add(_firestore.collection('BusQRcodes').doc(ticketId).get());
    }
    final List<DocumentSnapshot> snapshots = await Future.wait(futures);
    for (DocumentSnapshot snapshot in snapshots) {
      if (snapshot.exists) {
        Map<String, dynamic> ticketData =
            snapshot.data() as Map<String, dynamic>;
        ticketData['id'] = snapshot.id;
        ticketData['type'] = 'bus';
        if (!ticketData['scanned']) {
          tickets.add(ticketData);
        }
      }
    }
    _processAndSetTickets(tickets);
  }

  void _processAndSetTickets(List<Map<String, dynamic>> tickets) {
    List<Map<String, dynamic>>? ticketsInUse;
    List<Map<String, dynamic>>? otherTickets;
    List<Map<String, dynamic>> metroTickets =
        tickets.where((ticket) => ticket['type'] == 'metro').toList();
    if (metroTickets.isEmpty) {
      otherTickets = tickets.where((ticket) => !ticket['scanned']).toList();
    }
    if (metroTickets.isNotEmpty) {
      ticketsInUse = tickets.where((ticket) => ticket['in']).toList();
      otherTickets = tickets.where((ticket) => !ticket['in']).toList();
    }

    ticketsInUse?.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    otherTickets?.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    if (mounted) {
      setState(() {
        _tickets = [..._tickets, ...?ticketsInUse, ...?otherTickets];
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd At hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            if (_username != null && _wallet != null) _buildUserInfo(),
            const SizedBox(height: 20),
            _buildTicketsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF073042),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _username!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet,
                  color: Color.fromARGB(255, 35, 184, 40)),
              const SizedBox(width: 5),
              Text(
                'L.E  $_wallet',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(width: 35),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 178, 20, 20),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChargeWalletScreen(),
                    ),
                  );
                },
                child: const Text('Charge Wallet'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketsSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tickets:',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF073042),
            ),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB31312)))
              : _tickets.isEmpty
                  ? const Center(
                      child: Text(
                        'No tickets purchased',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 17, 0)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QRcode(
                                  qrData: ticket['id'],
                                  ticketType: ticket['type'],
                                  screen: "profile",
                                ),
                              ),
                            );
                          },
                          child: (ticket['type'] == "metro")
                              ? Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: ticket['in']
                                      ? const Color.fromARGB(255, 95, 255, 15)
                                      : Colors.white,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 5),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    leading: Icon(
                                      ticket['type'] == 'metro'
                                          ? Icons.train
                                          : Icons.directions_bus,
                                      color: ticket['type'] == 'metro'
                                          ? const Color(0xFF00796B)
                                          : const Color(0xFFB31312),
                                      size: 40,
                                    ),
                                    title: Text(
                                      ticket['type'] == 'metro'
                                          ? 'Metro Ticket'
                                          : 'Bus Ticket',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                            0xff4A4A4D,
                                          )),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time: ${_formatTimestamp(ticket['timestamp'])}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Price: \$${ticket['price']}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        if (ticket['in'])
                                          const Text(
                                            'This ticket is in use',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 254, 17, 0),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color:
                                            Color.fromARGB(255, 121, 121, 121)),
                                  ),
                                )
                              : Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  color: Colors.white,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 5),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(10.0),
                                    leading: Icon(
                                      ticket['type'] == 'metro'
                                          ? Icons.train
                                          : Icons.directions_bus,
                                      color: ticket['type'] == 'metro'
                                          ? const Color(0xFF00796B)
                                          : const Color(0xFFB31312),
                                      size: 40,
                                    ),
                                    title: Text(
                                      ticket['type'] == 'metro'
                                          ? 'Metro Ticket'
                                          : 'Bus Ticket',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(
                                            0xff4A4A4D,
                                          )),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Time: ${_formatTimestamp(ticket['timestamp'])}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0)),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Price: \$${ticket['price']}',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color:
                                            Color.fromARGB(255, 121, 121, 121)),
                                  ),
                                ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
