/// auth_service.dart - Authentication Service Layer
/// 
/// Purpose:
/// - Manages authentication tokens and user session data
/// - Provides secure token storage using SharedPreferences
/// - Handles JWT token validation and automatic refresh
/// 
/// Key Logic:
/// - Stores access and refresh tokens securely in local storage
/// - Automatically refreshes tokens when they're close to expiration
/// - Validates JWT token expiration using jwt_decoder
/// - Manages user data persistence across app sessions
/// - Provides authentication status checking
/// - Handles token cleanup on logout
/// - Implements proactive token refresh (5 minutes before expiry)
/// - Uses separate Dio instance for token refresh to avoid interceptor loops

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'api_endpoints.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userDataKey = 'user_data';
  static const int _refreshThresholdMinutes = 5; // Refresh token if less than 5 minutes left

  AuthService(this._dio, this._prefs);

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  Map<String, dynamic>? get userData {
    final data = _prefs.getString(_userDataKey);
    return data != null ? jsonDecode(data) : null;
  }

  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
    
    try {
      // Extract and save expiration time
      final decodedToken = JwtDecoder.decode(accessToken);
      final expiryTime = decodedToken['exp'] * 1000; // Convert to milliseconds
      await _prefs.setInt(_tokenExpiryKey, expiryTime);
      print('DEBUG: Token expiry saved: ${DateTime.fromMillisecondsSinceEpoch(expiryTime)}');
    } catch (e) {
      print('ERROR: Error parsing JWT token: $e');
    }
    
    // Verify tokens were saved correctly
    final savedAccess = _prefs.getString(_accessTokenKey);
    final savedRefresh = _prefs.getString(_refreshTokenKey);
    print('DEBUG: Tokens saved - Access: ${savedAccess != null}, Refresh: ${savedRefresh != null}');
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, jsonEncode(userData));
  }

  Future<void> clearTokens() async {
    print('DEBUG: Clearing all tokens and user data');
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);
    await _prefs.remove(_userDataKey);
  }

  bool _shouldRefreshToken() {
    final expiryTime = _prefs.getInt(_tokenExpiryKey);
    if (expiryTime == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch;
    final timeUntilExpiry = expiryTime - now;
    final minutesUntilExpiry = timeUntilExpiry / (1000 * 60);

    print('DEBUG: Token expires in ${minutesUntilExpiry.toStringAsFixed(1)} minutes');
    return minutesUntilExpiry < _refreshThresholdMinutes;
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refresh = await getRefreshToken();
      if (refresh == null) {
        print('DEBUG: Cannot refresh token - No refresh token available');
        return false;
      }

      print('DEBUG: Attempting to refresh token');
      // Create a new Dio instance to avoid interceptors
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(ApiEndpoints.refreshToken, data: {
        'refresh': refresh,
      });

      if (response.statusCode == 200 && response.data['access'] != null) {
        final newAccessToken = response.data['access'];
        await _prefs.setString(_accessTokenKey, newAccessToken);
        
        // Update expiry time
        try {
          final decodedToken = JwtDecoder.decode(newAccessToken);
          final expiryTime = decodedToken['exp'] * 1000;
          await _prefs.setInt(_tokenExpiryKey, expiryTime);
        } catch (e) {
          print('Error parsing refreshed JWT token: $e');
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    }
  }

  // Check and refresh token if needed
  Future<bool> ensureValidToken() async {
    if (_shouldRefreshToken()) {
      return await refreshAccessToken();
    }
    return true;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error checking token expiration: $e');
      return false;
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return userData;
  }
} 