import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:intl/intl.dart';

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
        final ticketIds = List<String>.from(userDoc.data()!['qrCodes']);
        await _fetchTickets(ticketIds);
      }
    }
  }

  Future<void> _fetchTickets(List<String> ticketIds) async {
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

    if (mounted) {
      setState(() {
        _tickets = [...ticketsInUse, ...otherTickets];
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_username != null && _wallet != null)
                Container(
                  padding: const EdgeInsets.all(20.0),
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
                    children: [
                      Text(
                        _username!,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Color.fromARGB(255, 9, 255, 17)),
                          const SizedBox(width: 5),
                          Text(
                            '\$$_wallet',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              Container(
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
                    Text(
                      'Tickets:',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      color: ticket['in']
                                          ? const Color.fromARGB(
                                              255, 143, 255, 15)
                                          : Colors.white,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 5),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        leading: const Icon(Icons.train,
                                            color: Colors.blueAccent, size: 40),
                                        title: Text(
                                          'Time: ${_formatTimestamp(ticket['timestamp'])}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('Price: \$${ticket['price']}'),
                                            if (ticket['in'])
                                              const Text(
                                                'This ticket is in use',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  );
                                },
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
