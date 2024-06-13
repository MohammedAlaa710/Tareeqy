import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tareeqy_metro/Payment/Screens/ChargeWallet_Screen.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/homepage.dart';

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
  bool _isLoading = true;

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
      }
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
        if (!ticketData['out']) {
          tickets.add(ticketData);
        }
      }
    }

    _processAndSetTickets(tickets);
  }

  void _processAndSetTickets(List<Map<String, dynamic>> tickets) {
    List<Map<String, dynamic>> ticketsInUse =
        tickets.where((ticket) => ticket['in']).toList();
    List<Map<String, dynamic>> otherTickets =
        tickets.where((ticket) => !ticket['in']).toList();
    ticketsInUse.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
    otherTickets.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

    if (mounted) {
      setState(() {
        _tickets = [..._tickets, ...ticketsInUse, ...otherTickets];
        _isLoading = false;
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
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
        color: const Color(0xffAD3838),
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
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                '\$$_wallet',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChargeWalletScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color(0xffAD3838),
                  backgroundColor: Colors.white,
                ),
                child: const Text('Charge Wallet',
                    style: TextStyle(color: Color(0xffAD3838))),
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
              color: Color(0xffAD3838),
            ),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _tickets.isEmpty
                  ? const Center(
                      child: Text(
                        'No tickets purchased',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
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
                                builder: (context) =>
                                    QRcode(qrData: ticket['id']),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color:
                                ticket['in'] ? Colors.green[100] : Colors.white,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10.0),
                              leading: Icon(
                                ticket['type'] == 'metro'
                                    ? Icons.train
                                    : Icons.directions_bus,
                                color: ticket['type'] == 'metro'
                                    ? const Color(0xffAD3838)
                                    : const Color(0xff343890),
                                size: 40,
                              ),
                              title: Text(
                                'Time: ${_formatTimestamp(ticket['timestamp'])}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price: \$${ticket['price']}'),
                                  Text(
                                    ticket['type'] == 'metro'
                                        ? 'Metro Ticket'
                                        : 'Bus Ticket',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  if (ticket['in'])
                                    const Text(
                                      'This ticket is in use',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  color: Colors.grey),
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
