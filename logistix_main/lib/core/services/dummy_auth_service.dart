import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

// Temporary dummy service that implements AuthService but doesn't depend on ApiClient
class DummyAuthService implements AuthService {
  final SharedPreferences _prefs;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  DummyAuthService(this._prefs);

  @override
  String? get accessToken => _prefs.getString(_accessTokenKey);
  
  @override
  String? get refreshToken => _prefs.getString(_refreshTokenKey);
  
  @override
  Future<void> saveTokens(String access, String refresh) async {
    await _prefs.setString(_accessTokenKey, access);
    await _prefs.setString(_refreshTokenKey, refresh);
  }
  
  @override
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }
  
  @override
  Future<bool> refreshAccessToken() async {
    // Dummy implementation - just return false
    return false;
  }
  
  @override
  Future<bool> isTokenValid() async {
    // Dummy implementation
    return accessToken != null;
  }
} 