/// create_driver_profile_screen.dart - Driver Profile Creation Screen
/// 
/// Purpose:
/// - Provides interface for creating driver profile for first-time users
/// - Handles personal details input and validation
/// - Integrates with driver repository for profile creation
/// 
/// Key Logic:
/// - Collects driver personal information (first name, last name, email, city)
/// - Shows onboarding progress (Profile, Vehicle, Documents)
/// - Automatically sets driver as available
/// - Includes FCM token for push notifications
/// - Handles form validation and error display
/// - Navigates to vehicle screen on success
library;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/repositories/user_repository.dart';
import '../../domain/repositories/driver_repository.dart';
import '../screens/driver_documents_screen.dart';

class CreateDriverProfileScreen extends StatefulWidget {
  const CreateDriverProfileScreen({super.key});

  @override
  State<CreateDriverProfileScreen> createState() => _CreateDriverProfileScreenState();
}

class _CreateDriverProfileScreenState extends State<CreateDriverProfileScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // Profile form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  
  // Vehicle form controllers
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  
  bool _isLoading = false;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _cityError;
  String? _licenseNumberError;
  String? _selectedCity;
  String? _selectedVehicleType = 'Car';
  String? _selectedColor;
  
  // List of cities (you can replace this with an API call)
  final List<String> _cities = [
    'Delhi NCR',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Surat',
  ];
  
  // List of colors
  final List<String> _colors = [
    'White',
    'Black',
    'Silver',
    'Red',
    'Blue',
    'Grey',
    'Brown',
    'Green',
    'Yellow',
    'Orange',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Profile and Documents only
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    // Fetch and prefill driver profile if it exists
    _fetchAndPrefillProfile();
  }

  Future<void> _fetchAndPrefillProfile() async {
    try {
      final driverRepository = serviceLocator<DriverRepository>();
      final driver = await driverRepository.getDriverProfile();
      
      if (mounted) {
        // Prefill form fields from existing profile
        if (driver.user.firstName != null && driver.user.firstName!.isNotEmpty) {
          _firstNameController.text = driver.user.firstName!;
        }
        if (driver.user.lastName != null && driver.user.lastName!.isNotEmpty) {
          _lastNameController.text = driver.user.lastName!;
        }
        if (driver.licenseNumber.isNotEmpty) {
          _licenseNumberController.text = driver.licenseNumber;
        }
        
        // Check if profile is already filled
        final isProfileFilled = (driver.user.firstName != null && driver.user.firstName!.isNotEmpty) &&
                                (driver.user.lastName != null && driver.user.lastName!.isNotEmpty) &&
                                driver.licenseNumber.isNotEmpty;
        
        if (isProfileFilled) {
          // Navigate directly to documents tab
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _tabController.animateTo(1);
            }
          });
        }
      }
    } catch (e) {
      // Profile doesn't exist or error fetching - this is fine, user will create new profile
      debugPrint('Driver profile not found or error fetching: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _insuranceExpiryController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _cityError = null;
      _licenseNumberError = null;
    });
    
    if (_firstNameController.text.trim().isEmpty) {
      setState(() {
        _firstNameError = 'Please enter your first name';
      });
      isValid = false;
    }
    
    if (_lastNameController.text.trim().isEmpty) {
      setState(() {
        _lastNameError = 'Please enter your last name';
      });
      isValid = false;
    }
    
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        setState(() {
          _emailError = 'Please enter a valid email address';
        });
        isValid = false;
      }
    }
    
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      setState(() {
        _cityError = 'Please select your home base city';
      });
      isValid = false;
    }
    
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

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final licenseNumber = _licenseNumberController.text.trim();
      
      print('📝 Creating/updating driver profile with: $firstName $lastName, License: $licenseNumber');

      // Update user profile (firstName, lastName) if provided
      if (firstName.isNotEmpty || lastName.isNotEmpty) {
        try {
          final userRepository = serviceLocator<UserRepository>();
          await userRepository.updateUserProfile(
            firstName: firstName.isNotEmpty ? firstName : null,
            lastName: lastName.isNotEmpty ? lastName : null,
          );
          print('✅ User profile updated successfully');
        } catch (e) {
          print('⚠️ Warning: Failed to update user profile: $e');
          // Continue with driver profile creation even if user update fails
        }
      }

      // Create or update driver profile
      try {
        // Try to get existing profile first
        await driverRepository.getDriverProfile();
        // If profile exists, update it
        await driverRepository.updateDriverProfile(
          licenseNumber: licenseNumber,
          fcmToken: fcmToken,
        );
        print('✅ Driver profile updated successfully');
      } catch (e) {
        // Profile doesn't exist, create new one
        await driverRepository.createDriverProfile(
          licenseNumber: licenseNumber,
          isAvailable: true,
          fcmToken: fcmToken,
        );
        print('✅ Driver profile created successfully');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Documents tab after profile creation/update
        if (mounted) {
          _tabController.animateTo(1);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = _extractErrorMessage(e);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  String _extractErrorMessage(dynamic error) {
    // Handle DioException to extract API error messages
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final responseData = error.response?.data;
      
      // Try to extract error message from response
      String? apiErrorMessage;
      if (responseData is Map<String, dynamic>) {
        // Check for 'error' field
        if (responseData.containsKey('error')) {
          apiErrorMessage = responseData['error'].toString();
        }
        // Check for 'message' field
        else if (responseData.containsKey('message')) {
          apiErrorMessage = responseData['message'].toString();
        }
        // Check for 'detail' field
        else if (responseData.containsKey('detail')) {
          apiErrorMessage = responseData['detail'].toString();
        }
      } else if (responseData is String) {
        apiErrorMessage = responseData;
      }
      
      // Parse and format the error message
      if (apiErrorMessage != null) {
        // Handle duplicate key constraint (profile already exists)
        if (apiErrorMessage.contains('duplicate key') || 
            apiErrorMessage.contains('already exists') ||
            apiErrorMessage.contains('user_id')) {
          return 'Driver profile already exists. Please contact support if you need assistance.';
        }
        
        // Handle validation errors
        if (apiErrorMessage.contains('validation') || 
            apiErrorMessage.contains('required') ||
            apiErrorMessage.contains('invalid')) {
          // Try to extract field-specific errors
          if (apiErrorMessage.contains('license_number')) {
            return 'Invalid license number. Please check and try again.';
          }
          return 'Please check all fields and try again.';
        }
        
        // Clean up the error message (remove brackets, quotes, etc.)
        String cleanedMessage = apiErrorMessage;
        if (cleanedMessage.startsWith('[') && cleanedMessage.endsWith(']')) {
          cleanedMessage = cleanedMessage.substring(1, cleanedMessage.length - 1);
        }
        if ((cleanedMessage.startsWith('"') && cleanedMessage.endsWith('"')) ||
            (cleanedMessage.startsWith("'") && cleanedMessage.endsWith("'"))) {
          cleanedMessage = cleanedMessage.substring(1, cleanedMessage.length - 1);
        }
        cleanedMessage = cleanedMessage.trim();
        
        // If it's a long technical message, provide a generic one
        if (cleanedMessage.length > 100) {
          return 'Failed to create driver profile. Please try again or contact support.';
        }
        
        return cleanedMessage;
      }
      
      // Handle specific status codes
      switch (statusCode) {
        case 400:
          return 'Invalid information provided. Please check all fields and try again.';
        case 401:
          return 'Authentication failed. Please log in again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Service not found. Please try again later.';
        case 409:
          return 'Driver profile already exists. Please contact support if you need assistance.';
        case 422:
          return 'Invalid data provided. Please check all fields and try again.';
        case 500:
        case 502:
        case 503:
          return 'Server error. Please try again later.';
        default:
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return 'Request timed out. Please check your connection and try again.';
          } else if (error.type == DioExceptionType.connectionError) {
            return 'Connection error. Please check your internet connection and try again.';
          }
          return 'Failed to create driver profile. Please try again.';
      }
    }
    
    // Handle other exception types
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('getit') || errorString.contains('service locator')) {
      return 'Configuration error. Please restart the app.';
    } else if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('socket')) {
      return 'Connection error. Please check your internet connection.';
    }
    
    // Default error message
    return 'Failed to create driver profile. Please try again or contact support.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE6E6E6),
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  'Driver Onboarding',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Progress Bar
            Container(
              width: double.infinity,
              height: 4,
              decoration: const BoxDecoration(color: Color(0xFF333333)),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width * (_currentTabIndex == 0 ? 0.5 : 1.0),
                      height: 4,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFF6B00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Progress Tabs
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE6E6E6),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _tabController.animateTo(0);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: _currentTabIndex == 0
                                    ? const Color(0xFFFF6B00)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Profile',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTabIndex == 0
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_validateProfileForm()) {
                                _tabController.animateTo(1);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: ShapeDecoration(
                                color: _currentTabIndex == 1
                                    ? const Color(0xFFFF6B00)
                                    : Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                'Documents',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _currentTabIndex == 1
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(),
                        _buildDocumentsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _validateProfileForm() {
    return _validateInputs();
  }
  
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header Section
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-0.00, -0.00),
                    end: Alignment(1.00, 1.00),
                    colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create your profile',
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tell us about you to get started.',
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFE6E6E6),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        child: Form(
          key: _formKey,
          child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Text(
                    'Personal details',
                    style: TextStyle(
                      color: const Color(0xFF111111),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // First Name and Last Name Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'First name',
                              style: TextStyle(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 8,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFAFAFA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: _firstNameError != null
                                        ? Colors.red
                                        : const Color(0xFFE6E6E6),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: TextField(
                                controller: _firstNameController,
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter first\nname',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  if (_firstNameError != null) {
                                    setState(() {
                                      _firstNameError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            if (_firstNameError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _firstNameError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last name',
                              style: TextStyle(
                                color: const Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 8,
                              ),
                              decoration: ShapeDecoration(
                                color: const Color(0xFFFAFAFA),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: _lastNameError != null
                                        ? Colors.red
                                        : const Color(0xFFE6E6E6),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: TextField(
                                controller: _lastNameController,
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter last\nname',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) {
                                  if (_lastNameError != null) {
                                    setState(() {
                                      _lastNameError = null;
                                    });
                                  }
                                },
                              ),
                            ),
                            if (_lastNameError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _lastNameError!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Email Field
              Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                      Text(
                        'Email (optional)',
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAFAFA),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _emailError != null
                                  ? Colors.red
                                  : const Color(0xFFE6E6E6),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                            color: const Color(0xFF111111),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                    ),
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            hintStyle: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                  ),
                          onChanged: (value) {
                            if (_emailError != null) {
                              setState(() {
                                _emailError = null;
                              });
                            }
                          },
                        ),
                      ),
                      if (_emailError != null) ...[
                        const SizedBox(height: 4),
                  Text(
                          _emailError!,
                    style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // City Field
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Home base city',
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAFAFA),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _cityError != null
                                  ? Colors.red
                                  : const Color(0xFFE6E6E6),
                    ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_city_outlined,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCity,
                                  isExpanded: true,
                                  hint: Text(
                                    'Choose city',
                                    style: TextStyle(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: const Color(0xFF111111),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 18,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  items: _cities.map((String city) {
                                    return DropdownMenuItem<String>(
                                      value: city,
                                      child: Text(city),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedCity = newValue;
                                      _cityError = null;
                                    });
                                  },
                                ),
                              ),
                  ),
                ],
              ),
                      ),
                      if (_cityError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _cityError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
              // License Number Field
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'License number',
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFFAFAFA),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              color: _licenseNumberError != null
                                  ? Colors.red
                                  : const Color(0xFFE6E6E6),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.credit_card_outlined,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                controller: _licenseNumberController,
                                textCapitalization: TextCapitalization.characters,
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                decoration: InputDecoration(
                                  hintText: 'Enter license number',
                                  hintStyle: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                onChanged: (value) {
                  if (_licenseNumberError != null) {
                    setState(() {
                      _licenseNumberError = null;
                    });
                  }
                },
              ),
                            ),
                          ],
                        ),
                      ),
                      if (_licenseNumberError != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _licenseNumberError!,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
              const SizedBox(height: 24),
          // Continue Button
          GestureDetector(
            onTap: _isLoading ? null : () {
              _createDriverProfile();
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                color: _isLoading
                    ? const Color(0xFFFF6B00).withOpacity(0.6)
                    : const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFFF6B00),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildVehicleTab() {
    return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Header Section
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-0.00, -0.00),
                    end: Alignment(1.00, 1.00),
                    colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 20,
                ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle details',
                      style: TextStyle(
                        color: const Color(0xFF111111),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Add your vehicle to continue to documents.',
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFE6E6E6),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select vehicle type',
                  style: TextStyle(
                    color: const Color(0xFF111111),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVehicleType = 'Car';
                          });
                        },
                        child: Container(
                          height: 37,
                          decoration: ShapeDecoration(
                            color: _selectedVehicleType == 'Car'
                                ? const Color(0xFFFF6B00)
                                : const Color(0xFF333333),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: _selectedVehicleType == 'Car'
                                    ? const Color(0xFFFF6B00)
                                    : const Color(0xFFE6E6E6),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 16,
                                  color: _selectedVehicleType == 'Car'
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Car',
                                  textAlign: TextAlign.center,
                        style: TextStyle(
                                    color: _selectedVehicleType == 'Car'
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                          fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVehicleType = 'Van';
                          });
                        },
                        child: Container(
                          height: 37,
                          decoration: ShapeDecoration(
                            color: _selectedVehicleType == 'Van'
                                ? const Color(0xFFFF6B00)
                                : const Color(0xFF333333),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: _selectedVehicleType == 'Van'
                                    ? const Color(0xFFFF6B00)
                                    : const Color(0xFFE6E6E6),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.airport_shuttle,
                                  size: 16,
                                  color: _selectedVehicleType == 'Van'
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Van',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _selectedVehicleType == 'Van'
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVehicleType = 'Bike';
                          });
                        },
                        child: Container(
                          height: 37,
                          decoration: ShapeDecoration(
                            color: _selectedVehicleType == 'Bike'
                                ? const Color(0xFFFF6B00)
                                : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: _selectedVehicleType == 'Bike'
                                    ? const Color(0xFFFF6B00)
                                    : const Color(0xFFE6E6E6),
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.two_wheeler,
                                  size: 16,
                                  color: _selectedVehicleType == 'Bike'
                                      ? Colors.white
                                      : const Color(0xFF9CA3AF),
                        ),
                                const SizedBox(width: 4),
                                Text(
                                  'Bike',
                                  textAlign: TextAlign.center,
                        style: TextStyle(
                                    color: _selectedVehicleType == 'Bike'
                                        ? Colors.white
                                        : const Color(0xFF9CA3AF),
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Vehicle information',
                  style: TextStyle(
                    color: const Color(0xFF111111),
                          fontSize: 16,
                    fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Make and Model Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Make',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.build_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _makeController,
                                    style: TextStyle(
                                      color: const Color(0xFF111111),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Toyota',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                        ),
                      ),
              ),
            ],
          ),
        ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Model',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.directions_car_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _modelController,
                                    style: TextStyle(
                                      color: const Color(0xFF111111),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Corolla',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Year and Color Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _yearController,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: const Color(0xFF111111),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'YYYY',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Color',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.palette_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedColor,
                                      isExpanded: true,
                                      hint: Text(
                                        'Select',
                                        style: TextStyle(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      items: _colors.map((String color) {
                                        return DropdownMenuItem<String>(
                                          value: color,
                                          child: Text(color),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedColor = newValue;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // License Plate Field
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'License plate',
                      style: TextStyle(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFFAFAFA),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE6E6E6),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _licensePlateController,
                              textCapitalization: TextCapitalization.characters,
                              style: TextStyle(
                                color: const Color(0xFF111111),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                hintText: 'ABC-1234',
                                hintStyle: TextStyle(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // VIN and Insurance Expiry Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIN (optional)',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _vinController,
                                    textCapitalization: TextCapitalization.characters,
                                    style: TextStyle(
                                      color: const Color(0xFF111111),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '17-character\nVIN',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Insurance expiry',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 8,
                            ),
                            decoration: ShapeDecoration(
                              color: const Color(0xFFFAFAFA),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE6E6E6),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _insuranceExpiryController,
                                    style: TextStyle(
                                      color: const Color(0xFF111111),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'MM / YYYY',
                                      hintStyle: TextStyle(
                                        color: const Color(0xFF9CA3AF),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Make sure your vehicle matches your documents.',
                  style: TextStyle(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Continue Button
          GestureDetector(
            onTap: _isLoading ? null : _createDriverProfile,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: ShapeDecoration(
                color: _isLoading
                    ? const Color(0xFFFF6B00).withOpacity(0.6)
                    : const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFFF6B00),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Center(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildDocumentsTab() {
    // Navigate to documents screen when Documents tab is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentTabIndex == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DriverDocumentsScreen(),
          ),
        );
      }
    });
    
    // Show loading or placeholder while navigating
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFFF6B00),
      ),
    );
  }
} 
