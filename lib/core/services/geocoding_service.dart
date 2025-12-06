import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  // Using Nominatim (OpenStreetMap) - Free, no API key required
  static const String _nominatimBaseUrl =
      'https://nominatim.openstreetmap.org/reverse';


  Future<Map<String, String?>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl?format=json&lat=$latitude&lon=$longitude&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterLocationTracker/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['address'] != null) {
          final address = data['address'];


          String? city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['municipality'] ??
              address['county'];

          String? state = address['state'] ??
              address['state_district'] ??
              address['region'];

          String? pincode = address['postcode'];

          String? fullAddress = data['display_name'];

          return {
            'city': city,
            'state': state,
            'pincode': pincode,
            'fullAddress': fullAddress,
          };
        } else {

          return {
            'city': 'Unknown',
            'state': 'Unknown',
            'pincode': null,
            'fullAddress': 'Location: $latitude, $longitude',
          };
        }
      } else {

        return {
          'city': 'Unknown',
          'state': 'Unknown',
          'pincode': null,
          'fullAddress': 'Location: $latitude, $longitude',
        };
      }
    } catch (e) {

      print('Geocoding error: $e');
      return {
        'city': 'Unknown',
        'state': 'Unknown',
        'pincode': null,
        'fullAddress': 'Location: $latitude, $longitude',
      };
    }
  }
}
