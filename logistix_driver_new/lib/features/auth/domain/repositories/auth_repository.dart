/**
 * auth_repository.dart - Authentication Repository Interface
 * 
 * Purpose:
 * - Defines the contract for authentication operations
 * - Provides abstraction layer for auth-related data operations
 * - Ensures consistent authentication patterns across the application
 * 
 * Key Logic:
 * - Abstract repository interface following domain-driven design
 * - OTP-based authentication flow (request OTP, verify OTP)
 * - Token management operations (save, refresh, logout)
 * - Returns structured data for login/registration flow
 * - Handles both new user registration and existing user login
 * - Provides token refresh capability for session management
 * - Clear method signatures with detailed documentation
 * - Follows async/await pattern for all operations
 */

abstract class AuthRepository {
  /// Request OTP for login/registration
  /// 
  /// [phone] - User's phone number
  /// Returns a Future that completes when the OTP is sent
  Future<void> requestOtp(String phone);
  
  /// Verify OTP and handle login/registration
  /// 
  /// [phone] - User's phone number
  /// [otp] - OTP received by user
  /// Returns a Map containing:
  /// - is_new_user: bool
  /// - user: Map<String, dynamic>
  /// - tokens: Map<String, String>
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp);
  
  /// Save authentication tokens
  /// 
  /// [accessToken] - JWT access token
  /// [refreshToken] - JWT refresh token
  Future<void> saveTokens(String accessToken, String refreshToken);
  
  /// Refresh JWT token
  /// 
  /// [refreshToken] - Current refresh token
  /// Returns a new access token
  Future<String> refreshToken(String refreshToken);
  
  /// Logout user
  /// Clears all auth tokens and user data
  Future<void> logout();
} 