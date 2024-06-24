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

//////////////////////////////////      BUS Services
  Future<void> addBus(String busNumber, List<String> regions) async {
    // Validate that the bus number doesn't already exist in Bus2
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(busNumber).get();
    if (busDoc.exists) {
      throw Exception("Bus with this number already exists");
    }

    // Add the bus to Bus2 collection with the document ID as busNumber
    await _firestore.collection('Bus2').doc(busNumber).set({
      'Stations': regions,
    });

    // Update regions in the Bus collection
    for (String region in regions) {
      final DocumentSnapshot regionDoc =
          await _firestore.collection('Bus').doc(region).get();
      if (!regionDoc.exists) {
        // If region document doesn't exist, create a new one
        await _firestore.collection('Bus').doc(region).set({
          'Bus_Number': [
            busNumber
          ], // Initialize Bus_Number array with the busNumber
        });
      } else {
        // If region document already exists, update it to add busNumber to Bus_Number array
        await _firestore.collection('Bus').doc(region).update({
          'Bus_Number': FieldValue.arrayUnion([busNumber]),
        });
      }
    }
  }

  Future<void> updateBus(
      String oldBusNumber, String newBusNumber, List<String> newRegions) async {
    // Get current regions of the bus
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(oldBusNumber).get();
    if (!busDoc.exists) {
      throw Exception("Bus with this number does not exist");
    }
    final List<String> currentRegions = List<String>.from(busDoc['Stations']);

    // Update the bus number in Bus2 collection (delete then add operation)
    if (oldBusNumber != newBusNumber) {
      await _firestore.collection('Bus2').doc(oldBusNumber).delete();
      await _firestore.collection('Bus2').doc(newBusNumber).set({
        'Stations': newRegions,
      });
    } else {
      // Just update the regions if the bus number remains the same
      await _firestore.collection('Bus2').doc(oldBusNumber).update({
        'Stations': newRegions,
      });
    }

    for (String region in currentRegions) {
      if (!newRegions.contains(region)) {
        // Remove the old bus number from the Bus_Number array in the old region document
        await _firestore.collection('Bus').doc(region).update({
          'Bus_Number': FieldValue.arrayRemove([oldBusNumber]),
        });

        // Check if the document is empty after removing the bus number
        final DocumentSnapshot updatedRegionDoc =
            await _firestore.collection('Bus').doc(region).get();
        if (updatedRegionDoc.exists &&
            (updatedRegionDoc['Bus_Number'] as List).isEmpty) {
          await _firestore.collection('Bus').doc(region).delete();
        }
      }
    }

    // Update the Bus collection for new regions
    for (String newRegion in newRegions) {
      if (!currentRegions.contains(newRegion)) {
        final DocumentSnapshot regionDoc =
            await _firestore.collection('Bus').doc(newRegion).get();
        if (!regionDoc.exists) {
          print("insidedddddd if");
          // If the region document doesn't exist, create a new one
          await _firestore.collection('Bus').doc(newRegion).set({
            'Bus_Number': currentRegions.contains(newRegion)
                ? [newBusNumber, ...regionDoc['Bus_Number']]
                : [newBusNumber],
          });
        } else {
          print("insidedddddd else");
          // If the region document exists, update it with the new bus number
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
    // Get current regions of the bus
    final DocumentSnapshot busDoc =
        await _firestore.collection('Bus2').doc(busNumber).get();
    if (!busDoc.exists) {
      throw Exception("Bus with this number does not exist");
    }
    final List<String> currentRegions = List<String>.from(busDoc['Stations']);

    // Remove the bus from Bus2 collection
    await _firestore.collection('Bus2').doc(busNumber).delete();

    // Update regions in the Bus collection
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
      String value, List<DocumentSnapshot> buses) {
    List<DocumentSnapshot> filteredBuses = [];
    for (var bus in buses) {
      if (bus.id.contains(value)) {
        filteredBuses.add(bus);
      }
    }
    return filteredBuses;
  }
}
