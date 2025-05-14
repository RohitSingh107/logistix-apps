class ApiEndpoints {
  // Auth endpoints
  static const String requestOtp = '/api/users/request-otp/';
  static const String verifyOtp = '/api/users/verify-otp/';
  static const String requestOtpForLogin = '/api/users/login/request-otp/';
  static const String verifyOtpForLogin = '/api/users/login/verify-otp/';
  static const String register = '/api/users/register/';
  static const String refreshToken = '/api/users/token/refresh/';
  static const String userProfile = '/api/users/profile/';
  static const String driverProfile = '/api/users/driver/profile/';

  // Booking endpoints
  static const String createBooking = '/api/booking/create/';
  static const String acceptBooking = '/api/booking/accept/';

  // Trip endpoints
  static String tripDetail(int tripId) => '/api/trip/detail/$tripId/';
  static String updateTrip(int tripId) => '/api/trip/update/$tripId/';

  // Payment endpoints
  static const String walletBalance = '/api/payments/wallet/balance/';
  static const String walletTransactions = '/api/payments/wallet/transactions/';

  // Strategy endpoints
  static const String vehicleEstimates = '/api/strategy/vehicle-estimates/';
} 