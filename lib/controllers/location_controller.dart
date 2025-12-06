import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_location.dart';
import '../core/services/location_service.dart';
import '../core/services/geocoding_service.dart';
import '../core/constants/app_constants.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();
  final GeocodingService _geocodingService = GeocodingService();

  // Observable variables
  final Rx<UserLocation?> currentLocation = Rx<UserLocation?>(null);
  final RxList<UserLocation> locationHistory = <UserLocation>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString permissionStatus = 'unknown'.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    initializeLocation();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  // Initialize location tracking
  Future<void> initializeLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Check if location service is enabled
      bool serviceEnabled = await _locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled';
        permissionStatus.value = 'service_disabled';
        isLoading.value = false;
        return;
      }

      // Check permission
      LocationPermission permission = await _locationService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await _locationService.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permission permanently denied';
        permissionStatus.value = 'denied_forever';
        hasPermission.value = false;
        isLoading.value = false;
        return;
      }

      if (permission == LocationPermission.denied) {
        errorMessage.value = 'Location permission denied';
        permissionStatus.value = 'denied';
        hasPermission.value = false;
        isLoading.value = false;
        return;
      }

      hasPermission.value = true;
      permissionStatus.value = 'granted';

      // Get initial position
      await updateCurrentLocation();

      // Start listening to position updates
      startLocationUpdates();

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error initializing location: $e';
      isLoading.value = false;
    }
  }

  // Update current location
  Future<void> updateCurrentLocation() async {
    try {
      Position position = await _locationService.getCurrentPosition();

      // Fetch address from coordinates
      final addressData = await _geocodingService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final location = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: addressData['city'],
        state: addressData['state'],
        pincode: addressData['pincode'],
        fullAddress: addressData['fullAddress'],
        timestamp: DateTime.now(),
      );

      currentLocation.value = location;

      // Add to history only if location changed significantly
      if (locationHistory.isEmpty) {
        locationHistory.insert(0, location);
      } else if (_hasLocationChangedSignificantly(
        locationHistory.first,
        location,
      )) {
        locationHistory.insert(0, location);
      }
    } catch (e) {
      errorMessage.value = 'Error updating location: $e';
    }
  }

  // Start listening to location updates
  void startLocationUpdates() {
    _positionStreamSubscription = _locationService.getPositionStream().listen(
      (Position position) async {
        try {
          // Fetch address from coordinates
          final addressData = await _geocodingService.getAddressFromCoordinates(
            position.latitude,
            position.longitude,
          );

          final location = UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            city: addressData['city'],
            state: addressData['state'],
            pincode: addressData['pincode'],
            fullAddress: addressData['fullAddress'],
            timestamp: DateTime.now(),
          );

          currentLocation.value = location;

          // Add to history (avoid duplicates if location hasn't changed much)
          if (locationHistory.isEmpty) {
            locationHistory.insert(0, location);
          } else if (_hasLocationChangedSignificantly(
            locationHistory.first,
            location,
          )) {
            locationHistory.insert(0, location);
          }
        } catch (e) {
          errorMessage.value = 'Error in location stream: $e';
        }
      },
      onError: (error) {
        errorMessage.value = 'Location stream error: $error';
      },
    );
  }

  // Check if location has changed significantly
  bool _hasLocationChangedSignificantly(UserLocation old, UserLocation newLoc) {
    double distance = Geolocator.distanceBetween(
      old.latitude,
      old.longitude,
      newLoc.latitude,
      newLoc.longitude,
    );
    return distance > AppConstants.minimumDistanceForHistoryMeters;
  }

  // Stop location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
  }

  // Request permission again
  Future<void> requestPermission() async {
    await initializeLocation();
  }

  // Open app settings
  Future<void> openSettings() async {
    await _locationService.openAppSettings();
  }


  void clearHistory() {
    locationHistory.clear();
  }
}
