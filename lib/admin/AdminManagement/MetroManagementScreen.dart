import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tareeqy_metro/admin/Service/AdminService.dart';

class MetroManagementScreen extends StatefulWidget {
  const MetroManagementScreen({Key? key});

  @override
  _MetroManagementScreenState createState() => _MetroManagementScreenState();
}

class _MetroManagementScreenState extends State<MetroManagementScreen> {
  final AdminService _service = AdminService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

String _selectedLine = 'Metro_Line_1';
@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      title: Text("Metro Management"),
      centerTitle: true,
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown for selecting metro line
              Text(
                'Select Metro Line',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedLine,
                decoration: InputDecoration(
                  labelText: 'Metro Line',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLine = newValue!;
                  });
                },
                items: <String>['Metro_Line_1', 'Metro_Line_2', 'Metro_Line_3']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Station list
              Text(
                'Stations List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 180, // Adjust height as needed
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _service.getStations(_selectedLine),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    return ListView.separated(
                      physics: ClampingScrollPhysics(),
                      separatorBuilder: (context, index) => Divider(color: Colors.grey),
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        final station = data.docs[index];
                        return ListTile(
                          title: Text(station['name']),
                          subtitle: Text('Number: ${station['number']}'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteDialog(context, station),
                          ),
                          onTap: () {
                            _nameController.text = station['name'];
                            _numberController.text = station['number'].toString();
                            _latController.text = station['latlng'].latitude.toString();
                            _lngController.text = station['latlng'].longitude.toString();
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Form for adding/updating stations
              Text(
                'Station Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Station Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _numberController,
                decoration: InputDecoration(
                  labelText: 'Station Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _latController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
              SizedBox(height: 8),
              TextField(
                controller: _lngController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addStation,
                    child: Text('Add Station', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _updateStation,
                    child: Text('Update Station', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}




  Future<void> _confirmDeleteDialog(BuildContext context, DocumentSnapshot station) async {
    final name = station['name'];
    final number = station['number'];
    final latlng = station['latlng'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to delete this station?'),
              Text('Name: $name'),
              Text('Number: $number'),
              Text('Location: (${latlng.latitude}, ${latlng.longitude})'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _service.deleteStation(_selectedLine, station.id);
                _showSnackbar('Station deleted successfully');
              },
              icon: Icon(Icons.delete_forever_outlined, color: Colors.white),
              label: Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

 void _showSnackbar(String message, {bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          isSuccess
              ? Icon(Icons.check, color: Colors.white)
              : Icon(Icons.warning, color: Colors.white),
          SizedBox(width: 8.0),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: isSuccess ? Duration(seconds: 2) : Duration(seconds: 3),
    ),
  );
}



  Future<void> _addStation() async {
    try {
      final name = _nameController.text;
      final number = int.parse(_numberController.text);
      final latlng = GeoPoint(
        double.parse(_latController.text),
        double.parse(_lngController.text),
      );

      // Show confirmation dialog for adding station
      bool? confirmAdd = await _showAddConfirmationDialog(name, number, latlng);
      if ((confirmAdd != null && confirmAdd)) {
        await _service.addStation(_selectedLine, name, number, latlng);
        _showSnackbar('Station added successfully' , isSuccess: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _updateStation() async {
    try {
      final name = _nameController.text;
      final number = int.parse(_numberController.text);
      final latlng = GeoPoint(
        double.parse(_latController.text),
        double.parse(_lngController.text),
      );

      // Show confirmation dialog for updating station
      bool? confirmUpdate = await _showUpdateConfirmationDialog(name, number, latlng);
      if (confirmUpdate != null && confirmUpdate) {
        await _service.updateStation(_selectedLine, name, number, latlng);
        _showSnackbar('Station updated successfully', isSuccess: true);
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<bool?> _showAddConfirmationDialog(String name, int number, GeoPoint latlng) async {
    return showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Add Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to add the station "$name"?'),
              Text('Station Number: $number'),
              Text('Latitude: ${latlng.latitude}, Longitude: ${latlng.longitude}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to confirm
              },
              child: const Text('Add',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showUpdateConfirmationDialog(String name, int number, GeoPoint latlng) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Are you sure you want to update the station "$name"?'),
              Text('New Station Number: $number'),
              Text('New Latitude: ${latlng.latitude}, New Longitude: ${latlng.longitude}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to confirm
              },
              child: const Text('Update',style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        );
      },
    );
  }
}