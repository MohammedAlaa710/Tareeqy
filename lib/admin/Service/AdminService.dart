import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addStation(
      String line, String name, int number, GeoPoint latlng) async {
    final DocumentSnapshot doc =
        await _firestore.collection(line).doc(name).get();
    if (doc.exists) {
      throw Exception("Station with this name already exists");
    } else {
      await _firestore.collection(line).doc(name).set({
        'name': name,
        'number': number,
        'latlng': latlng,
      });
    }
  }

  Future<void> updateStation(
      String line, String name, int number, GeoPoint latlng) async {
    final DocumentSnapshot doc =
        await _firestore.collection(line).doc(name).get();
    if (!doc.exists) {
      throw Exception("Station with this name does not exist");
    } else {
      await _firestore.collection(line).doc(name).update({
        'number': number,
        'latlng': latlng,
      });
    }
  }

  Future<void> deleteStation(String line, String name) async {
    await _firestore.collection(line).doc(name).delete();
  }

  Stream<QuerySnapshot> getStations(String line) {
    return _firestore.collection(line).orderBy('number').snapshots();
  }

//////////////////////////////////
  Future<void> addBus(String busNumber, List<String> regions) async {
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(busNumber).get();
    if (busDoc.exists) {
      throw Exception("Bus with this number already exists");
    }

    await _firestore.collection('Bus2').doc(busNumber).set({
      'Stations': regions,
    });

    for (String region in regions) {
      final DocumentSnapshot regionDoc =
          await _firestore.collection('Bus').doc(region).get();
      if (!regionDoc.exists) {
        await _firestore.collection('Bus').doc(region).set({
          'Bus_Number': [busNumber],
        });
      } else {
        await _firestore.collection('Bus').doc(region).update({
          'Bus_Number': FieldValue.arrayUnion([busNumber]),
        });
      }
    }
  }

  Future<void> updateBus(
      String oldBusNumber, String newBusNumber, List<String> newRegions) async {
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(oldBusNumber).get();
    if (!busDoc.exists) {
      throw Exception("Bus with this number does not exist");
    }
    final List<String> currentRegions = List<String>.from(busDoc['Stations']);

    if (oldBusNumber != newBusNumber) {
      await _firestore.collection('Bus2').doc(oldBusNumber).delete();
      await _firestore.collection('Bus2').doc(newBusNumber).set({
        'Stations': newRegions,
      });
    } else {
      await _firestore.collection('Bus2').doc(oldBusNumber).update({
        'Stations': newRegions,
      });
    }

    for (String region in currentRegions) {
      if (!newRegions.contains(region)) {
        await _firestore.collection('Bus').doc(region).update({
          'Bus_Number': FieldValue.arrayRemove([oldBusNumber]),
        });

        final DocumentSnapshot updatedRegionDoc =
            await _firestore.collection('Bus').doc(region).get();
        if (updatedRegionDoc.exists &&
            (updatedRegionDoc['Bus_Number'] as List).isEmpty) {
          await _firestore.collection('Bus').doc(region).delete();
        }
      }
    }

    for (String newRegion in newRegions) {
      if (!currentRegions.contains(newRegion)) {
        final DocumentSnapshot regionDoc =
            await _firestore.collection('Bus').doc(newRegion).get();
        if (!regionDoc.exists) {
          await _firestore.collection('Bus').doc(newRegion).set({
            'Bus_Number': currentRegions.contains(newRegion)
                ? [newBusNumber, ...regionDoc['Bus_Number']]
                : [newBusNumber],
          });
        } else {
          final List<dynamic> busNumbers =
              List<dynamic>.from(regionDoc['Bus_Number']);
          if (!busNumbers.contains(newBusNumber)) {
            if (busNumbers.contains(oldBusNumber)) {
              busNumbers.remove(oldBusNumber);
              busNumbers.add(newBusNumber);
            }
            await _firestore.collection('Bus').doc(newRegion).update({
              'Bus_Number': busNumbers,
            });
          }
        }
      } else {
        final DocumentSnapshot regionDoc =
            await _firestore.collection('Bus').doc(newRegion).get();
        final List<dynamic> busNumbers =
            List<dynamic>.from(regionDoc['Bus_Number']);
        if (!busNumbers.contains(newBusNumber)) {
          if (busNumbers.contains(oldBusNumber)) {
            busNumbers.remove(oldBusNumber);
            busNumbers.add(newBusNumber);
          }
          await _firestore.collection('Bus').doc(newRegion).update({
            'Bus_Number': busNumbers,
          });
        }
      }
    }
  }

////////////////////////////////////////////////////////////////////////
  Future<void> addDriver() async {}
////////////////////////////////////////////////////////////////////////////
  Future<void> removeBus(String busNumber) async {
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(busNumber).get();
    if (!busDoc.exists) {
      throw Exception("Bus with this number does not exist");
    }
    final List<String> currentRegions = List<String>.from(busDoc['Stations']);

    await _firestore.collection('Bus2').doc(busNumber).delete();

    for (String region in currentRegions) {
      await _firestore.collection('Bus').doc(region).update({
        'Bus_Number': FieldValue.arrayRemove([busNumber]),
      });
    }
  }

  Stream<QuerySnapshot> getAllBuses() {
    return _firestore.collection('Bus2').snapshots();
  }

  List<DocumentSnapshot> filterBusesByNumber(
      String searchValue, List<DocumentSnapshot> buses) {
    return buses
        .where((bus) => bus.id.toLowerCase().contains(searchValue))
        .toList();
  }
}
