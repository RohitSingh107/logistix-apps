abstract class AuthRepository {
  /// Request OTP for Phone Number Verification
  Future<void> requestOtp(String phone);
  
  /// Verify OTP for Phone Number Verification
  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, String sessionId);


  // Request OTP for Login
  Future<void> requestOtpForLogin(String phone);

  // Verify OTP for Login
  Future<Map<String, dynamic>> verifyOtpForLogin(String phone, String otp, String sessionId);
  
  /// Register a new user (signup flow)
  Future<void> register(String phone, String firstName, String lastName);
  
  /// Logout the current user
  Future<void> logout();
} 