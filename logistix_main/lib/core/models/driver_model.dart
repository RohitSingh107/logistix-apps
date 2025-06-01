import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  final User user;
  final String licenseNumber;
  final bool isAvailable;
  final double averageRating;
  final double totalEarnings;

  Driver({
    required this.id,
    required this.user,
    required this.licenseNumber,
    required this.isAvailable,
    required this.averageRating,
    required this.totalEarnings,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);
}

@JsonSerializable()
class DriverRequest {
  final String licenseNumber;
  final bool isAvailable;

  DriverRequest({
    required this.licenseNumber,
    this.isAvailable = true,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) => _$DriverRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverRequestToJson(this);
} 