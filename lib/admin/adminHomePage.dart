import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/Auth/Login.dart';
import 'package:tareeqy_metro/Auth/Register.dart';
import 'package:tareeqy_metro/admin/AdminBus/BusScanner.dart';
import 'package:tareeqy_metro/admin/AdminManagement/BusManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminManagement/MetroManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminMetro/metroStations.dart';

class adminHomePage extends StatelessWidget {
  const adminHomePage({Key? key});

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
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Manage Metro Stations
              AdminButton(
                icon: Icons.directions_subway,
                text: "Manage Metro Stations",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MetroManagementScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
                            AdminButton(
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
              const SizedBox(height: 20),
              // Scan Metro Code
              AdminButton(
                icon: Icons.qr_code_scanner,
                text: "Scan Metro Code",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MetroStations()),
                  );
                },
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 20),
              // Scan Bus Code
              AdminButton(
                icon: Icons.qr_code,
                text: "Scan Bus Code",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const busQRCodeScannerPage()),
                  );
                },
                backgroundColor: Colors.orange,
              ),
              const SizedBox(height: 20),
              // Add Driver
              AdminButton(
                icon: Icons.person_add,
                text: "Add Driver",
                backgroundColor: Colors.deepPurple,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Register(
                              collection: "Drivers",
                            )),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Manage Buses

            ],
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
    return ElevatedButton.icon(
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
    );
  }
}
