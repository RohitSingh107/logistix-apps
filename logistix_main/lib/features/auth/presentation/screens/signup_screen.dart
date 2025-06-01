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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _phone;
  String? _firstName;
  String? _lastName;
  String? _phoneError;
  String? _firstNameError;
  String? _lastNameError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    
    // Reset all errors
    setState(() {
      _phoneError = null;
      _firstNameError = null;
      _lastNameError = null;
    });
    
    // Validate phone
    final phone = _phone ?? _phoneController.text;
    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Please enter a valid phone number';
      });
      isValid = false;
    }
    
    // Validate first name
    if (_firstNameController.text.isEmpty) {
      setState(() {
        _firstNameError = 'Please enter your first name';
      });
      isValid = false;
    }
    
    // Validate last name
    if (_lastNameController.text.isEmpty) {
      setState(() {
        _lastNameError = 'Please enter your last name';
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
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    
    setState(() {
      _phone = phone; // Make sure we store the phone number
      _firstName = firstName;
      _lastName = lastName;
    });
    
    // Request OTP for signup (passing firstName and lastName)
    context.read<AuthBloc>().add(RequestOtp(
      phone,
      isLogin: false,
      firstName: firstName,
      lastName: lastName,
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
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
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
            } else if (message.contains('first name') || message.contains('firstname')) {
              setState(() {
                _firstNameError = state.message;
              });
            } else if (message.contains('last name') || message.contains('lastname')) {
              setState(() {
                _lastNameError = state.message;
              });
            } else {
              // General error
              _showErrorToast(state.message);
            }
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: const OutlineInputBorder(),
                    errorText: _firstNameError,
                  ),
                  onChanged: (value) {
                    if (_firstNameError != null) {
                      setState(() {
                        _firstNameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border: const OutlineInputBorder(),
                    errorText: _lastNameError,
                  ),
                  onChanged: (value) {
                    if (_lastNameError != null) {
                      setState(() {
                        _lastNameError = null;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
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
    );
  }
} 