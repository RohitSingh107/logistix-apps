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
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'otp_verification_screen.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../language/presentation/screens/language_selection_screen.dart';

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
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showUserNotFoundDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/signup');
            },
            child: Text(l10n.createProfile),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 644),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.white),
            child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                    child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const SizedBox(height: 32),
                          // Logo
                          Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/logo without text/logo color.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback to gradient if image not found
                                  return Container(
                                    decoration: ShapeDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment(-0.00, 0.00),
                                        end: Alignment(1.00, 1.00),
                                        colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Title
                        Center(
                          child: Text(
                              'Welcome to Logistix',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF111111),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Description
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 21.50),
                              child: Text(
                                'Use your phone to access trips, earnings, and\nsupport.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF9CA3AF),
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                          ),
                          const SizedBox(height: 32),
                          // Phone Number Input
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Phone number',
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
                                  vertical: 11,
                                ),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: _phoneError != null
                                          ? theme.colorScheme.error
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
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: Color(0xFF111111),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                          controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: TextStyle(
                                          color: const Color(0xFF111111),
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '+1 202 555 • • • •',
                                          hintStyle: TextStyle(
                                            color: const Color(0xFF111111).withOpacity(0.90),
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
                            setState(() {
                                            _phoneNumber = value;
                              _phoneError = null;
                            });
                          },
                                        onSubmitted: (value) {
                                          if (value.isNotEmpty) {
                            _requestOtp();
                                          }
                          },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_phoneError != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  _phoneError!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                        ),
                                ),
                              ] else ...[
                                const SizedBox(height: 6),
                                Text(
                                  'We\'ll send a verification code to this number.',
                                  style: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Login Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            
                              return GestureDetector(
                                onTap: isLoading ? null : _requestOtp,
                                child: Container(
                              width: double.infinity,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: isLoading
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
                                child: isLoading
                                      ? Center(
                                          child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            ' Log in',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                          color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                            ),
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        ],
                      ),
                    ),
                    ),
                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        top: 13,
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE6E6E6),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                          const Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Secure authentication',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: ShapeDecoration(
                              color: const Color(0xFF9CA3AF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Logistix',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}