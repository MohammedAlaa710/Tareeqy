import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/QR-service.dart';
import 'package:tareeqy_metro/QR-Code/QRcode.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';

class srcDstQR extends StatefulWidget {
  const srcDstQR({super.key});

  @override
  State<srcDstQR> createState() => _srcDstQRState();
}

class _srcDstQRState extends State<srcDstQR> {
  String selectedValue1 = '';
  String selectedValue2 = '';
  bool isDataLoaded = false;
  late final metroService _metroService;
  late final QRservices _qrServices; // Create an instance of the service

  @override
  void initState() {
    super.initState();
    _metroService = metroService();
    _qrServices = QRservices();
    _loadStations();
  }

  Future<void> _loadStations() async {
    await _metroService.getStations();
    setState(() {
      isDataLoaded = true;
    }); // Update the UI with the loaded stations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF073042),
        title: const Text(
          "Get a Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //here must be a text box that takes only numbers and the number must be less than 80
            if (!isDataLoaded) const CircularProgressIndicator(),
            if (isDataLoaded)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: MyDropdownSearch(
                      fromto: 'From',
                      items: _metroService
                          .getStationNames()
                          .where((String x) => x != selectedValue2)
                          .toSet(),
                      selectedValue: selectedValue1,
                      onChanged: (value) {
                        setState(() {
                          selectedValue1 = value!;
                        });
                      },
                    ),
                  ),
                  ////////////////////////////////////////////////////////////////////////////
                  const SizedBox(height: 10),
                  ////////////////////////////////////////////////////////////////////////////
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: MyDropdownSearch(
                      fromto: 'To',
                      items: _metroService
                          .getStationNames()
                          .where((String x) => x != selectedValue1)
                          .toSet(),
                      selectedValue: selectedValue2,
                      onChanged: (value) {
                        setState(() {
                          selectedValue2 = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(
                height: 20), // Add some space between the dropdown and button
            if (isDataLoaded)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                ),
                onPressed: (selectedValue1 != '' && selectedValue2 != '')
                    ? () async {
                        String docId = await _qrServices.addQRWithSrcandDst(
                            context, selectedValue1, selectedValue2);
                        if (docId.isNotEmpty) {
                          await _qrServices.addQRCodeToUser(context, docId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRcode(qrData: docId, ticketType: 'metro'),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text(
                  'Get The Ticket',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
