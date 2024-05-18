import 'package:flutter/material.dart';
import 'package:tareeqy_metro/admin/metroScanner.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';

class MetroStations extends StatefulWidget {
  const MetroStations({super.key});

  @override
  State<MetroStations> createState() => _MetroStationsState();
}

class _MetroStationsState extends State<MetroStations> {
  String selectedValue1 = '';

  late Future<void> stationsFuture;

  metroService _metroService = metroService();

  @override
  void initState() {
    super.initState();
    stationsFuture = _metroService.getStations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("price page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<void>(
              future: stationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error fetching stations: ${snapshot.error}');
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: MyDropdownSearch(
                      fromto: 'From',
                      items: _metroService.getStationNames().toSet(),
                      selectedValue: selectedValue1,
                      onChanged: (value) {
                        setState(() {
                          selectedValue1 = value!;
                        });
                      },
                    ),
                  );
                }
              },
            ),
            const SizedBox(
                height: 20), // Add some space between the dropdown and button
            ElevatedButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          QRCodeScannerPage(station: selectedValue1)),
                );

                // Add document functionality here QRCodeScannerPage
              },
              child: const Text('Add Document'),
            ),
          ],
        ),
      ),
    );
  }
}
