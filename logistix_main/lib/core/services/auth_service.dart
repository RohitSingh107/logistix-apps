import 'dart:convert';
import 'dart:math' as math;
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
  static const int _refreshThresholdMinutes = 5; // Refresh token if less than 5 minutes left

  AuthService(this._dio, this._prefs);

  String? get accessToken {
    final token = _prefs.getString(_accessTokenKey);
    print('DEBUG: Getting access token: ${token != null ? "Token exists" : "No token found"}');
    return token;
  }
  
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> saveTokens(String access, String refresh) async {
    print('DEBUG: Saving tokens - Access: ${access.substring(0, math.min(20, access.length))}..., Refresh: ${refresh.substring(0, math.min(20, refresh.length))}...');
    await _prefs.setString(_accessTokenKey, access);
    await _prefs.setString(_refreshTokenKey, refresh);
    
    try {
      // Extract and save expiration time
      final decodedToken = JwtDecoder.decode(access);
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

  Future<void> clearTokens() async {
    print('DEBUG: Clearing all tokens');
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);
  }

  // Check if token needs refresh (less than threshold minutes remaining)
  bool _shouldRefreshToken() {
    try {
      final token = accessToken;
      if (token == null) {
        print('DEBUG: Should refresh token - No token found');
        return true;
      }
      
      final expiryTime = _prefs.getInt(_tokenExpiryKey);
      if (expiryTime == null) {
        // If no expiry saved, check using JwtDecoder
        if (JwtDecoder.isExpired(token)) {
          print('DEBUG: Should refresh token - Token is expired');
          return true;
        }
        
        final decodedToken = JwtDecoder.decode(token);
        final expMillis = decodedToken['exp'] * 1000;
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Refresh if token expires within threshold minutes
        final thresholdMillis = _refreshThresholdMinutes * 60 * 1000;
        final shouldRefresh = (expMillis - now) < thresholdMillis;
        print('DEBUG: Should refresh token - ${shouldRefresh ? "Yes" : "No"}, Expires in: ${(expMillis - now) / 60000} minutes');
        return shouldRefresh;
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        final thresholdMillis = _refreshThresholdMinutes * 60 * 1000;
        final shouldRefresh = (expiryTime - now) < thresholdMillis;
        print('DEBUG: Should refresh token - ${shouldRefresh ? "Yes" : "No"}, Expires in: ${(expiryTime - now) / 60000} minutes');
        return shouldRefresh;
      }
    } catch (e) {
      print('ERROR: Error checking token expiry: $e');
      return true; // Refresh on error
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refresh = refreshToken;
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
    if (accessToken == null) return false;
    if (_shouldRefreshToken()) {
      return await refreshAccessToken();
    }
    return true;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    final token = accessToken;
    return token != null && !JwtDecoder.isExpired(token);
  }
} 