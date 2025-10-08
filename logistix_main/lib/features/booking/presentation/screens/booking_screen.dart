/// booking_screen.dart - Main Booking Creation Interface
/// 
/// Purpose:
/// - Provides comprehensive interface for creating new bookings
/// - Handles pickup and dropoff location selection
/// - Manages vehicle estimation and selection process
/// 
/// Key Logic:
/// - Location selection for pickup and dropoff points using LocationSelectionScreen
/// - Vehicle estimation fetching through GetVehicleEstimates use case
/// - Real-time fare calculation based on selected locations
/// - Vehicle type selection with pricing display
/// - Booking validation before proceeding to details screen
/// - Error handling for estimation failures with fallback data
/// - Map integration for visual location representation
/// - Progress states for loading and estimation processes
/// - Navigation to BookingDetailsScreen upon confirmation

import 'package:flutter/material.dart';
import 'simple_location_selection_screen.dart';
import 'booking_details_screen.dart';
import '../widgets/map_widget.dart';
import '../widgets/ola_map_widget.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/services/map_service_interface.dart';
import '../../../../core/di/service_locator.dart';
import '../../../vehicle_estimation/domain/usecases/get_vehicle_estimates.dart';
import '../../../vehicle_estimation/data/models/vehicle_estimate_response.dart';
import '../../../vehicle_estimation/presentation/widgets/vehicle_estimate_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  MapLatLng? _pickupLocation;
  MapLatLng? _dropLocation;
  String _pickupAddress = '';
  String _dropAddress = '';
  
  // Vehicle estimation
  List<VehicleEstimateResponse> _vehicleEstimates = [];
  VehicleEstimateResponse? _selectedVehicle;
  bool _isLoadingEstimates = false;
  String? _estimationError;
  bool _usingFallbackData = false;
  
  late final GetVehicleEstimates _getVehicleEstimates;

  @override
  void initState() {
    super.initState();
    _getVehicleEstimates = serviceLocator<GetVehicleEstimates>();
  }

  Future<void> _selectLocation(bool isPickup) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => SimpleLocationSelectionScreen(
          title: isPickup ? 'Set pickup location' : 'Set drop-off location',
          initialLocation: isPickup ? _pickupLocation : _dropLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isPickup) {
          _pickupLocation = result['location'];
          _pickupAddress = result['address'];
        } else {
          _dropLocation = result['location'];
          _dropAddress = result['address'];
        }
      });
      
      // Fetch vehicle estimates if both locations are selected
      if (_pickupLocation != null && _dropLocation != null) {
        _fetchVehicleEstimates();
      }
    }
  }

  Future<void> _fetchVehicleEstimates() async {
    if (_pickupLocation == null || _dropLocation == null) return;

    setState(() {
      _isLoadingEstimates = true;
      _estimationError = null;
      _vehicleEstimates.clear();
      _selectedVehicle = null;
      _usingFallbackData = false;
    });

    try {
      final estimates = await _getVehicleEstimates(
        pickupLatitude: _pickupLocation!.lat,
        pickupLongitude: _pickupLocation!.lng,
        dropoffLatitude: _dropLocation!.lat,
        dropoffLongitude: _dropLocation!.lng,
      );

      setState(() {
        _vehicleEstimates = estimates;
        _isLoadingEstimates = false;
        _usingFallbackData = estimates.isNotEmpty && estimates.first.vehicleTitle.contains('Two Wheeler');
        // Auto-select the first vehicle if available
        if (estimates.isNotEmpty) {
          _selectedVehicle = estimates.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingEstimates = false;
        _estimationError = 'Unable to get live estimates. Showing standard rates.';
        _usingFallbackData = true;
      });
      print('Error fetching vehicle estimates: $e');
    }
  }

  void _confirmBooking() {
    if (_pickupLocation == null || _dropLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both pickup and drop locations'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Navigate to booking details screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(
          pickupLocation: _pickupLocation!,
          dropLocation: _dropLocation!,
          pickupAddress: _pickupAddress,
          dropAddress: _dropAddress,
          selectedVehicle: _selectedVehicle!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book a Ride',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'scheduled':
                  Navigator.pushNamed(context, '/scheduled-booking');
                  break;
                case 'recurring':
                  Navigator.pushNamed(context, '/recurring-booking');
                  break;
                case 'package':
                  Navigator.pushNamed(context, '/package-details');
                  break;
                case 'support':
                  Navigator.pushNamed(context, '/support-center');
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'scheduled',
                child: Row(
                  children: [
                    Icon(Icons.schedule),
                    SizedBox(width: 8),
                    Text('Scheduled Booking'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'recurring',
                child: Row(
                  children: [
                    Icon(Icons.repeat),
                    SizedBox(width: 8),
                    Text('Recurring Booking'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'package',
                child: Row(
                  children: [
                    Icon(Icons.inventory),
                    SizedBox(width: 8),
                    Text('Package Details'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'support',
                child: Row(
                  children: [
                    Icon(Icons.support_agent),
                    SizedBox(width: 8),
                    Text('Support'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Where are you going?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Pickup location
                  _buildLocationTile(
                    icon: Icons.trip_origin,
                    iconColor: Colors.green,
                    title: 'Pickup Location',
                    subtitle: _pickupAddress.isNotEmpty ? _pickupAddress : 'Select pickup location',
                    onTap: () => _selectLocation(true),
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Drop location
                  _buildLocationTile(
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: 'Drop Location',
                    subtitle: _dropAddress.isNotEmpty ? _dropAddress : 'Select drop location',
                    onTap: () => _selectLocation(false),
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Trip info (if both locations selected)
                  if (_pickupLocation != null && _dropLocation != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.straighten,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${_calculateDistance()} km',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Distance',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 30,
                            width: 1,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
                          Column(
                            children: [
                              Icon(
                                Icons.access_time,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${_estimateTime()} min',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Duration',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  
                  // Available Vehicles Section
                  if (_pickupLocation != null && _dropLocation != null) ...[
                    Text(
                      'Available Vehicles',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Fallback data notification
                    if (_usingFallbackData && _vehicleEstimates.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber[700],
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'Showing standard rates. Live estimates temporarily unavailable.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Loading state
                    if (_isLoadingEstimates) ...[
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Getting vehicle estimates...',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ]
                    
                    // Error state
                    else if (_estimationError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: theme.colorScheme.error.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _estimationError!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ElevatedButton(
                              onPressed: _fetchVehicleEstimates,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ]
                    
                    // Vehicle estimates
                    else if (_vehicleEstimates.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vehicleEstimates.length,
                        itemBuilder: (context, index) {
                          final estimate = _vehicleEstimates[index];
                          return VehicleEstimateCard(
                            estimate: estimate,
                            isSelected: _selectedVehicle == estimate,
                            onTap: () {
                              setState(() {
                                _selectedVehicle = estimate;
                              });
                            },
                          );
                        },
                      ),
                      
                      // Distance and Duration Info
                      if (_selectedVehicle != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildDistanceDurationInfo(theme, _selectedVehicle!),
                      ],
                    ]
                    
                    // No estimates available
                    else ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No vehicles available for this route',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Add bottom padding for the fixed button
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Fixed confirmation button at bottom
      bottomNavigationBar: (_pickupLocation != null && _dropLocation != null && _vehicleEstimates.isNotEmpty)
          ? Container(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
                top: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedVehicle != null ? _confirmBooking : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedVehicle != null 
                        ? 'Confirm Booking • ₹${_selectedVehicle!.estimatedFare.toStringAsFixed(0)}'
                        : 'Select a Vehicle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDistance() {
    if (_pickupLocation == null || _dropLocation == null) return '0';
    
    // Use Haversine formula for distance calculation
    const double R = 6371; // Earth's radius in kilometers
    
    double lat1Rad = _pickupLocation!.lat * (3.14159265359 / 180);
    double lat2Rad = _dropLocation!.lat * (3.14159265359 / 180);
    double deltaLatRad = (_dropLocation!.lat - _pickupLocation!.lat) * (3.14159265359 / 180);
    double deltaLngRad = (_dropLocation!.lng - _pickupLocation!.lng) * (3.14159265359 / 180);

    double a = (deltaLatRad / 2).abs() * (deltaLatRad / 2).abs() +
        lat1Rad.abs() * lat2Rad.abs() *
        (deltaLngRad / 2).abs() * (deltaLngRad / 2).abs();
    double c = 2 * (a > 1 ? 1 : a);

    double km = R * c;
    return km.toStringAsFixed(1);
  }

  int _estimateTime() {
    if (_pickupLocation == null || _dropLocation == null) return 0;
    
    final double km = double.parse(_calculateDistance());
    // Assuming average speed of 30 km/h in city
    return (km / 30 * 60).round();
  }

  Widget _buildDistanceDurationInfo(ThemeData theme, VehicleEstimateResponse vehicle) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // First Row: Distance and Pickup Time
          Row(
            children: [
              // Distance Section
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      Icons.straighten,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${vehicle.estimatedDistance?.toStringAsFixed(1) ?? "0.0"} km',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Distance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Vertical Divider
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
              
              // Pickup Time Section
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${vehicle.pickupReachTime} min',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Pickup Time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Horizontal Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          
          // Second Row: Trip Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Trip Duration: ${vehicle.estimatedDuration ?? vehicle.pickupReachTime} min',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for dotted line
class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 5;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 