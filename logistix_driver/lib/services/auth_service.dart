import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'https://02d7-43-225-75-202.ngrok-free.app/api';
  
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

  Future<Map<String, dynamic>?> updateUserProfile(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createDriverProfile(String licenseNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/driver/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'license_number': licenseNumber,
          'is_available': true,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating driver profile: $e');
      return null;
    }
  }

  Future<bool> updateFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final fcmToken = await FirebaseMessaging.instance.getToken();
      
      if (fcmToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/users/update-fcm-token/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating FCM token: $e');
      return false;
    }
  }
} 
