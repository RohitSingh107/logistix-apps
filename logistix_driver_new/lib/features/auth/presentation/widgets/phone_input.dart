import 'package:flutter/material.dart';

class PhoneInput extends StatefulWidget {
  final Function(String) onSubmitted;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? errorText;

  const PhoneInput({
    super.key,
    required this.onSubmitted,
    this.onChanged,
    this.controller,
    this.errorText,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // Listen to changes in text and notify parent
    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(covariant PhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update error from parent widget
    if (widget.errorText != oldWidget.errorText) {
      _error = widget.errorText;
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  bool _validatePhone(String phone) {
    // Basic phone validation - you might want to adjust this based on your requirements
    if (phone.isEmpty) return false;
    
    // Allow just entering numbers for testing
    if (phone.length >= 4) return true;
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{9,14}$');
    return phoneRegex.hasMatch(phone);
  }

  void _handleSubmitted(String value) {
    if (_validatePhone(value)) {
      setState(() => _error = null);
      widget.onSubmitted(value);
    } else {
      setState(() => _error = 'Please enter a valid phone number');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use external error if provided, otherwise use internal validation error
    final errorMessage = widget.errorText ?? _error;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+1234567890',
            prefixIcon: const Icon(Icons.phone),
            errorText: errorMessage,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onSubmitted: _handleSubmitted,
          onChanged: (value) {
            // Clear error on typing
            if (_error != null) {
              setState(() => _error = null);
            }
          },
        ),
      ],
    );
  }
} 