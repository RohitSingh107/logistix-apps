/// signup_screen.dart - User Registration Interface
/// 
/// Purpose:
/// - Provides user interface for new user registration
/// - Handles phone number input and validation for signup flow
/// - Manages signup-specific user interactions and error handling
/// 
/// Key Logic:
/// - Implements phone number input validation using PhoneInput widget
/// - Triggers OTP request through AuthBloc for registration flow
/// - Handles different error scenarios (phone already registered, validation errors)
/// - Shows context-specific error messages via SnackBar and dialogs
/// - Navigates to OTP verification screen upon successful request
/// - Provides login redirection for users with existing accounts
/// - Manages loading states during OTP request process
/// - Implements form validation with real-time error feedback
/// - Handles phone already exists scenario with helpful dialog

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/phone_input.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _phone;
  String? _phoneError;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    // Reset all errors
    setState(() {
      _phoneError = null;
    });
    
    // Validate phone
    final phone = _phone ?? _phoneController.text;
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
      isValid = false;
    }
    
    return isValid;
  }

  void _requestOtp() {
    // Validate all inputs first
    if (!_validateInputs()) {
      return;
    }
    
    final phone = _phone ?? _phoneController.text;
    
    setState(() {
      _phone = phone; // Make sure we store the phone number
    });
    
    // Request OTP for signup
    context.read<AuthBloc>().add(RequestOtp(
      phone,
      isLogin: false,
    ));
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

  void _showPhoneExistsDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Already Exists'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpRequested) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phone: state.phone,
                  isLogin: false,
                ),
              ),
            );
          } else if (state is AuthError) {
            final message = state.message.toLowerCase();
            
            // Handle phone already registered
            if (message.contains('already registered') || 
                message.contains('already exists')) {
              _showPhoneExistsDialog(state.message);
              return;
            }
            
            // Handle specific field errors
            if (message.contains('phone')) {
              setState(() {
                _phoneError = state.message;
              });
            } else {
              // General error
              _showErrorToast(state.message);
            }
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  PhoneInput(
                    controller: _phoneController,
                    errorText: _phoneError,
                    onChanged: (phone) {
                      setState(() {
                        _phone = phone;
                        _phoneError = null;
                      });
                    },
                    onSubmitted: (phone) {
                      setState(() {
                        _phone = phone;
                        _phoneError = null;
                      });
                      _requestOtp();
                    },
                  ),
                  const SizedBox(height: 24),
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
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 