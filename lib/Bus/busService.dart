import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusService {
  List<String> stations = [];
  List<QueryDocumentSnapshot> stationsQuery = [];
  List<String> buses = [];
  List<String> commonRegions = [];
  List<String> twoBusesForDetails = [];
  List<String> regionsBus1 = [];
  List<String> regionsBus2 = [];
  int numberOfeBuses = 1;
  List<String> commonRegionsDetails = [];
  List<QueryDocumentSnapshot> busQuery = [];
  static final BusService _instance = BusService._();
  Map<int, List<String>> BusesMap = {};
  factory BusService() {
    return _instance;
  }

  BusService._();

  List<String> get _stations => stations;

  Future<void> getStations() async {
    try {
      QuerySnapshot bus =
          await FirebaseFirestore.instance.collection('Bus').get();
      stationsQuery.addAll(bus.docs);
      stations = bus.docs.map((doc) => doc.id).toList();
    } catch (error) {
      print("Error getting Bus data: $error");
    }
  }

  Future<void> getBuses() async {
    try {
      QuerySnapshot bus =
          await FirebaseFirestore.instance.collection('Bus2').get();
      busQuery.addAll(bus.docs);
      buses = bus.docs.map((doc) => doc.id).toList();
    } catch (error) {
      print("Error getting Bus2 data: $error");
    }
  }

////////////////////////////////////////////////////////////////////////////
  List<String> getAllBusStations(String busNumber) {
    List<String> busStations = [];

    for (int i = 0; i < busQuery.length; i++) {
      if (busQuery[i].id == busNumber) {
        if (busQuery[i].get('Stations') != null) {
          for (String busStation in busQuery[i].get('Stations')) {
            busStations.add(busStation);
          }
        }
        break;
      }
    }

    return busStations;
  }

  List<String> getMetroStations(String busNumber) {
    List<String> metroStations = [];

    for (int i = 0; i < busQuery.length; i++) {
      if (busQuery[i].id == busNumber) {
        final data = busQuery[i].data() as Map<String, dynamic>;
        if (data.containsKey('Nearby_Metros') == true) {
          for (String busStation in busQuery[i].get('Nearby_Metros')) {
            metroStations.add(busStation);
          }
        }
        break;
      }
    }

    return metroStations;
  }

////////////////////////////////////////////////////////////////////////////
  Map<int, List<String>> getBusNumber(
      String selectedItem1, String selectedItem2) {
    List<String> busNumber1 = [];
    List<String> busNumber2 = [];

    bool s1 = false;
    bool s2 = false;
    for (int i = 0; i < stationsQuery.length; i++) {
      if (stationsQuery[i].id == selectedItem1) {
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber1.add(busNumberItem);
          }
        }
        s1 = true;
      } else if (stationsQuery[i].id == selectedItem2) {
        if (stationsQuery[i].get('Bus_Number') != null) {
          for (String busNumberItem in stationsQuery[i].get('Bus_Number')) {
            busNumber2.add(busNumberItem);
          }
        }
        s2 = true;
      }
      if (s1 && s2) {
        break;
      }
    }
    BusesMap[1] = busNumber1.toSet().intersection(busNumber2.toSet()).toList();

    BusesMap[2] = getTwoBuses(selectedItem1, selectedItem2, BusesMap[1]);

    return BusesMap;
  }

  List<String> getTwoBuses(String from, String to, List<String>? directbuses) {
    List<String> fromBuses = busesPassByRegion(from);
    List<String> toBuses = busesPassByRegion(to);
    List<String> twoBuses = [];
    for (String fromBus in fromBuses) {
      if (directbuses != null && directbuses.contains(fromBus)) {
        continue;
      }
      List<String> fromBusRegions = getBusRegionsOfBus(fromBus);
      for (String toBus in toBuses) {
        if (directbuses != null && directbuses.contains(toBus)) {
          continue;
        }

        if (fromBus != toBus) {
          List<String> toBusRegions = getBusRegionsOfBus(toBus);
          List<String> commonRegions = fromBusRegions
              .toSet()
              .intersection(toBusRegions.toSet())
              .toList();
          if (commonRegions.isNotEmpty) {
            twoBuses.add('$fromBus , $toBus');
            twoBusesForDetails.add(fromBus);
            twoBusesForDetails.add(toBus);
          }
        }
      }
    }

    return twoBuses;
  }

  List<String> getRegionsOfTwoBuses(
      String bus1, String bus2, String from, String to) {
    List<String> regions = [];

    Set<String> commonRegions = getBusRegionsOfBus(bus1)
        .toSet()
        .intersection(getBusRegionsOfBus(bus2).toSet());

    commonRegionsDetails.clear();
    commonRegionsDetails = commonRegions.toList();

    regionsBus1.clear();
    regionsBus1 = getBusRegions(bus1, from, commonRegionsDetails[0]);

    regionsBus2.clear();
    regionsBus2 = getBusRegions(bus2, commonRegionsDetails[0], to);

    commonRegionsDetails.forEach((element) => regionsBus1.remove(element));
    commonRegionsDetails.forEach((element) => regionsBus2.remove(element));

    regions.addAll(regionsBus1);
    regions.removeLast();
    regions.addAll(regionsBus2);

    return regions;
  }

////////////////////////////////////////////////////////////////////////////////////////////
  List<String> busesPassByRegion(String region) {
    List<String> buses = [];
    for (var doc in stationsQuery) {
      if (doc.id == region) {
        if (doc.get('Bus_Number') != null) {
          buses.addAll(List<String>.from(doc.get('Bus_Number')));
        }
      }
    }
    return buses;
  }

  List<String> getBusRegionsOfBus(String busNumber) {
    List<String> regions = [];
    for (var doc in busQuery) {
      if (doc.id == busNumber) {
        if (doc.get('Stations') != null) {
          regions.addAll(List<String>.from(doc.get('Stations')));
        }
        break;
      }
    }
    return regions;
  }

//////////////////////////////////////////////////////////////////////////////
  List<String> getBusRegions(String busNumber, String from, String to) {
    List<String> regions = [];
    bool fromFlag = false;
    bool toFlag = false;
    bool start = false;

    for (int i = 0; i < busQuery.length; i++) {
      if (busQuery[i].id == busNumber) {
        if (busQuery[i].get('Stations') != null) {
          for (String busNumberItem in busQuery[i].get('Stations')) {
            if (toFlag && !fromFlag) {
              start = true;
            }
            if (from == busNumberItem) {
              fromFlag = true;
              regions.add(busNumberItem);
              continue;
            } else if (to == busNumberItem) {
              toFlag = true;
              regions.add(busNumberItem);
              continue;
            }
            if (fromFlag && toFlag) {
              break;
            } else if (fromFlag || toFlag) {
              regions.add(busNumberItem);
            }
          }
          break;
        }
      }
    }
    return start ? regions.reversed.toList() : regions;
  }

  List<int> regionsCoveredList(List<String> busNumber, String from, String to) {
    List<int> regionsCovered = [];
    for (int i = 0; i < busNumber.length; i++) {
      regionsCovered.add(getBusRegions(busNumber[i], from, to).length);
    }
    return regionsCovered;
  }

  List<String> insertionSort(List<int> regionsCovered, List<String> BusNumber) {
    for (int i = 1; i < regionsCovered.length; i++) {
      int current = regionsCovered[i];
      String currents = BusNumber[i];
      int j = i - 1;
      while (j >= 0 && regionsCovered[j] > current) {
        regionsCovered[j + 1] = regionsCovered[j];
        BusNumber[j + 1] = BusNumber[j];
        j--;
      }
      regionsCovered[j + 1] = current;
      BusNumber[j + 1] = currents;
    }
    return BusNumber;
  }

  Future<List<String>> searchBusNumbers(String query) async {
    List<String> busNumbers = [];
    for (var doc in busQuery) {
      if (doc.id.contains(query)) {
        busNumbers.add(doc.id);
      }
    }
    return busNumbers;
  }

  Future<bool> checkIfBusesAvailable(String busNumber) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Drivers')
        .where('busId', isEqualTo: busNumber)
        .where('work', isEqualTo: true)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  void showNoBusesAvailableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.directions_bus,
                color: Color(0xFFB31312),
              ),
              SizedBox(width: 10),
              Text(
                'No Buses Available',
                style: TextStyle(
                  color: Color(0xFFB31312),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF073042),
                size: 38,
              ),
              SizedBox(height: 10),
              Text(
                'Currently, there are no buses available to track. Please check back later.',
                style: TextStyle(
                  color: Color(0xFF073042),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 2,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
