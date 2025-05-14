import 'package:equatable/equatable.dart';
import 'base_model.dart';

class User extends BaseModel {
  final int id;
  final int phone;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  const User({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      profilePicture: json['profile_picture'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': profilePicture,
    };
  }

  @override
  List<Object?> get props => [id, phone, firstName, lastName, profilePicture];
} 