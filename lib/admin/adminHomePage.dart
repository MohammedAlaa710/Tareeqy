import 'package:flutter/material.dart';
import 'package:tareeqy_metro/admin/metroStations.dart';

class adminHomePage extends StatelessWidget {
  const adminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MetroStations()),
                );
              },
              child: Text("Scan code")),
        ],
      )),
    );
  }
}
