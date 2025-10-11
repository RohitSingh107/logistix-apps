/// stop_point.dart - Stop Point Model
/// 
/// Purpose:
/// - Represents a stop point in a booking route
/// - Handles waypoint information including location, address, and contact details
/// - Supports different stop types (WAYPOINT, PICKUP, DROPOFF)
/// 
/// Key Logic:
/// - Parses location data from SRID format
/// - Provides helper methods for address formatting
/// - Handles contact information for each stop
/// - Supports stop ordering and type classification

class StopPoint {
  final int id;
  final String location; // SRID=4326;POINT (lon lat) format
  final String address;
  final int stopOrder;
  final String stopType;
  final String contactName;
  final String contactPhone;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  StopPoint({
    required this.id,
    required this.location,
    required this.address,
    required this.stopOrder,
    required this.stopType,
    required this.contactName,
    required this.contactPhone,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StopPoint.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] as int? ?? 0;
      final location = json['location'] as String? ?? '';
      final address = json['address'] as String? ?? '';
      final stopOrder = json['stop_order'] as int? ?? 0;
      final stopType = json['stop_type'] as String? ?? 'WAYPOINT';
      final contactName = json['contact_name'] as String? ?? '';
      final contactPhone = json['contact_phone'] as String? ?? '';
      final notes = json['notes'] as String? ?? '';
      final createdAt = DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String());
      final updatedAt = DateTime.parse(json['updated_at'] as String? ?? DateTime.now().toIso8601String());
      
      return StopPoint(
        id: id,
        location: location,
        address: address,
        stopOrder: stopOrder,
        stopType: stopType,
        contactName: contactName,
        contactPhone: contactPhone,
        notes: notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      // Return a default stop point instead of rethrowing
      return StopPoint(
        id: 0,
        location: 'POINT (0 0)',
        address: 'Unknown Address',
        stopOrder: 0,
        stopType: 'WAYPOINT',
        contactName: '',
        contactPhone: '',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Helper method to extract coordinates from SRID format
  Map<String, double> get coordinates {
    try {
      // Parse SRID=4326;POINT (lon lat) format
      final pointMatch = RegExp(r'POINT \(([^)]+)\)').firstMatch(location);
      if (pointMatch != null) {
        final coords = pointMatch.group(1)!.split(' ');
        return {
          'longitude': double.parse(coords[0]),
          'latitude': double.parse(coords[1]),
        };
      }
    } catch (e) {
      print('Error parsing coordinates: $e');
    }
    return {'longitude': 0.0, 'latitude': 0.0};
  }

  // Helper method to get short address
  String get shortAddress {
    if (address.isEmpty) return 'Unknown';
    final parts = address.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : address;
  }

  // Helper method to check if this is a waypoint
  bool get isWaypoint => stopType == 'WAYPOINT';
  bool get isPickup => stopType == 'PICKUP';
  bool get isDropoff => stopType == 'DROPOFF';
}
