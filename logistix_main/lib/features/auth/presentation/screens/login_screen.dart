/**
 * login_screen.dart - User Login Interface
 * 
 * Purpose:
 * - Provides user interface for login functionality
 * - Handles phone number input and OTP request flow
 * - Manages login-specific user interactions and error states
 * 
 * Key Logic:
 * - Implements phone number input validation using PhoneInput widget
 * - Triggers OTP request through AuthBloc for login flow
 * - Handles different error scenarios (user not found, validation errors)
 * - Shows user-friendly error messages via SnackBar and dialogs
 * - Navigates to OTP verification screen upon successful request
 * - Provides signup redirection for unregistered users
 * - Manages loading states during OTP request
 * - Implements proper error handling with context-specific messages
 */

import 'package:flutter/material.dart';
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpRequested) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phone: state.phone,
                  isLogin: true,
                ),
              ),
            );
          } else if (state is AuthError) {
            final message = state.message.toLowerCase();
            
            // Handle user not found error
            if (message.contains('not found') || 
                message.contains('does not exist') ||
                message.contains('not registered')) {
              _showUserNotFoundDialog(state.message);
              return;
            }
            
            // Handle phone-specific errors
            if (message.contains('phone')) {
              setState(() {
                _phoneError = state.message;
              });
            } else {
              _showErrorToast(state.message);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              PhoneInput(
                controller: _phoneController,
                errorText: _phoneError,
                onChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone;
                    _phoneError = null; // Clear error when user types
                  });
                },
                onSubmitted: (phone) {
                  setState(() {
                    _phoneNumber = phone;
                    _phoneError = null; // Clear error when user submits
                  });
                  _requestOtp();
                },
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : _requestOtp,
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('Send OTP'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 