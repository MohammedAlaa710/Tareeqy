import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasebus/BusDetails.dart';
import 'package:tareeqy_metro/firebasebus/busService.dart';

class BusScreen extends StatefulWidget {
  const BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  String selectedValue1 = '';
  String selectedValue2 = '';
  String busNumber = '';
  late final BusService _busService;
  bool isSwitched = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF073042),
    ));

    _busService = BusService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: const Color(0xFF073042),
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
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                "assets/images/busIconn.png",
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSwitched)
                        const Text(
                          "Select Regions",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      if (!isSwitched)
                        const Text(
                          "Select Regions",
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00796B)),
                        ),
                      const SizedBox(width: 5),
                      Switch(
                        activeColor: const Color(0xFFB31312),
                        activeTrackColor:
                            const Color.fromARGB(255, 209, 100, 100),
                        inactiveThumbColor: const Color(0xFF00796B),
                        inactiveTrackColor:
                            const Color.fromARGB(255, 45, 184, 168),
                        value: isSwitched,
                        onChanged: (value) =>
                            setState(() => isSwitched = value),
                      ),
                      const SizedBox(width: 5),
                      if (!isSwitched)
                        const Text(
                          "Select Bus Number",
                          style: TextStyle(
                              fontSize: 14.0, fontWeight: FontWeight.bold),
                        ),
                      if (isSwitched)
                        const Text(
                          "Select Bus Number",
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB31312)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (!isSwitched)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFB31312)),
                        const SizedBox(width: 10),
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
                if (!isSwitched) const SizedBox(height: 10),
                if (!isSwitched)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF00796B)),
                        const SizedBox(width: 10),
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
                if (isSwitched)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.bus_alert, color: Color(0xFF00796B)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyDropdownSearch(
                            fromto: 'Bus Number',
                            items: _busService.buses.toSet(),
                            selectedValue: busNumber,
                            onChanged: (value) {
                              setState(() {
                                //wadi
                                busNumber = value!;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BusDetails(
                                            busNumber: busNumber,
                                            metroStations: _busService
                                                .getMetroStations(busNumber),
                                            regions: _busService
                                                .getAllBusStations(busNumber),
                                          )),
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF073042),
                      minimumSize: const Size(100, 40),
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
                        busNumber = '';
                        // Update bus numbers after clearing
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const SizedBox(height: 30),
                if (!isSwitched)
                  if (selectedValue1.isNotEmpty && selectedValue2.isNotEmpty)
                    for (int i = 0;
                        i <
                            _busService
                                .getBusNumber(selectedValue1, selectedValue2)
                                .length;
                        i++)
                      //hna
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 148, 194, 214),
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
                                                  selectedValue1,
                                                  selectedValue2),
                                              selectedValue1,
                                              selectedValue2),
                                          _busService.getBusNumber(
                                              selectedValue1,
                                              selectedValue2))[i],
                                      selectedValue1,
                                      selectedValue2),
                                  metroStations: _busService.getMetroStations(
                                      _busService.insertionSort(
                                          _busService.regionsCoveredList(
                                              _busService.getBusNumber(
                                                  selectedValue1,
                                                  selectedValue2),
                                              selectedValue1,
                                              selectedValue2),
                                          _busService.getBusNumber(
                                              selectedValue1,
                                              selectedValue2))[i]),
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
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
                                    style: const TextStyle(
                                      color: Color(0xFFB31312),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Text(
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
