import '../models/user_model.dart';

abstract class UserRepository {
  /// Get current user profile
  Future<User> getCurrentUser();
  
  /// Update user profile
  Future<User> updateUserProfile({
    String? phone,
    String? firstName,
    String? lastName,
    String? profilePicture,
  });
} 