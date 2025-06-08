import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking_list_response.dart';
import '../../data/models/trip_detail.dart';
import 'trip_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late final BookingService _bookingService;
  late final TabController _tabController;
  
  List<BookingListItem> _bookings = [];
  List<TripDetail> _trips = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService(serviceLocator());
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bookingListResponse = await _bookingService.getBookingList();
      final tripList = await _bookingService.getTripList();
      
      setState(() {
        _bookings = bookingListResponse.bookingRequests;
        _trips = tripList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          'Your Orders',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'All Bookings',
            ),
            Tab(
              icon: Icon(Icons.local_shipping),
              text: 'Active Trips',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState(theme)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsTab(theme),
                    _buildTripsTab(theme),
                  ],
                ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load orders',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please check your internet connection and try again.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsTab(ThemeData theme) {
    if (_bookings.isEmpty) {
      return _buildEmptyState(
        theme,
        icon: Icons.receipt_long,
        title: 'No Bookings Yet',
        message: 'Your booking history will appear here once you make your first order.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingCard(theme, booking);
        },
      ),
    );
  }

  Widget _buildTripsTab(ThemeData theme) {
    final activeTrips = _trips.where((trip) => 
        trip.status == 'ACCEPTED' || 
        trip.status == 'LOADING_STARTED' || 
        trip.status == 'LOADING_DONE' ||
        trip.status == 'REACHED_DESTINATION' ||
        trip.status == 'UNLOADING_STARTED'
    ).toList();

    if (activeTrips.isEmpty) {
      return _buildEmptyState(
        theme,
        icon: Icons.local_shipping,
        title: 'No Active Trips',
        message: 'You have no ongoing deliveries at the moment.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: activeTrips.length,
        itemBuilder: (context, index) {
          final trip = activeTrips[index];
          return _buildTripCard(theme, trip);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(ThemeData theme, BookingListItem booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _onBookingTapped(booking),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: booking.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: booking.statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      booking.statusMessage,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: booking.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(booking.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Route information
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.shortPickupAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          booking.shortDropoffAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Bottom row with goods and fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${booking.goodsType} • ${booking.goodsQuantity}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${booking.estimatedFare.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(ThemeData theme, TripDetail trip) {
    final booking = trip.bookingRequest;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _onTripTapped(trip),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with trip status and driver info
              Row(
                children: [
                  _buildDriverAvatar(theme, trip.driver),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driver?.user.fullName ?? 'Driver',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              trip.driver?.rating.toStringAsFixed(1) ?? '0.0',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTripStatusColor(trip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: _getTripStatusColor(trip.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getTripStatusMessage(trip.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getTripStatusColor(trip.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              
              // Route information
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getShortAddress(booking.pickupAddress),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _getShortAddress(booking.dropoffAddress),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Show call/message buttons only if trip is not completed and payment not done
              if (!(trip.isCompleted && trip.isPaymentDone)) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement message functionality
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onBookingTapped(BookingListItem booking) {
    if (booking.tripId != null && booking.isAccepted) {
      // Navigate to trip details if booking is accepted and has trip_id
      _navigateToTripDetails(booking.tripId!);
    } else {
      // Navigate to booking details for other cases
      _navigateToBookingDetails(booking);
    }
  }

  void _onTripTapped(TripDetail trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(tripDetail: trip),
      ),
    );
  }

  void _navigateToTripDetails(int tripId) async {
    try {
      final tripDetail = await _bookingService.getTripDetail(tripId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(tripDetail: tripDetail),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trip details: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToBookingDetails(BookingListItem booking) {
    // Since BookingDetailsScreen expects different parameters, 
    // we'll show a simple dialog for now or create a booking details viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${booking.statusMessage}'),
            const SizedBox(height: AppSpacing.sm),
            Text('From: ${booking.pickupAddress}'),
            const SizedBox(height: AppSpacing.sm),
            Text('To: ${booking.dropoffAddress}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Goods: ${booking.goodsType} (${booking.goodsQuantity})'),
            const SizedBox(height: AppSpacing.sm),
            Text('Fare: ₹${booking.estimatedFare.toStringAsFixed(0)}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Payment: ${booking.paymentMode}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getShortAddress(String address) {
    final parts = address.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : address;
  }

  Widget _buildDriverAvatar(ThemeData theme, Driver? driver) {
    final String initial = driver?.user.firstName.substring(0, 1).toUpperCase() ?? 'D';
    
    if (driver?.user.profilePicture != null && driver!.user.profilePicture!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: ClipOval(
          child: Image.network(
            'http://localhost:8000${driver.user.profilePicture}',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Color _getTripStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return const Color(0xFF2196F3); // Blue
      case 'LOADING_STARTED':
      case 'UNLOADING_STARTED':
        return const Color(0xFFFF9800); // Orange
      case 'LOADING_DONE':
      case 'REACHED_DESTINATION':
        return const Color(0xFF4CAF50); // Green
      case 'COMPLETED':
        return const Color(0xFF4CAF50); // Green
      case 'CANCELLED':
        return const Color(0xFFE91E63); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String _getTripStatusMessage(String status) {
    switch (status) {
      case 'ACCEPTED':
        return 'On the way';
      case 'LOADING_STARTED':
        return 'Loading';
      case 'LOADING_DONE':
        return 'In transit';
      case 'REACHED_DESTINATION':
        return 'Arrived';
      case 'UNLOADING_STARTED':
        return 'Unloading';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }
} 