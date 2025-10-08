import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecurringBookingScreen extends StatefulWidget {
  const RecurringBookingScreen({Key? key}) : super(key: key);

  @override
  State<RecurringBookingScreen> createState() => _RecurringBookingScreenState();
}

class _RecurringBookingScreenState extends State<RecurringBookingScreen> {
  String _selectedFrequency = 'Daily';
  String _selectedDay = 'Monday';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime? _endDate;
  String _selectedVehicleType = 'Bike';
  String _selectedPackageType = 'Small Package';
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _frequencies = [
    'Daily',
    'Weekly',
    'Monthly',
  ];

  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _vehicleTypes = [
    'Bike',
    'Car',
    'Van',
    'Truck',
  ];

  final List<String> _packageTypes = [
    'Small Package',
    'Medium Package',
    'Large Package',
    'Fragile',
    'Electronics',
    'Documents',
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Recurring Booking',
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
                'Set Up Recurring Delivery',
                style: GoogleFonts.poppins(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Schedule regular deliveries for your business needs',
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
                      // Frequency Selection
                      _buildSectionTitle('Frequency'),
                      SizedBox(height: 16.h),
                      _buildDropdown(
                        value: _selectedFrequency,
                        items: _frequencies,
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequency = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      
                      // Day Selection (for weekly)
                      if (_selectedFrequency == 'Weekly') ...[
                        _buildSectionTitle('Day of Week'),
                        SizedBox(height: 16.h),
                        _buildDropdown(
                          value: _selectedDay,
                          items: _weekDays,
                          onChanged: (value) {
                            setState(() {
                              _selectedDay = value!;
                            });
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                      
                      // Time Selection
                      _buildSectionTitle('Pickup Time'),
                      SizedBox(height: 16.h),
                      _buildTimePicker(),
                      SizedBox(height: 24.h),
                      
                      // Date Range
                      _buildSectionTitle('Date Range'),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              title: 'Start Date',
                              date: _startDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _startDate = date;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildDatePicker(
                              title: 'End Date',
                              date: _endDate,
                              onDateSelected: (date) {
                                setState(() {
                                  _endDate = date;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      
                      // Location Selection
                      _buildSectionTitle('Pickup Location'),
                      SizedBox(height: 16.h),
                      _buildLocationField(
                        controller: _pickupController,
                        hint: 'Enter pickup address',
                        icon: Icons.location_on,
                      ),
                      SizedBox(height: 24.h),
                      
                      _buildSectionTitle('Drop-off Location'),
                      SizedBox(height: 16.h),
                      _buildLocationField(
                        controller: _dropoffController,
                        hint: 'Enter drop-off address',
                        icon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 24.h),
                      
                      // Vehicle Selection
                      _buildSectionTitle('Vehicle Type'),
                      SizedBox(height: 16.h),
                      _buildDropdown(
                        value: _selectedVehicleType,
                        items: _vehicleTypes,
                        onChanged: (value) {
                          setState(() {
                            _selectedVehicleType = value!;
                          });
                        },
                      ),
                      SizedBox(height: 24.h),
                      
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
                          'Create Recurring',
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

  Widget _buildTimePicker() {
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: Theme.of(context).colorScheme.primary,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Text(
              _selectedTime.format(context),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String title,
    required DateTime? date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () => _selectDate(onDateSelected),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16.w,
                ),
                SizedBox(width: 8.w),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select Date',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: date != null
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          prefixIcon: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
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
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Describe your package (optional)',
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  bool _canProceed() {
    return _pickupController.text.isNotEmpty &&
        _dropoffController.text.isNotEmpty &&
        _endDate != null;
  }

  void _proceedToBooking() {
    // Navigate to booking details with recurring data
    Navigator.pushNamed(
      context,
      '/booking-details',
      arguments: {
        'isRecurring': true,
        'frequency': _selectedFrequency,
        'day': _selectedDay,
        'time': _selectedTime,
        'startDate': _startDate,
        'endDate': _endDate,
        'pickupLocation': _pickupController.text,
        'dropoffLocation': _dropoffController.text,
        'vehicleType': _selectedVehicleType,
        'packageType': _selectedPackageType,
        'description': _descriptionController.text,
      },
    );
  }
} 