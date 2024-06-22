import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tareeqy_metro/Auth/Login.dart';
import 'package:tareeqy_metro/Auth/Register.dart';
import 'package:tareeqy_metro/admin/AdminBus/BusScanner.dart';
import 'package:tareeqy_metro/admin/AdminManagement/BusManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminManagement/MetroManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminMetro/metroStations.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key});

  void _logout(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //a7mr Color(0xFFB31312),,  a5dr Color(0xFF00796B),,  Color(0xFF073042)
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Manage Metro Stations
                Center(
                  child: AdminButton(
                    backgroundColor: const Color(0xFFB31312),
                    icon: Icons.directions_subway,
                    text: "Manage Metro Stations",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const MetroManagementScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: AdminButton(
                    backgroundColor: const Color(0xFFB31312),
                    icon: Icons.directions_bus,
                    text: "Manage Buses",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusManagementScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Scan Metro Code
                Center(
                  child: AdminButton(
                    icon: Icons.qr_code_scanner,
                    text: "Scan Metro Code",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MetroStations()),
                      );
                    },
                    backgroundColor: const Color(0xFF00796B),
                  ),
                ),
                const SizedBox(height: 20),
                // Scan Bus Code
                Center(
                  child: AdminButton(
                    icon: Icons.qr_code,
                    text: "Scan Bus Code",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const busQRCodeScannerPage()),
                      );
                    },
                    backgroundColor: const Color(0xFF00796B),
                  ),
                ),
                const SizedBox(height: 20),
                // Add Driver
                Center(
                  child: AdminButton(
                    icon: Icons.person_add,
                    text: "Add Driver",
                    backgroundColor: Colors.orange,
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
                ),
                const SizedBox(height: 20),
                // Manage Buses
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdminButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const AdminButton({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250, // Fixed width
      height: 80, // Fixed height
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 40),
        label: Text(text, style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor ?? Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(fontSize: 16),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
