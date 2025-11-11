import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/vehicle.dart';
import 'add_driver_details_screen.dart';

class VehicleNumberScreen extends StatefulWidget {
  const VehicleNumberScreen({super.key});

  @override
  State<VehicleNumberScreen> createState() => _VehicleNumberScreenState();
}

class _VehicleNumberScreenState extends State<VehicleNumberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNumberController = TextEditingController();
  
  final VehicleFormData _formData = VehicleFormData();
  
  final List<String> _cities = [
    'Delhi NCR',
    'Mumbai',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Hyderabad',
    'Pune',
    'Ahmedabad',
  ];

  final List<String> _vehicleTypes = [
    '2W',
    '3W',
    '4W',
  ];

  final List<String> _bodyTypes = [
    'Scooter',
    'Motorcycle',
    'Auto Rickshaw',
    'Car',
    'SUV',
  ];

  final List<String> _fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'CNG',
  ];

  @override
  void initState() {
    super.initState();
    _vehicleNumberController.text = 'DL 12Sb7806'; // Pre-filled example
    _formData.vehicleNumber = 'DL 12Sb7806';
    _formData.rcDocumentUrl = 'uploaded';
    _formData.cityOfOperation = 'Delhi NCR';
    _formData.vehicleType = '2W';
    _formData.bodyType = 'Scooter';
    _formData.fuelType = 'Petrol';
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Vehicle Number',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.headset_mic_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            onPressed: () {
              // Handle support
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Number Field
              _buildFieldLabel('Vehicle Number*'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _vehicleNumberController,
                hintText: 'Vehicle Number',
                onChanged: (value) {
                  _formData.vehicleNumber = value;
                },
              ),
              const SizedBox(height: 24),

              // Vehicle RC Field
              _buildFieldLabel('Vehicle RC'),
              const SizedBox(height: 8),
              _buildRcUploadField(),
              const SizedBox(height: 24),

              // City of Operation Dropdown
              _buildFieldLabel('Select the city of operation'),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: _formData.cityOfOperation,
                items: _cities,
                onChanged: (value) {
                  setState(() {
                    _formData.cityOfOperation = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Vehicle Type Field
              _buildFieldLabel('Select Vehicle Type'),
              const SizedBox(height: 8),
              _buildEditableField(
                value: _formData.vehicleType,
                onTap: () => _showVehicleTypeDialog(),
              ),
              const SizedBox(height: 24),

              // Body Type Field
              _buildFieldLabel('Select the vehicle body type'),
              const SizedBox(height: 8),
              _buildEditableField(
                value: _formData.bodyType,
                onTap: () => _showBodyTypeDialog(),
              ),
              const SizedBox(height: 24),

              // Fuel Type Dropdown
              _buildFieldLabel('Select the vehicle fuel type'),
              const SizedBox(height: 8),
              _buildDropdownField(
                value: _formData.fuelType,
                items: _fuelTypes,
                onChanged: (value) {
                  setState(() {
                    _formData.fuelType = value!;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildRcUploadField() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Uploaded',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 16,
            ),
            onPressed: () {
              // Handle RC upload/edit
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Vehicle Type',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _vehicleTypes.map((type) {
            return ListTile(
              title: Text(type, style: GoogleFonts.inter()),
              onTap: () {
                setState(() {
                  _formData.vehicleType = type;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showBodyTypeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Body Type',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _bodyTypes.map((type) {
            return ListTile(
              title: Text(type, style: GoogleFonts.inter()),
              onTap: () {
                setState(() {
                  _formData.bodyType = type;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_formData.vehicleNumber.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddDriverDetailsScreen(formData: _formData),
        ),
      );
    }
  }
}
