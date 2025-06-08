import 'package:flutter/material.dart';
import 'package:logistix_driver/models/notification_model.dart';
import 'package:logistix_driver/services/notification_service.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:logistix_driver/screens/trip_screen.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final List<NotificationModel> _notifications = [];
  late final NotificationService _notificationService;
  final AuthService _authService = AuthService();
  bool _isInitialized = false;
  String? _fcmToken;
  Timer? _cleanupTimer;
  bool _isAcceptingBooking = false;

  @override
  void initState() {
    super.initState();
    _initializeNotificationService();
  }

  Future<void> _initializeNotificationService() async {
    _notificationService = NotificationService();
    await _notificationService.initialize();
    debugPrint('AlertsScreen: Notification service initialized');
    
    // Get FCM token
    _fcmToken = await _notificationService.getFCMToken();
    
    _notificationService.notificationStream.listen((notification) {
      debugPrint('AlertsScreen: Received notification: ${notification.title} - ${notification.body}');
      setState(() {
        _notifications.insert(0, notification); // Add new notifications at the top
        debugPrint('AlertsScreen: Updated notifications list. Count: ${_notifications.length}');
      });

      // Remove notification after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _notifications.remove(notification);
          });
        }
      });
    });
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _notificationService.dispose();
    _cleanupTimer?.cancel();
    super.dispose();
  }

  Future<void> _acceptBooking(NotificationModel notification) async {
    if (notification.bookingId == null || _isAcceptingBooking) return;

    setState(() {
      _isAcceptingBooking = true;
    });

    try {
      final result = await _authService.acceptBooking(notification.bookingId!);
      
      if (result != null && mounted) {
        // Remove the notification immediately since booking is accepted
        setState(() {
          _notifications.remove(notification);
        });
        
        // Navigate to trip screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TripScreen(tripData: result),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept booking. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAcceptingBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Column(
      children: [
        // FCM Token Section
        Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FCM Token',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fcmToken ?? 'Loading...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _fcmToken == null
                          ? null
                          : () {
                              Clipboard.setData(ClipboardData(text: _fcmToken!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FCM Token copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Notifications Section
        if (_notifications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Active Booking Alerts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                if (notification.type != 'booking_alert') {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => _acceptBooking(notification),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    elevation: _isAcceptingBooking ? 1 : 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'New Booking Alert!',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '₹${notification.estimatedFare?.toStringAsFixed(2) ?? '0.00'}',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow(
                                  context,
                                  Icons.local_shipping,
                                  'Goods',
                                  '${notification.goodsQuantity ?? 0} ${notification.goodsType ?? ''}'
                                ),
                                const SizedBox(height: 8),
                                _buildInfoRow(
                                  context,
                                  Icons.payment,
                                  'Payment',
                                  notification.paymentMode ?? 'N/A'
                                ),
                                const SizedBox(height: 16),
                                _buildLocationInfo(
                                  context,
                                  'Pickup',
                                  notification.pickupAddress ?? 'N/A',
                                  notification.pickupTime?.toString() ?? 'N/A',
                                ),
                                const SizedBox(height: 8),
                                _buildLocationInfo(
                                  context,
                                  'Dropoff',
                                  notification.dropoffAddress ?? 'N/A',
                                  '',
                                ),
                              ],
                            ),
                            // Loading overlay
                            if (_isAcceptingBooking)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else
          const Expanded(
            child: Center(
              child: Text('No active booking alerts'),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(BuildContext context, String type, String address, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              type == 'Pickup' ? Icons.location_on : Icons.location_off,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
} 