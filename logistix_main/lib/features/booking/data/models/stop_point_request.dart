/// stop_point_request.dart - Stop Point Request Model for Booking Creation
/// 
/// Purpose:
/// - Represents a stop point request when creating a new booking
/// - Handles latitude, longitude, address, and stop order for API submission
/// - Supports multiple stops in a single booking request
/// 
/// Key Logic:
/// - Simple model for API request payload
/// - Supports stop ordering for multi-stop routes
/// - Handles coordinate and address information

class StopPointRequest {
  final double latitude;
  final double longitude;
  final String address;
  final int stopOrder;

  StopPointRequest({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.stopOrder,
  });

  factory StopPointRequest.fromJson(Map<String, dynamic> json) {
    return StopPointRequest(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      stopOrder: json['stop_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'stop_order': stopOrder,
    };
  }
}
