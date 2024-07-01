import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/Auth/Register.dart';
import 'package:tareeqy_metro/admin/AdminManagement/BusManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminManagement/MetroManagementScreen.dart';
import 'package:tareeqy_metro/components/AdminButton.dart';
import 'package:tareeqy_metro/components/LogOutDialog.dart';

class AdminHomePage extends StatefulWidget {
  AdminHomePage({super.key});

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final LogoutDialog logoutDialog = LogoutDialog();
  String? _username;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((userDoc) {
          if (userDoc.exists) {
            if (mounted) {
              setState(() {
                _username = userDoc.data()!['userName'];
              });
            }
          }
        });
      } catch (e) {
        print('Error fetching user document: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
      ),
      body: SafeArea(
        child: PageView(
          children: [
            _buildHomePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 215,
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Color(0xFF073042),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello Admin,\n$_username ',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => logoutDialog.showLogoutDialog(context),
                    color: const Color.fromARGB(255, 255, 0, 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60.0),
          AdminButton(
            backgroundColor: const Color(0xFFB31312),
            icon: Icons.directions_subway,
            text: "Manage Metro Stations",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MetroManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          AdminButton(
            backgroundColor: const Color(0xFFB31312),
            icon: Icons.directions_bus,
            text: "Manage Buses",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BusManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          AdminButton(
            icon: Icons.person_add,
            text: "Add Driver",
            backgroundColor: const Color(0xFF00796B),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Register(
                      collection: "Drivers",
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
