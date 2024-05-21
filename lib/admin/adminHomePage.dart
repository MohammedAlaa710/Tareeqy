import 'package:flutter/material.dart';
import 'package:tareeqy_metro/admin/AdminBus/BusScanner.dart';
import 'package:tareeqy_metro/admin/AdminMetro/metroStations.dart';

class adminHomePage extends StatelessWidget {
  const adminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MetroStations()),
                );
              },
              child: const Text("Scan Metro code")),
         ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const busQRCodeScannerPage()),
                );
              },
              child: const Text("Scan Bus code")),
        ],
        
      )),
    );
  }
}
