/**
 * user_repository.dart - User Repository Interface
 * 
 * Purpose:
 * - Defines the contract for user data operations
 * - Provides abstraction layer for user profile management
 * - Ensures consistent user data access patterns across the application
 * 
 * Key Logic:
 * - Abstract repository interface following repository pattern
 * - Defines methods for retrieving current user profile
 * - Provides user profile update functionality with optional parameters
 * - Returns User model instances for type safety
 * - Uses Future-based async operations for all data access
 * - Supports partial profile updates (nullable parameters)
 */

import '../models/user_model.dart';

abstract class UserRepository {
  /// Get current user profile
  Future<User> getCurrentUser();
  
  /// Update user profile
  Future<User> updateUserProfile({
    String? firstName,
    String? lastName,
    String? profilePicture,
  });
  
  /// Update FCM token for push notifications
  Future<User> updateFcmToken(String fcmToken);
} 