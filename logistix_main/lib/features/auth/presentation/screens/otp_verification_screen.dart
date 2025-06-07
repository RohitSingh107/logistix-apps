import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../profile/presentation/screens/create_profile_screen.dart';
import '../../../home/presentation/screens/home_screen.dart';

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
  bool _hasVerificationFailed = false;

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

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _handleOtpInput(String value, int index) {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
        _hasVerificationFailed = false;
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
    final lowerCaseMsg = errorMessage.toLowerCase();
    
    // Check for specific OTP errors
    if (lowerCaseMsg.contains('invalid') && lowerCaseMsg.contains('otp')) {
      setState(() {
        _errorText = 'Invalid OTP. Please check and try again.';
        _hasVerificationFailed = true;
      });
    } else if (lowerCaseMsg.contains('expire')) {
      setState(() {
        _errorText = 'OTP has expired. Please request a new one.';
        _hasVerificationFailed = true;
      });
    } else {
      setState(() {
        _errorText = errorMessage;
        _hasVerificationFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the OTP sent to ${widget.phone}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        errorText: _errorText != null && index == 0 ? _errorText : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) => _handleOtpInput(value, index),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            final otp = _controllers.map((c) => c.text).join();
                            _verifyOtp(otp);
                          },
                    child: state is AuthLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Text('Verify OTP'),
                  );
                },
              ),
              const SizedBox(height: 16),
              if (_hasVerificationFailed)
                ElevatedButton.icon(
                  onPressed: _clearOtpFields,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(RequestOtp(
                    widget.phone,
                    isLogin: widget.isLogin,
                    firstName: widget.firstName,
                    lastName: widget.lastName,
                  ));
                },
                child: const Text('Resend OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 