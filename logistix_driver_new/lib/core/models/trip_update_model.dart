/// trip_update_model.dart - Trip Update Model
/// 
/// Purpose:
/// - Represents a trip update/status change
/// - Contains update message and metadata
/// - Used for trip status tracking and notifications
/// 
/// Key Logic:
/// - Trip update creation and management
/// - Update message and timestamp tracking
/// - Creator information for updates
/// - Trip status change notifications
library;

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'trip_update_model.g.dart';

@JsonSerializable()
class TripUpdate extends BaseModel {
  final int id;
  final int trip;
  @JsonKey(name: 'update_message')
  final String updateMessage;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  @JsonKey(name: 'created_by_phone')
  final String? createdByPhone;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TripUpdate({
    required this.id,
    required this.trip,
    required this.updateMessage,
    this.createdBy,
    this.createdByPhone,
    required this.createdAt,
  });

  factory TripUpdate.fromJson(Map<String, dynamic> json) => _$TripUpdateFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TripUpdateToJson(this);

  /// Create a copy of this trip update with updated fields
  TripUpdate copyWith({
    int? id,
    int? trip,
    String? updateMessage,
    int? createdBy,
    String? createdByPhone,
    DateTime? createdAt,
  }) {
    return TripUpdate(
      id: id ?? this.id,
      trip: trip ?? this.trip,
      updateMessage: updateMessage ?? this.updateMessage,
      createdBy: createdBy ?? this.createdBy,
      createdByPhone: createdByPhone ?? this.createdByPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted creation time
  String get formattedCreatedAt {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} at ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Get creation time in 12-hour format
  String get createdAt12Hour {
    final hour = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${createdAt.minute.toString().padLeft(2, '0')} $period';
  }
}
