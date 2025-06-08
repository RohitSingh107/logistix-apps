import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/config/app_theme.dart';
import '../../../vehicle_estimation/data/models/vehicle_estimate_response.dart';
import '../../data/models/booking_request.dart';
import '../../data/models/trip_detail.dart';
import '../../data/services/booking_service.dart';
import '../../../../core/di/service_locator.dart';

class DriverSearchScreen extends StatefulWidget {
  final int tripId;
  final BookingResponse bookingDetails;
  final VehicleEstimateResponse selectedVehicle;

  const DriverSearchScreen({
    Key? key,
    required this.tripId,
    required this.bookingDetails,
    required this.selectedVehicle,
  }) : super(key: key);

  @override
  State<DriverSearchScreen> createState() => _DriverSearchScreenState();
}

class _DriverSearchScreenState extends State<DriverSearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _pulseAnimation;
  
  TripDetail? _tripDetail;
  bool _isSearching = true;
  String _searchText = 'Looking for drivers nearby...';
  int _searchDots = 0;
  Timer? _searchTimer;
  StreamSubscription<TripDetail>? _tripStatusSubscription;
  
  late final BookingService _bookingService;

  final List<String> _searchMessages = [
    'Looking for drivers nearby',
    'Finding the best driver for you',
    'Connecting with available drivers',
    'Almost there, hang tight',
  ];

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService(serviceLocator());
    _setupAnimations();
    _startSearchAnimation();
    _startPollingTripStatus();
  }

  void _setupAnimations() {
    _searchAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchAnimationController.repeat(reverse: true);
    _pulseAnimationController.repeat(reverse: true);
  }

  void _startSearchAnimation() {
    _searchTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isSearching) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _searchDots = (_searchDots + 1) % 4;
        if (_searchDots == 0) {
          final currentIndex = _searchMessages.indexOf(_searchText.split('.').first);
          final nextIndex = (currentIndex + 1) % _searchMessages.length;
          _searchText = _searchMessages[nextIndex];
        }
      });
    });
  }

  void _startPollingTripStatus() {
    _tripStatusSubscription = _bookingService
        .pollTripStatus(widget.tripId)
        .listen(
      (tripDetail) {
        setState(() {
          _tripDetail = tripDetail;
          if (tripDetail.hasDriver) {
            _isSearching = false;
            _searchAnimationController.stop();
            _pulseAnimationController.stop();
            _searchTimer?.cancel();
          }
        });
      },
      onError: (error) {
        print('Error polling trip status: $error');
        // Continue polling on error
      },
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _pulseAnimationController.dispose();
    _searchTimer?.cancel();
    _tripStatusSubscription?.cancel();
    super.dispose();
  }

  String _getDotsString() {
    return '.' * _searchDots;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _isSearching 
          ? _buildSearchingView(theme)
          : _buildDriverFoundView(theme),
      ),
    );
  }

  Widget _buildSearchingView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Finding Your Driver',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          
          const Spacer(),
          
          // Animated search indicator
          AnimatedBuilder(
            animation: _searchAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _searchAnimation.value,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 200 * _pulseAnimation.value,
                      height: 200 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.3),
                            theme.colorScheme.primary.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Search text with dots
          Text(
            '$_searchText${_getDotsString()}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'We\'re connecting you with the best available driver in your area',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const Spacer(),
          
          // Booking summary card
          _buildBookingSummaryCard(theme),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showCancelDialog(theme);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.lg),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
              ),
              child: Text(
                'Cancel Booking',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverFoundView(ThemeData theme) {
    final driver = _tripDetail!.driver!;
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Driver Found!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Success animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.1),
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.green,
              size: 60,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Driver details card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Driver photo and basic info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: driver.user.profilePicture != null
                          ? NetworkImage(driver.user.profilePicture!)
                          : null,
                      child: driver.user.profilePicture == null
                          ? Text(
                              driver.user.firstName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.user.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                driver.rating.toStringAsFixed(1),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'License: ${driver.licenseNumber}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Contact buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality
                        },
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement message functionality
                        },
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Trip status
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Trip Status: ${_tripDetail!.status}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your driver is on the way to pick up your goods',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Track order button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to tracking screen
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.lg),
              ),
              child: const Text(
                'Track Your Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummaryCard(ThemeData theme) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          Row(
            children: [
              Text(
                widget.selectedVehicle.vehicleIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.selectedVehicle.vehicleTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '₹${widget.selectedVehicle.estimatedFare.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          _buildSummaryRow(
            theme,
            Icons.trip_origin,
            Colors.green,
            'Pickup',
            widget.bookingDetails.pickupAddress,
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          _buildSummaryRow(
            theme,
            Icons.location_on,
            Colors.red,
            'Drop',
            widget.bookingDetails.dropoffAddress,
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          _buildSummaryRow(
            theme,
            Icons.inventory_2,
            theme.colorScheme.primary,
            'Goods',
            '${widget.bookingDetails.goodsType} - ${widget.bookingDetails.goodsQuantity}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    IconData icon,
    Color iconColor,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
              Navigator.pop(context); // Go back to booking screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }
} 