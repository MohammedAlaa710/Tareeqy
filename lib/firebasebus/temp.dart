// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, prefer_const_constructors_in_immutables, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/components/searchbar.dart';

class BusScreen extends StatefulWidget {
  BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  List<QueryDocumentSnapshot> stations = [];
  String selectedValue1 = '';
  String selectedValue2 = '';

  GetStations() async {
    QuerySnapshot Bus =
        await FirebaseFirestore.instance.collection('Bus').get();
    stations.addAll(Bus.docs);
    setState(() {});
  }

  void initState() {
    GetStations();
    super.initState();
  }

  List<String> getStations() {
    List<String> station_name = [];
    for (int i = 0; i < stations.length; i++) {
      station_name.add(stations[i].id);
    }
    return station_name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   //elevation: 5,
        //   backgroundColor: Colors.white,
        // ),
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        SingleChildScrollView(
          child: Container(
            //alignment: Alignment.topCenter,
            padding: EdgeInsets.fromLTRB(50, 60, 50, 50),
            // margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Image.asset(
              "assets/images/bus.jpg",
              width: 300,
              height: 200,
            ),
          ),
        ),
        //000000000000000000000000000000000000000000000000000000000000000000
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [],
          ),
        ),
        //From text box
        ////////////////////////////////////////////////////////////////////////////
        const SizedBox(height: 10),
        ////////////////////////////////////////////////////////////////////////////

        MyDropdownSearch(
          fromto: 'From',
          //items: stations[],
          items: getStations().where((String x) => x != selectedValue2).toSet(),
          selectedValue: selectedValue1,
          onChanged: (value) {
            setState(() {
              selectedValue1 = value!;
            });
          },
        ),
        ////////////////////////////////////////////////////////////////////////////
        const SizedBox(height: 10),
        ////////////////////////////////////////////////////////////////////////////
        MyDropdownSearch(
          fromto: 'To',
          items: getStations().where((String x) => x != selectedValue1).toSet(),
          selectedValue: selectedValue2,
          onChanged: (value) {
            setState(() {
              selectedValue2 = value!;
            });
          },
        ),
        const SizedBox(height: 10),
        ////////////////////////////////////////////////////////////////////////////
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Color(0xff2B62AD),
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
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              Color(0xff2B62AD),
            ),
          ),
          onPressed: () {
            testprint(selectedValue1, selectedValue2);
            /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BusDetails(
                          selectedItem1: selectedValue1,
                          selectedItem2: selectedValue2,
                        )));*/
          },
          child: const Text(
            'Bus Number',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        //
        const SizedBox(height: 20),
        ////////////////////////////////////////////////////////////////////////////
        if (selectedValue1 != '' && selectedValue2 != '')
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              height: 150,
              child: Row(children: [
                Spacer(
                  flex: 1,
                ),
              ])),
        //////
        ///
        //
      ]),
    ));
  }

  //hangeb arkam el otobesat mn el firebase
  List<String> getBusNumber(String selectedItem1, String selectedItem2) {
    List<String> busNumber1 = [];
    List<String> busNumber2 = [];
    List<String> busNumber = [];
    for (int i = 0; i < stations.length; i++) {
      if (stations[i].id == selectedItem1) {
        // Check if 'Bus_Number' field exists and is not null
        if (stations[i].get('Bus_Number') != null) {
          for (String busNumberItem in stations[i].get('Bus_Number')) {
            busNumber1.add(busNumberItem); // Add each string in the array
          }
        }
      } else if (stations[i].id == selectedItem2) {
        // Check if 'Bus_Number' field exists and is not null
        if (stations[i].get('Bus_Number') != null) {
          for (String busNumberItem in stations[i].get('Bus_Number')) {
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
