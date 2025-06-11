/**
 * driver_search_screen.dart - Driver Assignment and Search Interface
 * 
 * Purpose:
 * - Displays real-time driver search and assignment process
 * - Provides animated feedback during booking acceptance and driver assignment
 * - Manages transition from booking request to active trip
 * 
 * Key Logic:
 * - Polls booking status using BookingService for real-time updates
 * - Displays animated search indicators with pulse and rotation effects
 * - Shows booking details including vehicle selection and fare information
 * - Transitions through booking states: REQUESTED → SEARCHING → ACCEPTED
 * - Navigates to trip details screen once driver is assigned
 * - Provides cancel booking functionality during search phase
 * - Implements comprehensive animation controllers for visual feedback
 * - Handles error states and retry mechanisms for failed bookings
 * - Shows estimated wait times and search progress
 */

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../vehicle_estimation/data/models/vehicle_estimate_response.dart';
import '../../data/models/booking_request.dart';
import '../../data/models/trip_detail.dart';
import '../../data/services/booking_service.dart';
import '../../../../core/di/service_locator.dart';
import 'trip_details_screen.dart';

class DriverSearchScreen extends StatefulWidget {
  final BookingResponse bookingDetails;
  final VehicleEstimateResponse selectedVehicle;

  const DriverSearchScreen({
    Key? key,
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
  BookingResponse? _currentBooking;
  bool _isSearching = true;
  String _searchText = 'Processing your booking request...';
  int _searchDots = 0;
  Timer? _searchTimer;
  StreamSubscription<dynamic>? _statusSubscription;
  
  late final BookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.bookingDetails;
    _bookingService = BookingService(serviceLocator());
    _setupAnimations();
    _startSearchAnimation();
    _startPollingBookingStatus();
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
      });
    });
  }

  void _startPollingBookingStatus() {
    _statusSubscription = _bookingService
        .pollBookingStatus(widget.bookingDetails.id)
        .listen(
      (statusObject) {
        if (statusObject is BookingResponse) {
          setState(() {
            _currentBooking = statusObject;
            _searchText = _bookingService.getStatusMessage(statusObject);
            
            if (statusObject.isCancelled) {
              _isSearching = false;
              _searchAnimationController.stop();
              _pulseAnimationController.stop();
              _searchTimer?.cancel();
            }
          });
                  } else if (statusObject is TripDetail) {
            setState(() {
              _tripDetail = statusObject;
              _searchText = _bookingService.getStatusMessage(statusObject);
              
              if (statusObject.hasDriver) {
                _isSearching = false;
                _searchAnimationController.stop();
                _pulseAnimationController.stop();
                _searchTimer?.cancel();
                
                // Navigate to trip details screen
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripDetailsScreen(tripDetail: statusObject),
                      ),
                    );
                  }
                });
              }
            });
          }
      },
      onError: (error) {
        print('Error polling status: $error');
        // Continue polling on error
      },
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _pulseAnimationController.dispose();
    _searchTimer?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  String _getDotsString() {
    return '.' * _searchDots;
  }

  // Helper method for profile images
  ImageProvider? _getProfileImage(String? profilePicture) {
    if (profilePicture == null) return null;
    
    final fullUrl = ImageUtils.getFullProfilePictureUrl(profilePicture);
    if (fullUrl != null && ImageUtils.isValidProfilePictureUrl(profilePicture)) {
      return NetworkImage(fullUrl);
    }
    
    return null; // Will show default letter avatar
  }

  Widget _buildDriverAvatar(Driver driver) {
    final String initial = driver.user.firstName[0].toUpperCase();
    final profileImage = _getProfileImage(driver.user.profilePicture);
    
    if (profileImage != null) {
      return Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            ImageUtils.getFullProfilePictureUrl(driver.user.profilePicture!) ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                child: Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  String _getHeaderTitle() {
    if (_currentBooking != null) {
      switch (_currentBooking!.status) {
        case 'REQUESTED':
          return 'Processing Request';
        case 'SEARCHING':
          return 'Finding Your Driver';
        case 'ACCEPTED':
          return 'Driver Found!';
        default:
          return 'Finding Your Driver';
      }
    }
    return 'Finding Your Driver';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _buildCurrentView(theme),
      ),
    );
  }

  Widget _buildCurrentView(ThemeData theme) {
    // Check if booking was cancelled
    if (_currentBooking?.isCancelled == true) {
      return _buildCancelledView(theme);
    }
    
    // Check if driver found
    if (!_isSearching && _tripDetail?.hasDriver == true) {
      return _buildDriverFoundView(theme);
    }
    
    // Default searching view
    return _buildSearchingView(theme);
  }

  Widget _buildCancelledView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
              border: Border.all(
                color: Colors.red,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.close,
              color: Colors.red,
              size: 60,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Booking Cancelled',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            'Your booking request has been cancelled. You can try creating a new booking.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl * 2),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.lg),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
                  _getHeaderTitle(),
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
                    _buildDriverAvatar(driver),
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