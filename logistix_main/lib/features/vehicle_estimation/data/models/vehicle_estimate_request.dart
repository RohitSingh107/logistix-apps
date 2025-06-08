class VehicleEstimateRequest {
  final LocationData pickupLocation;
  final LocationData dropoffLocation;

  VehicleEstimateRequest({
    required this.pickupLocation,
    required this.dropoffLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'pickup_location': pickupLocation.toJson(),
      'dropoff_location': dropoffLocation.toJson(),
    };
  }
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
} 