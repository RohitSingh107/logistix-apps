import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'driver_model.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  final User user;
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'is_available')
  final bool isAvailable;
  @JsonKey(name: 'average_rating')
  final double averageRating;
  @JsonKey(name: 'total_earnings')
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
  @JsonKey(name: 'license_number')
  final String licenseNumber;
  @JsonKey(name: 'is_available')
  final bool isAvailable;

  DriverRequest({
    required this.licenseNumber,
    this.isAvailable = true,
  });

  factory DriverRequest.fromJson(Map<String, dynamic> json) => _$DriverRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DriverRequestToJson(this);
} 