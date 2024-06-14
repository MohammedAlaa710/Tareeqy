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
    _loadData(); // Call a method to load data (getStations and getBusDetails)
  }

  Future<void> _loadData() async {
   // if (_busService.stations.isEmpty) { // mmkn nshelha el comment bta3 el if after devolopment (just for the cause of testing the database and keep it updated)
      await _busService.getStations();
      await _busService.getBusDetails();
    //}
    setState(() {
      isLoading = false; // Set loading to false when data fetch completes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        title: const Text(
          'Bus',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SingleChildScrollView(
                child: Image.asset(
                  "assets/images/busIconn.jpg",
                  width: 250,
                  height: 250,
                ),
              ),
            ),
            const SizedBox(height: 5),
            if (isLoading)
              const CircularProgressIndicator() // Show loading indicator while data is loading
            else
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
                          backgroundColor: const Color.fromARGB(255, 40, 53, 173),
                          minimumSize: const Size(150, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                          backgroundColor: const Color.fromARGB(255, 40, 53, 173),
                          minimumSize: const Size(150, 50),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  const SizedBox(height: 20),
                  if (showBusNumbers)
                    for (int i = 0;
                        i <
                            _busService
                                .getBusNumber(selectedValue1, selectedValue2)
                                .length;
                        i++)
                      Container(
                        margin: const EdgeInsets.only(left: 3, right: 3, bottom: 3),
                        color: const Color.fromARGB(255, 128, 189, 250),
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
                                                _busService.getBusNumber(selectedValue1,
                                                    selectedValue2),
                                                selectedValue1,
                                                selectedValue2),
                                            _busService.getBusNumber(selectedValue1,
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
                              /*Container(
                                padding: EdgeInsets.only(left: 20),
                                child: Image.asset(
                                  "assets/images/BusIcon.png",
                                  width: 65,
                                  height: 65,
                                ),
                              ),*/
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
                                        ),
                                      ),
                                      Text(
                                        //t3ala
                                        _busService.insertionSort(
                                            _busService.regionsCoveredList(
                                                _busService.getBusNumber(
                                                    selectedValue1, selectedValue2),
                                                selectedValue1,
                                                selectedValue2),
                                            _busService.getBusNumber(
                                                selectedValue1, selectedValue2))[i],
                                        style: const TextStyle(
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
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        _busService.getBusRegions(
                                                _busService.insertionSort(
                                                    _busService.regionsCoveredList(
                                                        _busService.getBusNumber(selectedValue1,
                                                            selectedValue2),
                                                        selectedValue1,
                                                        selectedValue2),
                                                    _busService.getBusNumber(selectedValue1,
                                                        selectedValue2))[i],
                                                selectedValue1,
                                                selectedValue2)
                                            .length
                                            .toString(),
                                        style: const TextStyle(
                                            //fontWeight: FontWeight.bold,
                                            fontSize: 18),
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