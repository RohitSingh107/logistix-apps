/// login_screen.dart - User Login Interface
/// 
/// Purpose:
/// - Provides user interface for login functionality
/// - Handles phone number input and OTP request flow
/// - Manages login-specific user interactions and error states
/// 
/// Key Logic:
/// - Implements phone number input validation using PhoneInput widget
/// - Triggers OTP request through AuthBloc for login flow
/// - Handles different error scenarios (user not found, validation errors)
/// - Shows user-friendly error messages via SnackBar and dialogs
/// - Navigates to OTP verification screen upon successful request
/// - Provides signup redirection for unregistered users
/// - Manages loading states during OTP request
/// - Implements proper error handling with context-specific messages
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/phone_input.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneNumber;
  String? _phoneError;
  bool _isFromNavigation = false; // Track if user came from navigation

  @override
  void initState() {
    super.initState();
    // Check if there's a previous route in the navigation stack
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFromNavigation = ModalRoute.of(context)?.settings.name != null;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    print('Requesting OTP for $_phoneNumber');
    
    // Try to get phone number from controller if not set by onChanged
    final phone = _phoneNumber ?? _phoneController.text;
    
    if (phone.isNotEmpty) {
      // Update state to keep track of the phone
      setState(() {
        _phoneNumber = phone;
        _phoneError = null;
      });
      
      // Use RequestOtp with isLogin=true for login flow
      context.read<AuthBloc>().add(RequestOtp(phone, isLogin: true));
    } else {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showUserNotFoundDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Not Found'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/signup');
            },
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Exit the app
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: _isFromNavigation, // Allow back navigation only if user came from navigation
      onPopInvoked: (didPop) {
        if (!didPop && !_isFromNavigation) {
          // If user tries to go back but shouldn't be able to, show confirmation dialog
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light gray background
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                if (state.message.contains('not found')) {
                  _showUserNotFoundDialog(state.message);
                } else {
                  _showErrorToast(state.message);
                }
              } else if (state is OtpRequested) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OtpVerificationScreen(
                      phone: _phoneNumber!,
                      isLogin: true,
                    ),
                  ),
                );
              }
            },
            child: Column(
              children: [
                // Top Section - Interactive Elements (60% of screen)
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60), // Exact spacing from top
                        
                        // Title Section - Centered
                        Center(
                          child: Text(
                            'Logistics',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary, // Orange-brown #D2691E
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 50), // Exact spacing from title
                        
                        // Phone Input Section
                        PhoneInput(
                          controller: _phoneController,
                          onChanged: (phone) {
                            setState(() {
                              _phoneNumber = phone;
                              _phoneError = null;
                            });
                          },
                          onSubmitted: (phone) {
                            setState(() {
                              _phoneNumber = phone;
                              _phoneError = null;
                            });
                            _requestOtp();
                          },
                          errorText: _phoneError,
                        ),
                        
                        const SizedBox(height: 40), // Exact spacing from input
                        
                        // Next Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _requestOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // Exact border radius
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20), // Exact spacing from button
                        
                        // Terms and Privacy Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: true, // Always checked as shown in design
                              onChanged: (value) {
                                // Handle checkbox state if needed
                              },
                              activeColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Inter',
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'terms of service',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'privacy policy',
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Section - Image Placeholder (40% of screen)
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.delivery_dining,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}