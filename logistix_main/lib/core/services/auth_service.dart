import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class AuthService {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthService(this._apiClient, this._prefs);

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> saveTokens(String access, String refresh) async {
    await _prefs.setString(_accessTokenKey, access);
    await _prefs.setString(_refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refresh = refreshToken;
      if (refresh == null) return false;

      final response = await _apiClient.post('/api/users/token/refresh/', data: {
        'refresh': refresh,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await _prefs.setString(_accessTokenKey, newAccessToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    if (accessToken == null) return false;
    try {
      // Make a test request to verify token
      await _apiClient.get('/api/users/profile/');
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        return await refreshAccessToken();
      }
      return false;
    }
  }
} 