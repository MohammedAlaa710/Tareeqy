import 'package:cloud_firestore/cloud_firestore.dart';

class BusService {
  List<String> stations = [];
  List<QueryDocumentSnapshot> stationsQuery = [];
  List<String> buses = [];
  List<QueryDocumentSnapshot> busQuery = [];
  static final BusService _instance = BusService._(); // Singleton instance

  factory BusService() {
    return _instance;
  }

  BusService._(); // Private constructor for singleton

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
        if (busQuery[i].get('Nearby_Metros') != null) {
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
  List<String> getBusNumber(String selectedItem1, String selectedItem2) {
    List<String> busNumber1 = [];
    List<String> busNumber2 = [];
    List<String> busNumber = [];
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
    busNumber = busNumber1.toSet().intersection(busNumber2.toSet()).toList();
    return busNumber;
  }

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
}
