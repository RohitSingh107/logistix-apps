/// otp_verification_screen.dart - OTP Verification Interface
/// 
/// Purpose:
/// - Provides user interface for OTP verification during authentication
/// - Handles 6-digit OTP input with automatic field progression
/// - Manages verification process for both login and registration flows
/// 
/// Key Logic:
/// - Implements 6-digit OTP input with individual text fields
/// - Automatic focus progression between OTP input fields
/// - Auto-verification when all 6 digits are entered
/// - Handles different verification error scenarios with specific messages
/// - Supports both login and registration flows through isLogin parameter
/// - Navigates to appropriate screens based on authentication result
/// - Provides error feedback with field clearing for failed attempts
/// - Real-time error state management with visual feedback
/// - Supports retry functionality for failed verifications
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth_bloc.dart';
import '../../../../generated/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final bool isLogin;
  final String? firstName;
  final String? lastName;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.isLogin,
    this.firstName,
    this.lastName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  String? _errorText;
  int _focusedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Add focus listeners to track focused field
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _focusedIndex = _focusNodes[i].hasFocus ? i : -1;
        });
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOtpInput(String value, int index) {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
    
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // Check if all fields are filled
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      _verifyOtp(otp);
    }
  }

  void _verifyOtp(String otp) {
    if (otp.length != 6) {
      setState(() {
        _errorText = 'Please enter a valid 6-digit OTP';
      });
      return;
    }
    
    context.read<AuthBloc>().add(
      VerifyOtp(
        phone: widget.phone,
        otp: otp,
        isLogin: widget.isLogin,
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
    );
  }

  void _handleVerificationError(String errorMessage) {
    final l10n = AppLocalizations.of(context)!;
    final lowerCaseMsg = errorMessage.toLowerCase();
    
    // Check for specific OTP errors
    if (lowerCaseMsg.contains('invalid') && lowerCaseMsg.contains('otp')) {
      setState(() {
        _errorText = l10n.invalidOtp;
      });
    } else if (lowerCaseMsg.contains('expire')) {
      setState(() {
        _errorText = l10n.otpExpired;
      });
    } else {
      setState(() {
        _errorText = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return PopScope(
      canPop: true, // Allow back navigation to login screen
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Light gray background
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                if (state.isNewUser) {
                  Navigator.of(context).pushReplacementNamed(
                    '/profile/create',
                    arguments: {'phone': widget.phone},
                  );
                } else {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              } else if (state is AuthError) {
                _handleVerificationError(state.message);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60), // Exact spacing from top
                  
                  // Title Section - Centered
                  Center(
                    child: Text(
                      l10n.appTitle,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary, // Orange-brown
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40), // Exact spacing from title
                  
                  // Phone Number Display
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: Colors.grey.shade300, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: const Color(0xFFFF5722), // Saffron
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: Colors.white,
                                child: Center(
                                  child: Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF000080), // Navy blue
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: const Color(0xFF4CAF50), // Green
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.phone,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Bold as shown in design
                          color: Colors.black, // Dark grey/black as shown
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          l10n.change,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10), // Exact spacing from phone number
                  
                  // Instructions
                  Text(
                    l10n.otpInstructions,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600, // Lighter grey
                    ),
                  ),
                  
                  const SizedBox(height: 20), // Exact spacing from instructions
                  
                  // Status Message
                  Text(
                    l10n.waitingToAutoVerify,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 20), // Exact spacing from status
                  
                  // OTP Input Fields - 6 individual fields with proper styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      6,
                      (index) => Container(
                        width: 45,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, // Light gray background
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _errorText != null && index == 0 
                              ? theme.colorScheme.error 
                              : _focusedIndex == index
                                ? theme.colorScheme.primary // Orange-brown for focused
                                : Colors.grey.shade300,
                            width: _focusedIndex == index ? 2.0 : 1.0, // Double border for focused
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _focusedIndex == index 
                                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: _focusedIndex == index ? 4 : 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black, // Black text for visibility
                            fontFamily: 'Inter',
                            height: 1.2, // Ensure proper line height
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorText: _errorText != null && index == 0 ? _errorText : null,
                            contentPadding: EdgeInsets.zero, // Remove any padding
                          ),
                          cursorColor: theme.colorScheme.primary,
                          cursorWidth: 2.0,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _handleOtpInput(value, index),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40), // Exact spacing from OTP input
                  
                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  final otp = _controllers.map((c) => c.text).join();
                                  _verifyOtp(otp);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                          ),
                          child: state is AuthLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.verify,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20), // Exact spacing from button
                  
                  // Resend OTP Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(RequestOtp(
                          widget.phone,
                          isLogin: widget.isLogin,
                          firstName: widget.firstName,
                          lastName: widget.lastName,
                        ));
                      },
                      child: Text(
                        l10n.resendOtp,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(), // Push content to top, ignore keyboard space
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}