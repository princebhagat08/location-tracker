class UserLocation {
  final double latitude;
  final double longitude;
  final String? city;
  final String? state;
  final String? pincode;
  final String? fullAddress;
  final DateTime timestamp;

  UserLocation({
    required this.latitude,
    required this.longitude,
    this.city,
    this.state,
    this.pincode,
    this.fullAddress,
    required this.timestamp,
  });


  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      fullAddress: json['fullAddress'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'pincode': pincode,
      'fullAddress': fullAddress,
      'timestamp': timestamp.toIso8601String(),
    };
  }


  UserLocation copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? pincode,
    String? fullAddress,
    DateTime? timestamp,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      fullAddress: fullAddress ?? this.fullAddress,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
