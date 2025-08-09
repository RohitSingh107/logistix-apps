/**
 * home_screen.dart - Main Application Home Interface
 * 
 * Purpose:
 * - Provides the main home screen with bottom navigation
 * - Serves as the primary dashboard for the logistics application
 * - Integrates multiple feature screens through bottom navigation
 * 
 * Key Logic:
 * - HomeScreen: Main container with bottom navigation bar
 * - HomePage: Dashboard with quick service access and recent activity
 * - Displays greeting message and booking call-to-action
 * - Shows quick service access buttons for common actions
 * - Lists vehicle categories for booking selection
 * - Displays recent booking activity with status information
 * - Provides navigation to booking screen via search bar tap
 * - Loads and displays recent bookings from BookingService
 * - Implements responsive design with proper spacing and theming
 */

import 'package:flutter/material.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../booking/presentation/screens/booking_screen.dart';
import '../../../booking/presentation/screens/orders_screen.dart';
import '../../../booking/presentation/screens/trip_details_screen.dart';
import '../../../booking/data/services/booking_service.dart';
import '../../../booking/data/models/booking_list_response.dart';
import '../../../support/presentation/screens/support_center_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  Widget _getScreen(int index) {
    try {
      switch (index) {
        case 0:
          return const HomePage();
        case 1:
          return const OrdersScreen();
        case 2:
          return const SupportCenterScreen();
        case 3:
          return const ProfileScreen();
        default:
          return const HomePage();
      }
    } catch (e) {
      print('Error creating screen for index $index: $e');
      return const Scaffold(
        body: Center(
          child: Text('Error loading screen'),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_currentIndex),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BookingService _bookingService;
  List<BookingListItem> _recentBookings = [];
  bool _isLoadingBookings = false;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService(serviceLocator());
    _loadRecentBookings();
  }

  Future<void> _loadRecentBookings() async {
    setState(() {
      _isLoadingBookings = true;
    });

    try {
      final bookingListResponse = await _bookingService.getBookingList();
      setState(() {
        // Sort by creation date (most recent first) and take only 3
        _recentBookings = bookingListResponse.bookingRequests
            .take(3)
            .toList();
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _recentBookings = [];
        _isLoadingBookings = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              
              // Main Search Bar
              _buildMainSearchBar(context),
              
              // Quick Service Access
              _buildQuickServiceAccess(context),
              
              // Vehicle Categories
              _buildVehicleCategories(context),
              
              // Recent Activity
              _buildRecentActivity(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Book a delivery service',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                // Navigate to notifications
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Where do you want to send?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Tap to select pickup and drop location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickServiceAccess(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Services',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  context,
                  icon: Icons.flash_on,
                  title: 'Express Delivery',
                  subtitle: 'Fast & reliable',
                  color: Colors.orange,
                  gradient: [Colors.orange.shade400, Colors.orange.shade600],
                  onTap: () => Navigator.pushNamed(context, '/booking'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildServiceCard(
                  context,
                  icon: Icons.shopping_bag,
                  title: 'Shop & Drop',
                  subtitle: 'We buy & deliver',
                  color: Colors.green,
                  gradient: [Colors.green.shade400, Colors.green.shade600],
                  onTap: () => Navigator.pushNamed(context, '/package-details'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildServiceCard(
                  context,
                  icon: Icons.schedule,
                  title: 'Scheduled Booking',
                  subtitle: 'Plan ahead',
                  color: Colors.blue,
                  gradient: [Colors.blue.shade400, Colors.blue.shade600],
                  onTap: () => Navigator.pushNamed(context, '/scheduled-booking'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildServiceCard(
                  context,
                  icon: Icons.repeat,
                  title: 'Recurring Booking',
                  subtitle: 'Regular deliveries',
                  color: Colors.purple,
                  gradient: [Colors.purple.shade400, Colors.purple.shade600],
                  onTap: () => Navigator.pushNamed(context, '/recurring-booking'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required List<Color> gradient,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCategories(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Vehicle Type',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildVehicleCard(
                  context,
                  icon: Icons.two_wheeler,
                  label: 'Bike',
                  subtitle: 'Small items',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildVehicleCard(
                  context,
                  icon: Icons.airport_shuttle,
                  label: 'Auto',
                  subtitle: 'Medium load',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildVehicleCard(
                  context,
                  icon: Icons.local_shipping,
                  label: 'Mini Truck',
                  subtitle: 'Large items',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to orders tab (index 1) in the home screen
                  final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeScreenState?._onItemTapped(1);
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_isLoadingBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recentBookings.isEmpty)
            _buildEmptyState(theme)
          else
            ..._recentBookings.map((booking) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildActivityItem(context, booking),
            )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No Recent Activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your recent bookings will appear here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, BookingListItem booking) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _onBookingTapped(booking),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
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
                color: booking.statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(booking.status),
                color: booking.statusColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.goodsType} to ${booking.shortDropoffAddress}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${booking.statusMessage} • ${DateFormat('MMM dd, HH:mm').format(booking.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${booking.estimatedFare.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'REQUESTED':
        return Icons.schedule;
      case 'SEARCHING':
        return Icons.search;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.info;
    }
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
    // Show booking details in a dialog for non-accepted bookings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', booking.statusMessage),
              _buildDetailRow('From', booking.pickupAddress),
              _buildDetailRow('To', booking.dropoffAddress),
              _buildDetailRow('Goods', '${booking.goodsType} (${booking.goodsQuantity})'),
              _buildDetailRow('Fare', '₹${booking.estimatedFare.toStringAsFixed(0)}'),
              _buildDetailRow('Payment', booking.paymentMode),
              _buildDetailRow('Created', DateFormat('MMM dd, yyyy at HH:mm').format(booking.createdAt)),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
} 