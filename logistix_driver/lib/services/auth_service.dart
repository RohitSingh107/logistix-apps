import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  Future<bool> sendOTP(String phone) async {
    try {
      print('Sending OTP to $phone');
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      print('OTP Send Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOTP(String phone, String otp) async {
    try {
      print('Verifying OTP for $phone with code $otp');
      final response = await http.post(
        Uri.parse('$baseUrl/users/verify-otp/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );

      print('Verify OTP Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Store tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['tokens']['access']);
        await prefs.setString('refresh_token', data['tokens']['refresh']);
        await prefs.setString('user_data', jsonEncode(data['user']));
        return data;
      }
      return null;
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }
} 