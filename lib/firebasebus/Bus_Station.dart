// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, prefer_const_constructors_in_immutables, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';

class Bus_Screen extends StatefulWidget {
  Bus_Screen({super.key});

  @override
  State<Bus_Screen> createState() => _Bus_ScreenState();
}

class _Bus_ScreenState extends State<Bus_Screen> {
  List<String> stations = [];
  List<QueryDocumentSnapshot> stationsQuery = [];
  String selectedValue1 = '';
  String selectedValue2 = '';

  @override
  void initState() {
    super.initState();
    getStations();
  }

  Future<void> getStations() async {
    QuerySnapshot bus =
        await FirebaseFirestore.instance.collection('Bus').get();
    stationsQuery.addAll(bus.docs);
    setState(() {
      stations = bus.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.fromLTRB(50, 60, 50, 50),
                child: Image.asset(
                  "assets/images/bus.jpg",
                  width: 300,
                  height: 200,
                ),
              ),
            ),
            const SizedBox(height: 10),
            MyDropdownSearch(
              fromto: 'From',
              items: stations.where((x) => x != selectedValue2).toSet(),
              selectedValue: selectedValue1,
              onChanged: (value) {
                setState(() {
                  selectedValue1 = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            MyDropdownSearch(
              fromto: 'To',
              items: stations.where((x) => x != selectedValue1).toSet(),
              selectedValue: selectedValue2,
              onChanged: (value) {
                setState(() {
                  selectedValue2 = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedValue1 = '';
                  selectedValue2 = '';
                });
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                testprint(selectedValue1, selectedValue2);
              },
              child: const Text('Bus Number'),
            ),
            if (selectedValue1 != '' && selectedValue2 != '')
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                height: 150,
                child: Row(children: [
                  Spacer(flex: 1),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  //hangeb arkam el otobesat mn el firebase
  List<String> getBusNumber(String selectedItem1, String selectedItem2) {
    List<String> busNumber1 = [];
    List<String> busNumber2 = [];
    List<String> busNumber = [];
    for (int i = 0; i < stationsQuery.length; i++) {
      if (stationsQuery[i].id == selectedItem1) {
        // Check if 'Bus_Number' field exists and is not null
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber1.add(busNumberItem); // Add each string in the array
          }
        }
      } else if (stationsQuery[i].id == selectedItem2) {
        // Check if 'Bus_Number' field exists and is not null
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber2.add(busNumberItem); // Add each string in the array
          }
        }
      }
    }
    busNumber = busNumber1.toSet().intersection(busNumber2.toSet()).toList();
    return busNumber;
  }

  void testprint(String selectedItem1, String selectedItem2) {
    for (int i = 0;
        i < getBusNumber(selectedItem1, selectedItem2).length;
        i++) {
      print(getBusNumber(selectedItem1, selectedItem2)[i]);
    }
  }
}
