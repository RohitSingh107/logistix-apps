import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'simple_location_selection_screen.dart';
import '../widgets/map_widget.dart';
import '../../../../core/config/app_theme.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  LatLng? _pickupLocation;
  LatLng? _dropLocation;
  String _pickupAddress = '';
  String _dropAddress = '';
  LatLng? _currentMapCenter;
  bool _isBottomSheetExpanded = true;
  
  // Default to Chennai center
  final LatLng _defaultLocation = LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _currentMapCenter = const LatLng(13.0827, 80.2707); // Default to Chennai
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
        
        // Center map on newly selected location
        _currentMapCenter = result['location'];
      });
    }
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];
    
    if (_pickupLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: _pickupLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.trip_origin,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
    
    if (_dropLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: _dropLocation!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
    
    return markers;
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

    // TODO: Implement booking logic here
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVehicleSelectionSheet(),
    );
  }

  Widget _buildVehicleSelectionSheet() {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Select Vehicle Type',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Vehicle options would go here
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking confirmed! Finding drivers...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Map View (Full Screen)
          if (_currentMapCenter != null)
            MapWidget(
              initialPosition: _currentMapCenter!,
              initialZoom: 13.0,
              markers: _buildMarkers(),
              showUserLocation: true,
            ),
          
          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.surface,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Spacer(),
                      if (_pickupLocation != null && _dropLocation != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.round),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.route,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${_calculateDistance()} km • ${_estimateTime()} min',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
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
          
          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: _isBottomSheetExpanded ? 0.35 : 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.sm),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      
                      // Location Cards
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            // Title
                            Text(
                              'Where are you going?',
                              style: theme.textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            
                            // Pickup location
                            _buildLocationTile(
                              icon: Icons.trip_origin,
                              iconColor: Colors.green,
                              title: 'Pickup Location',
                              subtitle: _pickupAddress ?? 'Select pickup location',
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SimpleLocationSelectionScreen(
                                      title: 'Set pickup location',
                                      initialLocation: _pickupLocation,
                                    ),
                                  ),
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    _pickupLocation = result['location'];
                                    _pickupAddress = result['address'];
                                  });
                                  _updateRoute();
                                }
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Drop location
                            _buildLocationTile(
                              icon: Icons.location_on,
                              iconColor: Colors.red,
                              title: 'Drop Location',
                              subtitle: _dropAddress ?? 'Select drop location',
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SimpleLocationSelectionScreen(
                                      title: 'Set drop-off location',
                                      initialLocation: _dropLocation,
                                    ),
                                  ),
                                );
                                
                                if (result != null) {
                                  setState(() {
                                    _dropLocation = result['location'];
                                    _dropAddress = result['address'];
                                  });
                                  _updateRoute();
                                }
                              },
                            ),
                            
                            const SizedBox(height: AppSpacing.lg),
                            
                            // Fare Estimate (if both locations selected)
                            if (_pickupLocation != null && _dropLocation != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.payments,
                                          color: theme.colorScheme.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Text(
                                          'Estimated Fare',
                                          style: theme.textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '₹${_estimateFare()}',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                            ],
                            
                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (_pickupLocation != null && _dropLocation != null) 
                                  ? _confirmBooking 
                                  : null,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                                child: Text(
                                  (_pickupLocation == null || _dropLocation == null)
                                    ? 'Select Locations'
                                    : 'Choose Vehicle',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
              );
            },
          ),
        ],
      ),
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
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(AppRadius.round),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
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
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDistance() {
    if (_pickupLocation == null || _dropLocation == null) return '0';
    
    final Distance distance = Distance();
    final double km = distance.as(
      LengthUnit.Kilometer,
      _pickupLocation!,
      _dropLocation!,
    );
    
    return km.toStringAsFixed(1);
  }

  int _estimateTime() {
    if (_pickupLocation == null || _dropLocation == null) return 0;
    
    final double km = double.parse(_calculateDistance());
    // Assuming average speed of 30 km/h in city
    return (km / 30 * 60).round();
  }

  int _estimateFare() {
    if (_pickupLocation == null || _dropLocation == null) return 0;
    
    final double km = double.parse(_calculateDistance());
    // Base fare: 40, Per km: 15
    return (40 + (km * 15)).round();
  }

  void _updateRoute() {
    // Update the map center to show both locations
    if (_pickupLocation != null && _dropLocation != null) {
      // Calculate the center point between pickup and drop
      final centerLat = (_pickupLocation!.latitude + _dropLocation!.latitude) / 2;
      final centerLng = (_pickupLocation!.longitude + _dropLocation!.longitude) / 2;
      setState(() {
        _currentMapCenter = LatLng(centerLat, centerLng);
      });
    } else if (_pickupLocation != null) {
      setState(() {
        _currentMapCenter = _pickupLocation;
      });
    } else if (_dropLocation != null) {
      setState(() {
        _currentMapCenter = _dropLocation;
      });
    }
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