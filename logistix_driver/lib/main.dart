import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:logistix_driver/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logistix_driver/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Porter Driver',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  final _authService = AuthService();

  Future<void> _sendOTP() async {
    // Remove any spaces from phone number
    final phone = _phoneController.text.replaceAll(' ', '');
    
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await _authService.sendOTP(phone);
    
    setState(() {
      _isLoading = false;
      if (success) {
        _otpSent = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      }
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    final phone = _phoneController.text.replaceAll(' ', '');
    final otp = _otpController.text.replaceAll(' ', '');

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = await _authService.verifyOTP(phone, otp);
    
    setState(() => _isLoading = false);

    if (result != null) {
      if (!mounted) return;
      
      // Update FCM token after successful login
      await _authService.updateFCMToken();
      
      if (result['is_new_user'] == true) {
        // Show profile update dialog
        _showProfileUpdateDialog(result['user']);
      } else {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showProfileUpdateDialog(Map<String, dynamic> userData) async {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final licenseNumberController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Complete Your Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: licenseNumberController,
                decoration: const InputDecoration(labelText: 'License Number'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              
              // Update user profile
              final updatedUser = await _authService.updateUserProfile({
                'first_name': firstNameController.text,
                'last_name': lastNameController.text,
                'phone': userData['phone'],
              });

              if (updatedUser != null) {
                // Create driver profile
                final driverProfile = await _authService.createDriverProfile(
                  licenseNumberController.text,
                );

                if (driverProfile != null) {
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                }
              }

              setState(() => _isLoading = false);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Porter Driver Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter 10-digit phone number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_otpSent) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isLoading ? null : _sendOTP,
                child: const Text('Resend OTP'),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send OTP'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
}
