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
  bool showBusNumbers = false;
  bool isLoading = true; // Track loading state
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 30),
            Center(
              child: SingleChildScrollView(
                child: Image.asset(
                  "assets/images/busIconn.png",
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: MyDropdownSearch(
                    fromto: 'From',
                    items: _busService.stations
                        .where((x) => x != selectedValue2)
                        .toSet(),
                    selectedValue: selectedValue1,
                    onChanged: (value) {
                      setState(() {
                        selectedValue1 = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: MyDropdownSearch(
                    fromto: 'To',
                    items: _busService.stations
                        .where((x) => x != selectedValue1)
                        .toSet(),
                    selectedValue: selectedValue2,
                    onChanged: (value) {
                      setState(() {
                        selectedValue2 = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF073042),
                        minimumSize: const Size(150, 50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedValue1 = '';
                          selectedValue2 = '';
                        });
                      },
                      child: const Text('Clear',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF073042),
                        minimumSize: const Size(150, 50),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showBusNumbers = true;
                        });
                      },
                      child: const Text(
                        'Show Buses',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (showBusNumbers)
                  for (int i = 0;
                      i <
                          _busService
                              .getBusNumber(selectedValue1, selectedValue2)
                              .length;
                      i++)
                    Container(
                      margin:
                          const EdgeInsets.only(left: 3, right: 3, bottom: 3),
                      color: Color.fromARGB(255, 148, 194, 214),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return BusDetails(
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
                                                  selectedValue1,
                                                  selectedValue2),
                                              selectedValue1,
                                              selectedValue2),
                                          _busService.getBusNumber(
                                              selectedValue1,
                                              selectedValue2))[i],
                                      selectedValue1,
                                      selectedValue2),
                                );
                              },
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(
                              flex: 1,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Bus Number : ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                    Text(
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
                                      style: const TextStyle(
                                        color: Color(0xFFB31312),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Regions Covered : ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 0, 0, 0),
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
                                      style: const TextStyle(
                                        color: Color(0xFFB31312),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(
                              flex: 1,
                            ),
                            const Text(
                              "Click For \n Details",
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            const Spacer(
                              flex: 1,
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
