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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                if (!isSwitched)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFF00796B)),
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
                        const Icon(Icons.location_on, color: Color(0xFFB31312)),
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
                                busNumber = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          busNumber = '';
                          // Update bus numbers after clearing
                        });
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (isSwitched)
                          const Text(
                            "Bus Regions",
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
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
                        if (!isSwitched)
                          const Text(
                            "Bus Number",
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.bold),
                          )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                if (!isSwitched)
                  if (selectedValue1.isNotEmpty && selectedValue2.isNotEmpty)
                    for (int i = 0;
                        i <
                            _busService
                                .getBusNumber(selectedValue1, selectedValue2)
                                .length;
                        i++)
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
                if (isSwitched)
                  if (busNumber.isNotEmpty)
                    const Text(
                      "Regions passes by:",
                      style: TextStyle(
                          color: Color(0xFFB31312),
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),

                if (isSwitched)
                  if (busNumber.isNotEmpty) const SizedBox(height: 10),
                if (isSwitched)
                  if (busNumber.isNotEmpty)
                    for (int i = 0;
                        i < _busService.getAllBusStations(busNumber).length;
                        i++)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 148, 194, 214),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${i + 1}.  ${_busService.getAllBusStations(busNumber)[i]}",
                          style: const TextStyle(
                            color: Color(0xFF073042),
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                //////////////////////////////////////////////////////////
                if (_busService.getMetroStations(busNumber).isNotEmpty)
                  if (isSwitched)
                    if (busNumber.isNotEmpty) const SizedBox(height: 10),
                if (_busService.getMetroStations(busNumber).isNotEmpty)
                  if (isSwitched)
                    if (busNumber.isNotEmpty)
                      const Text(
                        "Metro Stations passes by:",
                        style: TextStyle(
                            color: Color(0xFFB31312),
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                if (_busService.getMetroStations(busNumber).isNotEmpty)
                  if (isSwitched)
                    if (busNumber.isNotEmpty) const SizedBox(height: 10),
                if (_busService.getMetroStations(busNumber).isNotEmpty)
                  if (isSwitched)
                    if (busNumber.isNotEmpty)
                      for (int i = 0;
                          i < _busService.getMetroStations(busNumber).length;
                          i++)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 78, 167, 156),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${i + 1}.  ${_busService.getMetroStations(busNumber)[i]}",
                            style: const TextStyle(
                              color: Color(0xFF073042),
                              fontSize: 20,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
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
