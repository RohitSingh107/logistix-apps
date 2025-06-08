import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'https://02d7-43-225-75-202.ngrok-free.app/api';
  
  Future<bool> sendOTP(String phone) async {
    try {
      print('Sending OTP to $phone');
      print('Using API URL: $baseUrl/users/login/');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
        },
        body: jsonEncode({'phone': phone}),
      );

      print('OTP Send Response Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      }
      print('Failed to send OTP. Status code: ${response.statusCode}');
      return false;
    } catch (e, stackTrace) {
      print('Error sending OTP: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOTP(String phone, String otp) async {
    try {
      print('Verifying OTP for $phone with code $otp');
      print('Using API URL: $baseUrl/users/verify-otp/');
      
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

      print('Verify OTP Response Status: ${response.statusCode}');
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
      print('Failed to verify OTP. Status code: ${response.statusCode}');
      return null;
    } catch (e, stackTrace) {
      print('Error verifying OTP: $e');
      print('Stack trace: $stackTrace');
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

  Future<Map<String, dynamic>?> acceptBooking(int bookingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Accepting booking with ID: $bookingId');
      final response = await http.post(
        Uri.parse('$baseUrl/booking/accept/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'booking_request_id': bookingId}),
      );

      print('Accept Booking Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error accepting booking: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateTripStatus(int tripId, String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Updating trip $tripId status to: $status');
      final response = await http.post(
        Uri.parse('$baseUrl/trip/update/$tripId/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'status': status}),
      );

      print('Update Trip Status Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error updating trip status: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDriverProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Fetching driver profile');
      final response = await http.get(
        Uri.parse('$baseUrl/users/driver/profile/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Get Driver Profile Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching driver profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateDriverAvailability(bool isAvailable) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Updating driver availability to: $isAvailable');
      final response = await http.patch(
        Uri.parse('$baseUrl/users/driver/profile/'),
        headers: {
          'Content-Type': 'application/json',
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'is_available': isAvailable}),
      );

      print('Update Driver Availability Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error updating driver availability: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDriverTrips({int page = 1, int pageSize = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Fetching driver trips - Page: $page, Size: $pageSize');
      final response = await http.get(
        Uri.parse('$baseUrl/trip/list/?for_driver=true&page=$page&page_size=$pageSize'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Get Driver Trips Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching driver trips: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTripDetail(int tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      
      print('Fetching trip detail for ID: $tripId');
      final response = await http.get(
        Uri.parse('$baseUrl/trip/detail/$tripId/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Get Trip Detail Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching trip detail: $e');
      return null;
    }
  }
} 
