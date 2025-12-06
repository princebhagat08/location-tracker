import 'package:geolocator/geolocator.dart';

class LocationService {

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }


  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }


  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }


  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }


  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }


  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }


  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
