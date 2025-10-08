/// demo_navigation_screen.dart - Demo Navigation Screen
/// 
/// Purpose:
/// - Provides a centralized navigation hub for development and testing
/// - Allows developers to quickly access any screen in the app
/// - Useful for demo purposes and feature testing
/// 
/// Key Logic:
/// - Grid layout with navigation cards for each feature
/// - Each card navigates to a specific screen or feature
/// - Includes sample data creation for testing
/// - Provides quick access to all major app features
library;

import 'package:flutter/material.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/driver_model.dart';
import '../../../../core/models/user_model.dart';
import '../../../trip/presentation/screens/driver_trip_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../notifications/presentation/screens/alerts_screen.dart';
import '../../../profile/presentation/screens/create_profile_screen.dart';
import '../../../driver/presentation/screens/create_driver_profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../trip/presentation/screens/my_trips_screen.dart';
import '../../../booking/presentation/widgets/test_booking_acceptance.dart';

class DemoNavigationScreen extends StatelessWidget {
  const DemoNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Navigation'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.developer_mode,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Development & Demo Hub',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Navigate to any screen for testing and development purposes',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Navigation Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildNavigationCard(
                  context,
                  'Driver Trip',
                  Icons.local_taxi,
                  Colors.blue,
                  () => _navigateToDriverTrip(context),
                ),
                _buildNavigationCard(
                  context,
                  'Wallet',
                  Icons.account_balance_wallet,
                  Colors.green,
                  () => Navigator.pushNamed(context, '/wallet'),
                ),
                _buildNavigationCard(
                  context,
                  'Notifications',
                  Icons.notifications,
                  Colors.orange,
                  () => Navigator.pushNamed(context, '/alerts'),
                ),
                _buildNavigationCard(
                  context,
                  'My Trips',
                  Icons.history,
                  Colors.purple,
                  () => Navigator.pushNamed(context, '/trips'),
                ),
                _buildNavigationCard(
                  context,
                  'Create Profile',
                  Icons.person_add,
                  Colors.teal,
                  () => Navigator.pushNamed(context, '/profile/create', arguments: {'phone': '9876543210'}),
                ),
                _buildNavigationCard(
                  context,
                  'Create Driver',
                  Icons.drive_eta,
                  Colors.indigo,
                  () => Navigator.pushNamed(context, '/driver/create'),
                ),
                _buildNavigationCard(
                  context,
                  'Settings',
                  Icons.settings,
                  Colors.grey,
                  () => Navigator.pushNamed(context, '/settings'),
                ),
                _buildNavigationCard(
                  context,
                  'Test Booking',
                  Icons.add_shopping_cart,
                  Colors.red,
                  () => _showTestBookingDialog(context),
                ),
                _buildNavigationCard(
                  context,
                  'Test Accept Booking',
                  Icons.check_circle,
                  Colors.deepPurple,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestBookingAcceptance(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildActionChip(
                        context,
                        'Clear Cache',
                        Icons.clear_all,
                        () => _clearCache(context),
                      ),
                      _buildActionChip(
                        context,
                        'Show Debug Info',
                        Icons.bug_report,
                        () => _showDebugInfo(context),
                      ),
                      _buildActionChip(
                        context,
                        'Test Notification',
                        Icons.notification_add,
                        () => _testNotification(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _navigateToDriverTrip(BuildContext context) {
    // Create a sample trip for testing
    final sampleTrip = _createSampleTrip();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DriverTripScreen(trip: sampleTrip),
      ),
    );
  }

  void _showTestBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Booking'),
        content: const Text('This would simulate a new booking request for testing purposes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateBookingRequest(context);
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }

  void _simulateBookingRequest(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking request simulation triggered'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearCache(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache cleared successfully'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDebugInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('App Version: 1.0.0'),
            Text('Build Number: 1'),
            Text('Platform: ${Theme.of(context).platform}'),
            Text('Theme: ${Theme.of(context).brightness}'),
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

  void _testNotification(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Trip _createSampleTrip() {
    // Create sample user
    final sampleUser = User(
      id: 1,
      phone: '9876543210',
      firstName: 'John',
      lastName: 'Doe',
      profilePicture: null,
      fcmToken: null,
    );

    // Create sample driver
    final sampleDriver = Driver(
      id: 1,
      user: sampleUser,
      licenseNumber: 'DL123456789',
      isAvailable: false,
      fcmToken: null,
      averageRating: '4.5',
      totalEarnings: 1500.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create sample booking
    final sampleBooking = Booking(
      id: 1,
      tripId: 1,
      senderName: 'Alice Johnson',
      receiverName: 'Bob Smith',
      senderPhone: '9876543210',
      receiverPhone: '9876543211',
      pickupLocation: 'Delhi, India',
      dropoffLocation: 'Mumbai, India',
      pickupTime: DateTime.now().add(const Duration(hours: 1)),
      pickupAddress: 'Connaught Place, New Delhi, Delhi 110001',
      dropoffAddress: 'Gateway of India, Mumbai, Maharashtra 400001',
      goodsType: 'Electronics',
      goodsQuantity: '5 boxes',
      paymentMode: PaymentMode.cash,
      estimatedFare: 2500.0,
      status: BookingStatus.accepted,
      instructions: 'Handle with care, fragile items',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Create sample trip
    return Trip(
      id: 1,
      driver: sampleDriver,
      bookingRequest: sampleBooking,
      status: TripStatus.accepted,
      loadingStartTime: null,
      loadingEndTime: null,
      unloadingStartTime: null,
      unloadingEndTime: null,
      paymentTime: null,
      finalFare: 2500.0,
      finalDuration: null,
      finalDistance: null,
      isPaymentDone: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
} 