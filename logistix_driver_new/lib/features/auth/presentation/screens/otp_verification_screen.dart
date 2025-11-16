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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../vehicle/presentation/widgets/vehicle_verification_wrapper.dart';

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
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes

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
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 120;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _maskPhoneNumber(String phone) {
    if (phone.length <= 4) return phone;
    final prefix = phone.substring(0, phone.length - 4);
    return '$prefix • • • •';
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  void _resendOtp() {
    context.read<AuthBloc>().add(RequestOtp(
      widget.phone,
      isLogin: widget.isLogin,
      firstName: widget.firstName,
      lastName: widget.lastName,
    ));
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
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
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const VehicleVerificationWrapper(),
                    ),
                  );
                }
              } else if (state is AuthError) {
                _handleVerificationError(state.message);
              }
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 644),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 67),
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
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            // Title
                            Center(
                              child: Text(
                                'Enter verification code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF111111),
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Description
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 36.91),
                                child: Text(
                                  'We sent a 6‑digit code to ${_maskPhoneNumber(widget.phone)}',
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
                            const SizedBox(height: 16),
                            // SMS Verification Card
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.sms_outlined,
                                        size: 18,
                                        color: Color(0xFF111111),
                      ),
                                      const SizedBox(width: 8),
                      Text(
                                        'SMS Verification',
                                        style: TextStyle(
                                          color: const Color(0xFF111111),
                                          fontSize: 15,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                        child: Text(
                                          _formatTimer(_remainingSeconds),
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      const SizedBox(width: 8),
                  Text(
                                        'Code expires in 2 minutes',
                                        style: TextStyle(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                    ),
                  ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 6-digit code input
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                  Text(
                                  '6-digit code',
                                  style: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                    ),
                  ),
                                const SizedBox(height: 10),
                  Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      6,
                      (index) => Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.all(1),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFFAFAFA),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1,
                                            color: _errorText != null
                              ? theme.colorScheme.error 
                              : _focusedIndex == index
                                                    ? const Color(0xFFFF6B00)
                                                    : const Color(0xFFE6E6E6),
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                            ),
                        ),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                                          color: const Color(0xFF111111),
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                          ),
                                        cursorColor: const Color(0xFFFF6B00),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) => _handleOtpInput(value, index),
                        ),
                      ),
                    ),
                  ),
                                if (_errorText != null) ...[
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      _errorText!,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                // Resend and change number
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Didn\'t receive it? ',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: _remainingSeconds == 0 ? _resendOtp : null,
                                            child: Text(
                                              'Resend',
                                              style: TextStyle(
                                                color: _remainingSeconds == 0
                                                    ? const Color(0xFFFF6B00)
                                                    : const Color(0xFF9CA3AF),
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Use a different number',
                                              style: TextStyle(
                                                color: const Color(0xFFFF6B00),
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                  // Verify Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                
                                return GestureDetector(
                                  onTap: isLoading
                              ? null
                              : () {
                                  final otp = _controllers.map((c) => c.text).join();
                                  _verifyOtp(otp);
                                },
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
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.check_circle_outline,
                                                size: 18,
                                    color: Colors.white,
                                  ),
                                              const SizedBox(width: 8),
                                              Text(
                                                ' Verify and continue',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
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
                            'Secure one-time code',
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
