import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasebus/BusDetails.dart';
import 'package:tareeqy_metro/firebasebus/busService.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({Key? key}) : super(key: key);

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  String selectedValue1 = '';
  String selectedValue2 = '';
  late final BusService _busService;

  @override
  void initState() {
    super.initState();
    _busService = BusService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Color(0xFF073042),
        title: const Text(
          'Bus',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/images/busIconn.png",
                width: 150,
                height: 150,
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF00796B)),
                      SizedBox(width: 10),
                      Expanded(
                        child: MyDropdownSearch(
                          fromto: 'From',
                          items: _busService.stations
                              .where((x) => x != selectedValue2)
                              .toSet(),
                          selectedValue: selectedValue1,
                          onChanged: (value) {
                            setState(() {
                              selectedValue1 = value!;
                              // Update bus numbers when 'From' changes
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFFB31312)),
                      SizedBox(width: 10),
                      Expanded(
                        child: MyDropdownSearch(
                          fromto: 'To',
                          items: _busService.stations
                              .where((x) => x != selectedValue1)
                              .toSet(),
                          selectedValue: selectedValue2,
                          onChanged: (value) {
                            setState(() {
                              selectedValue2 = value!;
                              // Update bus numbers when 'To' changes
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF073042),
                        minimumSize: Size(150, 50),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedValue1 = '';
                          selectedValue2 = '';
                          // Update bus numbers after clearing
                        });
                      },
                      child: Text(
                        'Clear',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                if (selectedValue1.isNotEmpty && selectedValue2.isNotEmpty)
                  for (int i = 0;
                      i <
                          _busService
                              .getBusNumber(selectedValue1, selectedValue2)
                              .length;
                      i++)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 148, 194, 214),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BusDetails(
                                busNumber: _busService.insertionSort(
                                    _busService.regionsCoveredList(
                                        _busService.getBusNumber(
                                            selectedValue1, selectedValue2),
                                        selectedValue1,
                                        selectedValue2),
                                    _busService.getBusNumber(
                                        selectedValue1, selectedValue2))[i],
                                regions: _busService.getBusRegions(
                                    _busService.insertionSort(
                                        _busService.regionsCoveredList(
                                            _busService.getBusNumber(
                                                selectedValue1, selectedValue2),
                                            selectedValue1,
                                            selectedValue2),
                                        _busService.getBusNumber(
                                            selectedValue1, selectedValue2))[i],
                                    selectedValue1,
                                    selectedValue2),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Bus Number: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF073042),
                                  ),
                                ),
                                Text(
                                  _busService.insertionSort(
                                      _busService.regionsCoveredList(
                                          _busService.getBusNumber(
                                              selectedValue1, selectedValue2),
                                          selectedValue1,
                                          selectedValue2),
                                      _busService.getBusNumber(
                                          selectedValue1, selectedValue2))[i],
                                  style: TextStyle(
                                    color: Color(0xFFB31312),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Regions Covered: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF073042),
                                  ),
                                ),
                                Text(
                                  _busService
                                      .getBusRegions(
                                          _busService.insertionSort(
                                              _busService.regionsCoveredList(
                                                  _busService.getBusNumber(
                                                      selectedValue1,
                                                      selectedValue2),
                                                  selectedValue1,
                                                  selectedValue2),
                                              _busService.getBusNumber(
                                                  selectedValue1,
                                                  selectedValue2))[i],
                                          selectedValue1,
                                          selectedValue2)
                                      .length
                                      .toString(),
                                  style: TextStyle(
                                    color: Color(0xFFB31312),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Click For Details",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF073042),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
