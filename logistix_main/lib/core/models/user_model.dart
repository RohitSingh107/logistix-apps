import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final int phone;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserRequest {
  final int phone;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  UserRequest({
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) => _$UserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
} 