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