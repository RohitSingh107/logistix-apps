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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/phone_input.dart';
import 'otp_verification_screen.dart';
import '../../../language/presentation/bloc/language_bloc.dart';

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
        _phoneError = AppLocalizations.of(context).get('pleaseEnterValidPhone');
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
          title: Text(AppLocalizations.of(context).get('userNotFound')),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).get('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/signup');
              },
              child: Text(AppLocalizations.of(context).get('signup')),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).get('login')),
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                // Navigate to language selection screen
                Navigator.of(context).pushReplacementNamed('/language-selection');
              },
            ),
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
                  Text(
                    AppLocalizations.of(context).get('welcomeBack'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
                            : Text(AppLocalizations.of(context).get('sendOtp')),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text(AppLocalizations.of(context).get('dontHaveAccount')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 