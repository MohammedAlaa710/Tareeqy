import 'package:location/location.dart';

class MyLocation {
  Location location = Location();

  Future<bool> caheckAndRqstLocService() async {
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      return serviceEnabled;
    }
    return true;
  }

  Future<bool> caheckAndRqstLocPerm() async {
    var permStatus = await location.hasPermission();
    if (permStatus == PermissionStatus.deniedForever) {
      return false;
    }

    if (permStatus == PermissionStatus.denied) {
      permStatus = await location.requestPermission();
      return permStatus == PermissionStatus.granted;
    }
    return true;
  }
}
