import 'package:equatable/equatable.dart';

class VehicleTypeModel extends Equatable {
  final int id;
  final String title;
  final double baseFare;
  final double baseDistance;
  final double capacity;
  final double dimensionHeight;
  final double dimensionWeight;
  final double dimensionDepth;
  final String dimensionUnit;

  const VehicleTypeModel({
    required this.id,
    required this.title,
    required this.baseFare,
    required this.baseDistance,
    required this.capacity,
    required this.dimensionHeight,
    required this.dimensionWeight,
    required this.dimensionDepth,
    required this.dimensionUnit,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'] as int,
      title: json['title'] as String,
      baseFare: (json['base_fare'] as num).toDouble(),
      baseDistance: (json['base_distance'] as num).toDouble(),
      capacity: (json['capacity'] as num).toDouble(),
      dimensionHeight: (json['dimension_height'] as num).toDouble(),
      dimensionWeight: (json['dimension_weight'] as num).toDouble(),
      dimensionDepth: (json['dimension_depth'] as num).toDouble(),
      dimensionUnit: json['dimension_unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'base_fare': baseFare,
      'base_distance': baseDistance,
      'capacity': capacity,
      'dimension_height': dimensionHeight,
      'dimension_weight': dimensionWeight,
      'dimension_depth': dimensionDepth,
      'dimension_unit': dimensionUnit,
    };
  }

  VehicleTypeModel copyWith({
    int? id,
    String? title,
    double? baseFare,
    double? baseDistance,
    double? capacity,
    double? dimensionHeight,
    double? dimensionWeight,
    double? dimensionDepth,
    String? dimensionUnit,
  }) {
    return VehicleTypeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      baseFare: baseFare ?? this.baseFare,
      baseDistance: baseDistance ?? this.baseDistance,
      capacity: capacity ?? this.capacity,
      dimensionHeight: dimensionHeight ?? this.dimensionHeight,
      dimensionWeight: dimensionWeight ?? this.dimensionWeight,
      dimensionDepth: dimensionDepth ?? this.dimensionDepth,
      dimensionUnit: dimensionUnit ?? this.dimensionUnit,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        baseFare,
        baseDistance,
        capacity,
        dimensionHeight,
        dimensionWeight,
        dimensionDepth,
        dimensionUnit,
      ];
} 