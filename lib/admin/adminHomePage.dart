import 'package:flutter/material.dart';
import 'package:tareeqy_metro/Auth/Register.dart';
import 'package:tareeqy_metro/admin/AdminManagement/BusManagementScreen.dart';
import 'package:tareeqy_metro/admin/AdminManagement/MetroManagementScreen.dart';
import 'package:tareeqy_metro/components/AdminButton.dart';
import 'package:tareeqy_metro/components/LogOutDialog.dart';

class AdminHomePage extends StatelessWidget {
  AdminHomePage({super.key});
  final LogoutDialog logoutDialog = LogoutDialog();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.red,
            onPressed: () => logoutDialog.showLogoutDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: AdminButton(
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
                          builder: (context) => const BusManagementScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: AdminButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
