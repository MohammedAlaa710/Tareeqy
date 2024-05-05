// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, prefer_const_constructors_in_immutables, annotate_overrides

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tareeqy_metro/components/searchbar.dart';
import 'package:tareeqy_metro/firebasebus/BusDetails.dart';

class BusScreen extends StatefulWidget {
  BusScreen({super.key});

  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  List<String> stations = [];
  List<QueryDocumentSnapshot> stationsQuery = [];
  List<String> busquerytest = [];
  List<QueryDocumentSnapshot> busQuery = [];
  String selectedValue1 = '';
  String selectedValue2 = '';
  bool showBusNumbers = false;
  @override
  void initState() {
    super.initState();
    getStations();
    getBusDetails();
  }

  Future<void> getStations() async {
    try {
      QuerySnapshot bus =
          await FirebaseFirestore.instance.collection('Bus').get();
      stationsQuery.addAll(bus.docs);
      setState(() {
        stations = bus.docs.map((doc) => doc.id).toList();
      });
    } catch (error) {
      print("Error getting Bus data: $error");
    } // Add semicolon here
  }

  Future<void> getBusDetails() async {
    try {
      QuerySnapshot bus =
          await FirebaseFirestore.instance.collection('Bus2').get();
      busQuery.addAll(bus.docs);
      setState(() {
        busquerytest = bus.docs.map((doc) => doc.id).toList();
      });
    } catch (error) {
      print("Error getting Bus2 data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Colors.white,
        title: Text(
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
            SingleChildScrollView(
              child: Image.asset(
                "assets/images/busIconn.jpg",
                width: 250,
                height: 250,
              ),
            ),
            //const SizedBox(height: 5),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: MyDropdownSearch(
                fromto: 'From',
                items: stations.where((x) => x != selectedValue2).toSet(),
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
              padding: EdgeInsets.only(left: 10, right: 10),
              child: MyDropdownSearch(
                fromto: 'To',
                items: stations.where((x) => x != selectedValue1).toSet(),
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
                Spacer(
                  flex: 1,
                ),
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
                      //print(getBusRegions("n1", selectedValue1, selectedValue2)
                      //  .length);
                      testprints(getTwoBuses(selectedValue1, selectedValue2));
                      //selectedValue1 = '';
                      //selectedValue2 = '';
                      //showBusNumbers = false;
                    });
                  },
                  child: const Text('Clear',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
                Spacer(
                  flex: 1,
                ),
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
                      showBusNumbers = true;
                    });
                  },
                  child: const Text(
                    'Show Buses',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (showBusNumbers)
              for (int i = 0;
                  i < getBusNumber(selectedValue1, selectedValue2).length;
                  i++)
                Container(
                  margin: EdgeInsets.only(left: 3, right: 3, bottom: 3),
                  color: Color.fromARGB(255, 128, 189, 250),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return BusDetails(
                              busNumber: insertionSort(
                                  regionsCoveredList(
                                      getBusNumber(
                                          selectedValue1, selectedValue2),
                                      selectedValue1,
                                      selectedValue2),
                                  getBusNumber(
                                      selectedValue1, selectedValue2))[i],
                              regions: getBusRegions(
                                  insertionSort(
                                      regionsCoveredList(
                                          getBusNumber(
                                              selectedValue1, selectedValue2),
                                          selectedValue1,
                                          selectedValue2),
                                      getBusNumber(
                                          selectedValue1, selectedValue2))[i],
                                  selectedValue1,
                                  selectedValue2),
                            );
                          },
                        ),
                      );
                    },

                    ///han3dl
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
                        Spacer(
                          flex: 1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Bus Number : ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  //t3ala
                                  insertionSort(
                                      regionsCoveredList(
                                          getBusNumber(
                                              selectedValue1, selectedValue2),
                                          selectedValue1,
                                          selectedValue2),
                                      getBusNumber(
                                          selectedValue1, selectedValue2))[i],

                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  "Regions Covered : ",
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  getBusRegions(
                                          insertionSort(
                                              regionsCoveredList(
                                                  getBusNumber(selectedValue1,
                                                      selectedValue2),
                                                  selectedValue1,
                                                  selectedValue2),
                                              getBusNumber(selectedValue1,
                                                  selectedValue2))[i],
                                          selectedValue1,
                                          selectedValue2)
                                      .length
                                      .toString(),
                                  style: TextStyle(
                                      //fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        Text(
                          "Click For \n Details",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  List<String> busesPassByRegion(String region) {
    List<String> buses = [];
    for (int i = 0; i < stationsQuery.length; i++) {
      if (stationsQuery[i].id == region) {
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            buses.add(busNumberItem);
          }
        }
      }
    }
    return buses;
  }

  //hangeb arkam el otobesat mn el firebase
  List<String> getBusNumber(String selectedItem1, String selectedItem2) {
    List<String> busNumber1 = [];
    List<String> busNumber2 = [];
    List<String> busNumber = [];
    bool s1 = false;
    bool s2 = false;
    for (int i = 0; i < stationsQuery.length; i++) {
      if (stationsQuery[i].id == selectedItem1) {
        // Check if 'Bus_Number' field exists and is not null
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber1.add(busNumberItem); // Add each string in the array
          }
        }
        s1 = true;
      } else if (stationsQuery[i].id == selectedItem2) {
        // Check if 'Bus_Number' field exists and is not null
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber2.add(busNumberItem); // Add each string in the array
          }
        }
        s2 = true;
      }
      if (s1 == true && s2 == true) {
        break;
      }
    }
    busNumber = busNumber1.toSet().intersection(busNumber2.toSet()).toList();
    return busNumber;
  }

  List<List<String>> getTwoBuses(String from, String to) {
    List<String> fromList = busesPassByRegion(from);
    List<String> toList = busesPassByRegion(to);
    print("bus1");
    testprint(fromList);
    print("bus2");
    testprint(toList);
    List<String> regionsCoveredBy1 = [];
    List<String> regionsCoveredBy2 = [];
    List<List<String>> twoBusNumbers = [];
    //List<List<String>> commonRegionsCovered = [];

    for (int i = 0; i < fromList.length; i++) {
      regionsCoveredBy1 = getBusRegionsOfBus(fromList[i]);
      print("bus1 regions");

      testprint(regionsCoveredBy1);
      for (int j = 0; j < toList.length; j++) {
        regionsCoveredBy2 = getBusRegionsOfBus(toList[i]);
        print("bus1 regions");
        testprint(regionsCoveredBy2);

        if (commonRegions(regionsCoveredBy1, regionsCoveredBy2).isNotEmpty) {
          //print("returned from common");
          twoBusNumbers.add([fromList[i], toList[j]]);
          //commonRegionsCovered.add(commonRegions(regionsCoveredBy1, regionsCoveredBy2));
          continue;
        }
      }
    }
    print("the two buses");
    testprints(twoBusNumbers);

    return twoBusNumbers;
  }

  List<String> commonRegions<T>(
      List<String> regionsList1, List<String> regionsList2) {
    List<String> x = [];
    for (int i = 0; i < regionsList1.length; i++) {
      for (int j = 0; j < regionsList2.length; j++) {
        if (regionsList1[i] == regionsList2[j]) {
          x.add(regionsList1[i]);
        }
      }
    }
    print("inside the common");
    testprint(x);
    print("ha return");
    return x;
  }

  ///////////////////////////////////////////////////////////////////////////
  List<String> getBusRegionsOfBus(String busNumber) {
    List<String> regions = [];

    for (int i = 0; i < busQuery.length; i++) {
      if (busQuery[i].id == busNumber) {
        if (busQuery[i].get('Regions') != null) {
          for (String busNumberItem in busQuery[i].get('Regions')) {
            regions.add(busNumberItem);
          }
          break;
        }
      }
    }
    //testprints(getBusRegions("n1"));

    return regions;
  }

  //////////////////////////////////////////////////////////////////////////
  List<String> getBusRegions(String busNumber, String from, String to) {
    List<String> regions = [];
    bool fromFlag = false;
    bool toFlag = false;
    //start is the indicator that indicates which station is found first (from or to)
    bool start = false;

    for (int i = 0; i < busQuery.length; i++) {
      if (busQuery[i].id == busNumber) {
        //print("case 0");
        if (busQuery[i].get('Regions') != null) {
          //print("case xxx");
          for (String busNumberItem in busQuery[i].get('Regions')) {
            if (toFlag == true && fromFlag == false) {
              start = true;
            }
            //print("inside loop");
            if (from == busNumberItem) {
              //print("case 1");
              fromFlag = true;
              regions.add(busNumberItem);
              continue;
            } else if (to == busNumberItem) {
              //print("case 2");
              //start = true;
              toFlag = true;
              regions.add(busNumberItem);
              continue;
            }
            if (fromFlag == true && toFlag == true) {
              break;
            } else if (fromFlag || toFlag) {
              regions.add(busNumberItem);
            } else {
              continue;
            }
            /*if (fromFlag && busNumberItem != to) {
              //print("case 3");
              regions.add(busNumberItem);
              continue;
            } else if (toFlag && busNumberItem != from) {
              //print("case 4");
              regions.add(busNumberItem);
              continue;
            }
            if (fromFlag == true && toFlag == true) {
              //print("case 5");
              break;
            }*/
          }
          break;
        }
      }
    }
    //testprints(getBusRegions("n1"));

    return start ? regions.reversed.toList() : regions;
  }

  //hast5dmha b3den kman
  /*int getBusRegionsCovered(String busNumber, String from, String to) {
    int cnt = 0;
    List<String> regions = getBusRegions(busNumber, from, to);
    //testprints(getBusRegions(busNumber));
    //print(getBusRegions(busNumber).length);
    bool fromFlag = false;
    bool toFlag = false;

    for (int i = 0; i < regions.length; i++) {
      if (from == regions[i]) {
        fromFlag = true;
        continue;
      } else if (to == regions[i]) {
        toFlag = true;
        continue;
      }
      if (fromFlag && regions[i] != to) {
        cnt++;
      } else if (toFlag && regions[i] != from) {
        cnt++;

      }
      if (fromFlag == true && toFlag == true) {
        break;
      }
    }
    print("int getregionsCovered:**********************" + cnt.toString());
    return cnt;
  }*/

  List<int> regionsCoveredList(List<String> busNumber, String from, String to) {
    List<int> regionsCovered = [];
    for (int i = 0; i < busNumber.length; i++) {
      regionsCovered.add(getBusRegions(busNumber[i], from, to).length);
    }
    return regionsCovered;
  }

  //list1(getBusNumber) => fyha arkam el busat
  //list2(regionsCoveredList) => fyha 3dd el ma7tat el be3di 3leha kol bus

  void testprint(List<String> x) {
    for (int i = 0; i < x.length; i++) {
      print(x[i]);
    }
  }

  void testprints(List<List<String>> x) {
    for (int i = 0; i < x.length; i++) {
      print(x[i]);
    }
  }

  List<String> insertionSort(List<int> regionsCovered, List<String> BusNumber) {
    //testprint(regionsCovered);

    for (int i = 1; i < regionsCovered.length; i++) {
      int current = regionsCovered[i];
      String currents = BusNumber[i];
      int j = i - 1;

      // Shift elements of list[0..i-1], that are greater than current
      while (j >= 0 && regionsCovered[j] > current) {
        regionsCovered[j + 1] = regionsCovered[j];
        BusNumber[j + 1] = BusNumber[j];
        j--;
      }
      // Insert current element at its correct position
      regionsCovered[j + 1] = current;
      BusNumber[j + 1] = currents;
    }
    //testprint(regionsCovered);
    return BusNumber;
  }
}
