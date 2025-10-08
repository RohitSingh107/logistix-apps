/// trip_details_screen.dart - Trip Details Display
/// 
/// Purpose:
/// - Displays comprehensive information about active or completed trips
/// - Provides real-time trip tracking and status updates
/// - Handles trip-related actions and user interactions
/// 
/// Key Logic:
/// - Real-time trip status monitoring and updates
/// - Live driver location tracking with map visualization
/// - Trip timeline with pickup, transit, and delivery phases
/// - Driver information display with contact options
/// - Trip route visualization on interactive map
/// - Status-specific action buttons (cancel, contact, rate)
/// - Integration with trip repository for live data updates
/// - Push notification handling for trip status changes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/image_utils.dart';
import '../../data/models/trip_detail.dart';
import 'dart:async';
import '../../data/services/booking_service.dart';
import '../../../../core/di/service_locator.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripDetail tripDetail;

  const TripDetailsScreen({
    Key? key,
    required this.tripDetail,
  }) : super(key: key);

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen>
    with TickerProviderStateMixin {
  
  late TripDetail _currentTrip;
  Timer? _statusTimer;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  late final BookingService _bookingService;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.tripDetail;
    _bookingService = BookingService(serviceLocator());
    
    _setupAnimations();
    _startStatusPolling();
  }

  void _setupAnimations() {
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    if (!_currentTrip.isCompleted && !_currentTrip.isCancelled) {
      _pulseAnimationController.repeat(reverse: true);
    }
  }

  void _startStatusPolling() {
    if (_currentTrip.isCompleted || _currentTrip.isCancelled) return;
    
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final updatedTrip = await _bookingService.getTripDetail(_currentTrip.id);
        if (mounted) {
          setState(() {
            _currentTrip = updatedTrip;
          });
          
          if (_currentTrip.isCompleted || _currentTrip.isCancelled) {
            _pulseAnimationController.stop();
            timer.cancel();
          }
        }
      } catch (e) {
        print('Error polling trip status: $e');
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  // Status helper methods
  String _getStatusText() {
    switch (_currentTrip.status) {
      case 'ACCEPTED':
        return 'Accepted by Driver';
      case 'TRIP_STARTED':
        return 'Trip Started';
      case 'LOADING_STARTED':
        return 'Loading Started';
      case 'LOADING_DONE':
        return 'Loading Done';
      case 'REACHED_DESTINATION':
        return 'Driver Reached Destination';
      case 'UNLOADING_STARTED':
        return 'Unloading Started';
      case 'UNLOADING_DONE':
        return 'Unloading Complete';
      case 'COMPLETED':
        return 'Trip Completed';
      case 'CANCELLED':
        return 'Trip Cancelled';
      default:
        return 'In Progress';
    }
  }

  String _getStatusDescription() {
    switch (_currentTrip.status) {
      case 'ACCEPTED':
        return 'Your driver has accepted the trip and is preparing for pickup';
      case 'TRIP_STARTED':
        return 'Driver has started the trip and is heading to pickup location';
      case 'LOADING_STARTED':
        return 'Driver has arrived and is loading your goods';
      case 'LOADING_DONE':
        return 'Goods have been loaded and driver is heading to destination';
      case 'REACHED_DESTINATION':
        return 'Driver has successfully reached the destination';
      case 'UNLOADING_STARTED':
        return 'Driver is unloading your goods at the destination';
      case 'UNLOADING_DONE':
        return 'Goods have been successfully unloaded at destination';
      case 'COMPLETED':
        return 'Trip completed successfully - all goods delivered';
      case 'CANCELLED':
        return 'This trip has been cancelled';
      default:
        return 'Trip is currently in progress';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentTrip.status) {
      case 'ACCEPTED':
        return Icons.person_pin;
      case 'TRIP_STARTED':
        return Icons.directions_car;
      case 'LOADING_STARTED':
        return Icons.download;
      case 'LOADING_DONE':
        return Icons.inventory;
      case 'REACHED_DESTINATION':
        return Icons.location_on;
      case 'UNLOADING_STARTED':
        return Icons.upload;
      case 'UNLOADING_DONE':
        return Icons.unarchive;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.local_shipping;
    }
  }

  Color _getStatusColor() {
    switch (_currentTrip.status) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'LOADING_STARTED':
      case 'UNLOADING_STARTED':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
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

  Widget _buildDriverProfileImage(ThemeData theme, Driver driver) {
    final String initial = driver.user.firstName.isNotEmpty 
        ? driver.user.firstName[0].toUpperCase()
        : 'D';
    
    final profileImage = _getProfileImage(driver.user.profilePicture);
    
    if (profileImage != null) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        child: ClipOval(
          child: Image.network(
            ImageUtils.getFullProfilePictureUrl(driver.user.profilePicture!) ?? '',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getStatusSteps() {
    return [
      {
        'status': 'ACCEPTED',
        'title': 'Accepted by Driver',
        'description': 'Your driver has accepted the trip',
        'icon': Icons.person_pin,
        'color': Colors.blue,
      },
      {
        'status': 'TRIP_STARTED',
        'title': 'Trip Started',
        'description': 'Driver is heading to pickup location',
        'icon': Icons.directions_car,
        'color': Colors.blue,
      },
      {
        'status': 'LOADING_STARTED',
        'title': 'Loading Started',
        'description': 'Driver is loading your goods',
        'icon': Icons.download,
        'color': Colors.orange,
      },
      {
        'status': 'LOADING_DONE',
        'title': 'Loading Done',
        'description': 'Goods loaded, heading to destination',
        'icon': Icons.inventory,
        'color': Colors.blue,
      },
      {
        'status': 'REACHED_DESTINATION',
        'title': 'Driver Reached Destination',
        'description': 'Driver has arrived at the destination',
        'icon': Icons.location_on,
        'color': Colors.blue,
      },
      {
        'status': 'UNLOADING_STARTED',
        'title': 'Unloading Started',
        'description': 'Driver is unloading your goods',
        'icon': Icons.upload,
        'color': Colors.orange,
      },
      {
        'status': 'UNLOADING_DONE',
        'title': 'Unloading Complete',
        'description': 'Goods successfully unloaded',
        'icon': Icons.unarchive,
        'color': Colors.blue,
      },
      {
        'status': 'COMPLETED',
        'title': 'Trip Completed',
        'description': 'Trip completed successfully',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'status': 'CANCELLED',
        'title': 'Trip Cancelled',
        'description': 'This trip has been cancelled',
        'icon': Icons.cancel,
        'color': Colors.red,
      },
    ];
  }

  int _getCurrentStatusIndex() {
    final steps = _getStatusSteps();
    for (int i = 0; i < steps.length; i++) {
      if (steps[i]['status'] == _currentTrip.status) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/support-center');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.support_agent),
      ),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentStatusCard(theme),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusProgressCards(theme),
                  const SizedBox(height: AppSpacing.lg),
                  if (_currentTrip.driver != null) ...[
                    _buildDriverCard(theme),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  _buildTripRouteCard(theme),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTripDetailsCard(theme),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPaymentCard(theme),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(theme),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      title: Text(
        'Trip #${_currentTrip.id}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentTrip.isCompleted || _currentTrip.isCancelled ? 1.0 : _pulseAnimation.value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor().withOpacity(0.2),
                    border: Border.all(
                      color: _getStatusColor(),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 30,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusDescription(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgressCards(ThemeData theme) {
    final steps = _getStatusSteps();
    final currentIndex = _getCurrentStatusIndex();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Progress',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = index < currentIndex;
          final isActive = index == currentIndex;
          final isCancelled = _currentTrip.isCancelled && step['status'] == 'CANCELLED';
          
          // Skip cancelled status if trip is not cancelled
          if (step['status'] == 'CANCELLED' && !_currentTrip.isCancelled) {
            return const SizedBox.shrink();
          }
          
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isCompleted || isActive || isCancelled)
                        ? (step['color'] as Color).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: (isCompleted || isActive || isCancelled)
                          ? (step['color'] as Color)
                          : Colors.grey,
                      width: isActive ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    (isCompleted && !isCancelled) ? Icons.check : step['icon'],
                    color: (isCompleted || isActive || isCancelled)
                        ? (step['color'] as Color)
                        : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Status content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: (isActive || isCancelled)
                          ? theme.colorScheme.surface
                          : theme.colorScheme.surface.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: (isActive || isCancelled)
                          ? Border.all(
                              color: (step['color'] as Color).withOpacity(0.3),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: (isCompleted || isActive || isCancelled)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: (isCompleted || isActive || isCancelled)
                                ? theme.colorScheme.onSurface
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: (isCompleted || isActive || isCancelled)
                                ? theme.colorScheme.onSurface.withOpacity(0.7)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
    final driver = _currentTrip.driver!;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Driver Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Driver photo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: _buildDriverProfileImage(theme, driver),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Driver info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.user.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '• ${driver.licenseNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Contact buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _callDriver(driver.user.phone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _messageDriver(driver.user.phone),
                  icon: const Icon(Icons.message, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripRouteCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Trip Route',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Pickup location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentTrip.bookingRequest.pickupAddress,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Destination location
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentTrip.bookingRequest.dropoffAddress,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Trip Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildDetailRow(theme, 'Sender', _currentTrip.bookingRequest.senderName),
          _buildDetailRow(theme, 'Receiver', _currentTrip.bookingRequest.receiverName),
          _buildDetailRow(theme, 'Goods', _currentTrip.bookingRequest.goodsType),
          
          if (_currentTrip.finalDistance != null)
            _buildDetailRow(theme, 'Distance', _currentTrip.finalDistance!),
          
          if (_currentTrip.finalDuration != null)
            _buildDetailRow(theme, 'Duration', _formatDuration(_currentTrip.finalDuration!)),
          
          _buildDetailRow(theme, 'Booked At', _formatDateTime(_currentTrip.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(': ', style: theme.textTheme.bodyMedium),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(ThemeData theme) {
    final booking = _currentTrip.bookingRequest;
    final finalFare = _currentTrip.finalFare ?? booking.estimatedFare;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                booking.paymentMode == 'WALLET' ? Icons.account_balance_wallet : Icons.payments,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Payment Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          _buildDetailRow(
            theme, 
            'Method', 
            booking.paymentMode == 'WALLET' ? 'Wallet' : 'Cash'
          ),
          
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Fare',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${finalFare.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          
          if (!_currentTrip.isPaymentDone) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pending,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Payment pending',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
        top: AppSpacing.sm,
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
      child: Row(
        children: [
          if (_currentTrip.driver != null) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _callDriver(_currentTrip.driver!.user.phone),
                icon: const Icon(Icons.phone),
                label: const Text('Call Driver'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(AppSpacing.md),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _shareTrip(),
              icon: const Icon(Icons.share),
              label: const Text('Share Trip'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Action methods
  Future<void> _callDriver(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _messageDriver(String phoneNumber) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch SMS app')),
        );
      }
    }
  }

  Future<void> _shareTrip() async {
    final tripInfo = '''
Trip Details - #${_currentTrip.id}
Status: ${_getStatusText()}
From: ${_currentTrip.bookingRequest.pickupAddress}
To: ${_currentTrip.bookingRequest.dropoffAddress}
Driver: ${_currentTrip.driver?.user.fullName ?? 'Not assigned'}
''';
    
    await Clipboard.setData(ClipboardData(text: tripInfo));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip details copied to clipboard')),
      );
    }
  }
} 