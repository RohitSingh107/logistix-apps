/// api_endpoints.dart - API Endpoint Constants
/// 
/// Purpose:
/// - Centralized management of all API endpoint URLs
/// - Provides consistent endpoint naming and organization
/// - Enables easy maintenance and updates of API routes
/// 
/// Key Logic:
/// - Static constants for all API endpoints organized by feature
/// - Auth endpoints: login, OTP verification, token refresh
/// - User endpoints: profile management, driver operations
/// - Booking endpoints: creation, acceptance, listing, details
/// - Trip endpoints: listing, details, status updates
/// - Payment endpoints: wallet operations and transactions
/// - Vehicle estimation endpoints: fare calculation
/// - Parameterized methods for dynamic endpoints (bookingDetail, tripDetail)
/// - Follows RESTful API conventions for URL structure

class ApiEndpoints {
  // Auth endpoints
  static const String login = '/api/users/login/';
  static const String verifyOtp = '/api/users/verify-otp/';
  static const String refreshToken = '/api/users/token/refresh/';

  // User endpoints
  static const String userProfile = '/api/users/profile/';
  static const String driverProfile = '/api/users/driver/profile/';
  static const String createDriver = '/api/users/driver/';

  // Booking endpoints
  static const String createBooking = '/api/booking/create/';
  static const String acceptBooking = '/api/booking/accept/';
  static const String bookingList = '/api/booking/list/';
  static String bookingDetail(int bookingId) => '/api/booking/detail/$bookingId/';

  // Trip endpoints
  static const String tripList = '/api/trip/list/';
  static String tripDetail(int tripId) => '/api/trip/detail/$tripId/';
  static String updateTrip(int tripId) => '/api/trip/update/$tripId/';

  // Payment endpoints
  static const String walletBalance = '/api/payments/wallet/balance/';
  static const String walletTransactions = '/api/payments/wallet/transactions/';
  static const String walletTopup = '/api/payments/wallet/topup/';

  // Vehicle estimation endpoints
  static const String vehicleEstimates = '/api/strategy/vehicle-estimates/';
} 