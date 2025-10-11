/// stop_point_model.dart - Stop Point Model
/// 
/// Purpose:
/// - Represents a stop point in a trip
/// - Contains location, address, and stop details
/// - Used for multi-stop trip management
/// 
/// Key Logic:
/// - Stop point creation and management
/// - Location and address information
/// - Stop order and type management
/// - Contact information for stop points
library;

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'stop_point_model.g.dart';

enum StopType {
  @JsonValue('PICKUP')
  pickup,
  @JsonValue('DROPOFF')
  dropoff,
  @JsonValue('WAYPOINT')
  waypoint,
}

@JsonSerializable()
class StopPoint extends BaseModel {
  final int id;
  final String location;
  final String address;
  @JsonKey(name: 'stop_order')
  final int stopOrder;
  @JsonKey(name: 'stop_type')
  final StopType stopType;
  @JsonKey(name: 'contact_name')
  final String? contactName;
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const StopPoint({
    required this.id,
    required this.location,
    required this.address,
    required this.stopOrder,
    required this.stopType,
    this.contactName,
    this.contactPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StopPoint.fromJson(Map<String, dynamic> json) => _$StopPointFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StopPointToJson(this);

  /// Create a copy of this stop point with updated fields
  StopPoint copyWith({
    int? id,
    String? location,
    String? address,
    int? stopOrder,
    StopType? stopType,
    String? contactName,
    String? contactPhone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StopPoint(
      id: id ?? this.id,
      location: location ?? this.location,
      address: address ?? this.address,
      stopOrder: stopOrder ?? this.stopOrder,
      stopType: stopType ?? this.stopType,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get stop type display text
  String get stopTypeText {
    switch (stopType) {
      case StopType.pickup:
        return 'Pickup';
      case StopType.dropoff:
        return 'Dropoff';
      case StopType.waypoint:
        return 'Waypoint';
    }
  }

  /// Parse coordinates from location string
  Map<String, double>? get coordinates {
    try {
      // Parse "SRID=4326;POINT (longitude latitude)" format
      final regex = RegExp(r'POINT \(([0-9.-]+) ([0-9.-]+)\)');
      final match = regex.firstMatch(location);
      if (match != null) {
        return {
          'longitude': double.parse(match.group(1)!),
          'latitude': double.parse(match.group(2)!),
        };
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  /// Get formatted coordinates
  String get formattedCoordinates {
    final coords = coordinates;
    if (coords != null) {
      return '${coords['latitude']!.toStringAsFixed(6)}, ${coords['longitude']!.toStringAsFixed(6)}';
    }
    return 'N/A';
  }
}
