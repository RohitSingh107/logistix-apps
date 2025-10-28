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

  Widget _buildIndianFlag() {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use external error if provided, otherwise use internal validation error
    final errorMessage = widget.errorText ?? _error;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: errorMessage != null 
                  ? theme.colorScheme.error 
                  : Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Mobile number',
              labelStyle: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 0, right: 8),
                child: _buildIndianFlag(),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 20,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 16,
              ),
              errorText: errorMessage,
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
        ),
      ],
    );
  }
} 