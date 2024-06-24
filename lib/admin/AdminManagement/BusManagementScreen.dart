import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tareeqy_metro/admin/Service/AdminService.dart';

class BusManagementScreen extends StatefulWidget {
  @override
  State<BusManagementScreen> createState() => _BusManagementScreenState();
}

class _BusManagementScreenState extends State<BusManagementScreen> {
  final AdminService _adminService = AdminService();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _regionsController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _filteredBuses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          'Bus Management',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Bus Number',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Filter the list of buses based on the entered search query
                setState(() {
                  if (value.isNotEmpty) {
                    _filteredBuses = _adminService.filterBusesByNumber(
                        value, _snapshot?.docs ?? []);
                  } else {
                    _filteredBuses = [];
                  }
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getAllBuses(),
              builder: (context, snapshot) {
                _snapshot = snapshot.data; // Storing the snapshot for later use
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No buses found.'),
                  );
                } else {
                  List<DocumentSnapshot> buses = _filteredBuses.isNotEmpty
                      ? _filteredBuses
                      : snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: _filteredBuses.isEmpty &&
                            _searchController.text.isNotEmpty
                        ? 1
                        : buses.length,
                    itemBuilder: (context, index) {
                      if (_filteredBuses.isEmpty &&
                          _searchController.text.isNotEmpty) {
                        return Center(
                          child: Text(
                              'No buses found for "${_searchController.text}"'),
                        );
                      } else {
                        final bus = buses[index];
                        final regions = (bus.data() as Map<String, dynamic>)
                                .containsKey('Stations')
                            ? bus['Stations'] as List<dynamic>
                            : [];
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text('Bus Number: ${bus.id}'),
                            subtitle: Text('Regions: ${regions.join(', ')}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _showUpdateBusDialog(
                                        context, bus.id, regions);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _confirmDeleteBus(context, bus.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBusDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  QuerySnapshot? _snapshot; // Storing the snapshot for later use

  void _showAddBusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Bus'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _busNumberController,
                    decoration: InputDecoration(labelText: 'Bus Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bus number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _regionsController,
                    decoration:
                        InputDecoration(labelText: 'Regions (comma-separated)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter regions';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  List<String> regions = _regionsController.text
                      .split(',')
                      .map((region) => region.trim())
                      .toList();
                  _adminService.addBus(_busNumberController.text, regions);
                  _busNumberController.clear();
                  _regionsController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateBusDialog(
      BuildContext context, String busNumber, List<dynamic> regions) {
    TextEditingController busNumberController =
        TextEditingController(text: busNumber);
    TextEditingController regionsController =
        TextEditingController(text: regions.join(', '));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Bus'),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: busNumberController,
                    decoration: InputDecoration(labelText: 'Bus Number'),
                    enabled: true, // Enable editing bus number
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: regionsController,
                    decoration:
                        InputDecoration(labelText: 'Regions (comma-separated)'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String oldBusNumber = busNumber;
                String newBusNumber = busNumberController.text;
                List<String> updatedRegions = regionsController.text
                    .split(',')
                    .map((region) => region.trim())
                    .toList();
                await _adminService.updateBus(oldBusNumber, newBusNumber,
                    updatedRegions); // Update bus number and regions
                Navigator.pop(context);
                setState(() {
                  _filteredBuses = []; // Clear filters
                });
                // Fetch updated list of buses
                _adminService.getAllBuses();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteBus(BuildContext context, String busNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this bus?'),
          actions: [
            TextButton(
              onPressed: () {
                _adminService.removeBus(busNumber);
                Navigator.pop(context);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }
}
