import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PackageDetailsScreen extends StatefulWidget {
  const PackageDetailsScreen({Key? key}) : super(key: key);

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  
  String _selectedPackageType = 'General';
  String _selectedFragility = 'Not Fragile';
  bool _isFragile = false;
  bool _isExpress = false;
  bool _requiresSignature = false;
  bool _requiresInsurance = false;

  final List<String> _packageTypes = [
    'General',
    'Electronics',
    'Documents',
    'Clothing',
    'Food',
    'Furniture',
    'Automotive',
    'Medical',
    'Cosmetics',
    'Books',
  ];

  final List<String> _fragilityLevels = [
    'Not Fragile',
    'Slightly Fragile',
    'Fragile',
    'Very Fragile',
    'Extremely Fragile',
  ];

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Package Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Package Information',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Provide detailed information about your package',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 24.h),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Package Type
                      _buildSectionTitle('Package Type'),
                      SizedBox(height: 16.h),
                      _buildDropdown(
                        value: _selectedPackageType,
                        items: _packageTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedPackageType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      // Dimensions
                      _buildSectionTitle('Dimensions & Weight'),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _lengthController,
                              label: 'Length (cm)',
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildInputField(
                              controller: _widthController,
                              label: 'Width (cm)',
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildInputField(
                              controller: _heightController,
                              label: 'Height (cm)',
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        hint: '0.0',
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 24.h),
                      
                      // Fragility
                      _buildSectionTitle('Fragility Level'),
                      SizedBox(height: 16.h),
                      _buildDropdown(
                        value: _selectedFragility,
                        items: _fragilityLevels,
                        onChanged: (value) {
                          setState(() {
                            _selectedFragility = value!;
                            _isFragile = value != 'Not Fragile';
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      // Package Value
                      _buildSectionTitle('Declared Value'),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: _valueController,
                        label: 'Value (₹)',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        prefix: '₹',
                      ),
                      SizedBox(height: 24.h),
                      
                      // Special Requirements
                      _buildSectionTitle('Special Requirements'),
                      SizedBox(height: 16.h),
                      _buildSwitchTile(
                        title: 'Express Delivery',
                        subtitle: 'Faster delivery with priority handling',
                        value: _isExpress,
                        onChanged: (value) {
                          setState(() {
                            _isExpress = value;
                          });
                        },
                      ),
                      _buildSwitchTile(
                        title: 'Signature Required',
                        subtitle: 'Recipient must sign upon delivery',
                        value: _requiresSignature,
                        onChanged: (value) {
                          setState(() {
                            _requiresSignature = value;
                          });
                        },
                      ),
                      _buildSwitchTile(
                        title: 'Insurance',
                        subtitle: 'Additional insurance coverage',
                        value: _requiresInsurance,
                        onChanged: (value) {
                          setState(() {
                            _requiresInsurance = value;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      // Description
                      _buildSectionTitle('Package Description'),
                      SizedBox(height: 16.h),
                      _buildDescriptionField(),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
              
              // Action Buttons
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _canProceed() ? _proceedToBooking : null,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputType keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              prefixText: prefix,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _descriptionController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Describe your package contents...',
          hintStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.w),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  bool _canProceed() {
    return _weightController.text.isNotEmpty &&
        _lengthController.text.isNotEmpty &&
        _widthController.text.isNotEmpty &&
        _heightController.text.isNotEmpty;
  }

  void _proceedToBooking() {
    // Navigate to booking details with package information
    Navigator.pushNamed(
      context,
      '/booking-details',
      arguments: {
        'packageType': _selectedPackageType,
        'fragility': _selectedFragility,
        'isFragile': _isFragile,
        'dimensions': {
          'length': double.tryParse(_lengthController.text) ?? 0,
          'width': double.tryParse(_widthController.text) ?? 0,
          'height': double.tryParse(_heightController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0,
        },
        'value': double.tryParse(_valueController.text) ?? 0,
        'isExpress': _isExpress,
        'requiresSignature': _requiresSignature,
        'requiresInsurance': _requiresInsurance,
        'description': _descriptionController.text,
      },
    );
  }
} 