/// create_driver_profile_screen.dart - Driver Profile Creation Screen
/// 
/// Purpose:
/// - Provides interface for creating driver profile for first-time users
/// - Handles license number input and validation
/// - Integrates with driver repository for profile creation
/// 
/// Key Logic:
/// - Collects driver license information
/// - Automatically sets driver as available
/// - Includes FCM token for push notifications
/// - Handles form validation and error display
/// - Navigates to home screen on success
library;

import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../domain/repositories/driver_repository.dart';
import '../../../vehicle/presentation/widgets/vehicle_verification_wrapper.dart';

class CreateDriverProfileScreen extends StatefulWidget {
  const CreateDriverProfileScreen({super.key});

  @override
  State<CreateDriverProfileScreen> createState() => _CreateDriverProfileScreenState();
}

class _CreateDriverProfileScreenState extends State<CreateDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseNumberController = TextEditingController();
  bool _isLoading = false;
  String? _licenseNumberError;

  @override
  void dispose() {
    _licenseNumberController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    setState(() {
      _licenseNumberError = null;
    });
    
    if (_licenseNumberController.text.trim().isEmpty) {
      setState(() {
        _licenseNumberError = 'Please enter your license number';
      });
      isValid = false;
    } else if (_licenseNumberController.text.trim().length < 6) {
      setState(() {
        _licenseNumberError = 'License number must be at least 6 characters';
      });
      isValid = false;
    }
    
    return isValid;
  }

  Future<void> _createDriverProfile() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚗 Starting driver profile creation...');
      final driverRepository = serviceLocator<DriverRepository>();
      print('✅ DriverRepository obtained from service locator');
      
      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await PushNotificationService.getCurrentToken();
        print('📱 FCM token obtained: ${fcmToken != null ? 'Yes' : 'No'}');
      } catch (e) {
        print('⚠️ Warning: Failed to get FCM token: $e');
      }

      final licenseNumber = _licenseNumberController.text.trim();
      print('📝 Creating driver profile with license: $licenseNumber');

      // Create driver profile
      await driverRepository.createDriverProfile(
        licenseNumber: licenseNumber,
        isAvailable: true,
        fcmToken: fcmToken,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen
        // Navigate to VehicleVerificationWrapper to check if documents are needed
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const VehicleVerificationWrapper(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Failed to create driver profile';
        
        // Provide more specific error messages
        if (e.toString().contains('GetIt')) {
          errorMessage = 'Configuration error. Please restart the app.';
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
          errorMessage = 'Network error. Please check your connection and try again.';
        } else if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
          errorMessage = 'Authentication error. Please log in again.';
        } else if (e.toString().contains('400') || e.toString().contains('bad request')) {
          errorMessage = 'Invalid license number. Please check and try again.';
        } else if (e.toString().contains('500') || e.toString().contains('server')) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage = 'Failed to create driver profile: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Driver Profile'),
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Header
              Column(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Complete Your Driver Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your license information to start accepting bookings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // License Number Field
              TextFormField(
                controller: _licenseNumberController,
                decoration: InputDecoration(
                  labelText: 'Driving License Number',
                  hintText: 'Enter your license number',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: _licenseNumberError,
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  if (_licenseNumberError != null) {
                    setState(() {
                      _licenseNumberError = null;
                    });
                  }
                },
              ),
              
              const SizedBox(height: 24),
              
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your license information will be verified. Make sure to enter the correct details.',
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Create Profile Button
              ElevatedButton(
                onPressed: _isLoading ? null : _createDriverProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Driver Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 