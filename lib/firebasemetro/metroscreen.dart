// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:tareeqy_metro/QR-Code/generateQrCode.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasemetro/metroService.dart';
import 'package:tareeqy_metro/firebasemetro/tripdetailsScreen.dart';
import 'package:tareeqy_metro/maps/track_location.dart';

class MetroScreen extends StatefulWidget {
  const MetroScreen({super.key});

  @override
  State<MetroScreen> createState() => _MetroScreenState();
}

class _MetroScreenState extends State<MetroScreen> {
  String selectedValue1 = '';
  String selectedValue2 = '';
  bool timePrice = false;
  late final metroService _metroService;

  @override
  void initState() {
    super.initState();
    _metroService = metroService();
    _loadStations();
  }

  Future<void> _loadStations() async {
    await _metroService.GetStations();
    setState(() {}); // Update the UI with the loaded stations
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.white,
        title: Text(
          'Metro',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      //0xff2A2D2E,, Color.fromARGB(150, 0, 63, 171),
      /* appBar: AppBar(
          title: Text(
            'Metro',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 14, 72, 171)), */
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Image(
              image: AssetImage("assets/images/metroIconn.jpg"),
              height: 220,
              width: 220,
            ),
            ////////////////////////////////////////////////////////////////////////////
            //const SizedBox(height: 0),
            ////////////////////////////////////////////////////////////////////////////
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
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
            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 15),
            ////////////////////////////////////////////////////////////////////////////
            ///clear/qr
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 40, 53, 173),
                    minimumSize: Size(150, 50),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      // This gives the button squared edges
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedValue1 = '';
                      selectedValue2 = '';
                    });
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Container(width: 20),
                //=================================================================//
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 40, 53, 173),
                    minimumSize: Size(150, 50),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      // This gives the button squared edges
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenerateQrCode()));
                  },
                  child: const Text(
                    'Get a Tticket?',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),

            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            if (selectedValue1 != '' && selectedValue2 != '')
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                height: 150,
                child: Row(
                  children: [
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.attach_money,
                            size: 70,
                          ),
                          const Text(
                            'Ticket Price',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                _metroService.calculateTime(
                                    selectedValue1, selectedValue2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ///////////////////////////////////////////////////////////////////////
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////

                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.black,
                      endIndent: 10,
                      indent: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.timelapse,
                            size: 70,
                          ),
                          const Text(
                            'Estimated Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                _metroService.calculateTime(
                                    selectedValue1, selectedValue2),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ///////////////////////////////////////////////////////////////////////
                    Spacer(
                      flex: 1,
                    ),
                    ///////////////////////////////////////////////////////////////////////
                  ],
                ),
              ),
            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 20),
            ////////////////////////////////////////////////////////////////////////////

            ////////////////////////////////////////////////////////////////////////////
            const SizedBox(height: 10),
            ////////////////////////////////////////////////////////////////////////////
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 30,
                          color: Color.fromARGB(255, 14, 72, 171),
                        ),
                      ),
                      //const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color.fromARGB(255, 14, 72, 171),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Color.fromARGB(255, 40, 53, 173),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return TrackLocation();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Nearest Station?',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),

                      //han7ot tripxxxx
                      if (selectedValue1 != '' && selectedValue2 != '')
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Color.fromARGB(255, 14, 72, 171),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 40, 53, 173),
                                minimumSize: Size(double.infinity,
                                    50), // Adjust width to fit the available space
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TripDetails(
                                        route: _metroService.getRoute(
                                            selectedValue1, selectedValue2),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Trip Details',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ////////////////////////////////////////////////////////////////////////////
            //const SizedBox(height: 20),
            ////////////////////////////////////////////////////////////////////////////
          ],
        ),
      ),
    );
  }
}
