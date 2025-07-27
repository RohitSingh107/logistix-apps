/**
 * alerts_screen.dart - Alerts and Notifications Screen
 * 
 * Purpose:
 * - Displays all notifications and alerts for the driver
 * - Provides notification management (read/unread, delete)
 * - Shows notification history with pagination
 * - Handles notification actions and navigation
 * 
 * Key Logic:
 * - Uses NotificationBloc for state management
 * - Displays notifications in a scrollable list
 * - Supports pull-to-refresh and infinite scrolling
 * - Shows notification badges and read/unread status
 * - Provides notification filtering and search
 * - Handles notification actions (mark as read, delete)
 * - Shows empty state when no notifications
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/notification_model.dart' as app_notification;
import '../../../../core/services/push_notification_service.dart';
import '../bloc/notification_bloc.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_filter_sheet.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/ride_action_service.dart';
import '../widgets/ride_request_popup.dart';
import '../../../../core/di/service_locator.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ScrollController _scrollController = ScrollController();
  app_notification.NotificationType? _selectedType;
  bool? _selectedReadStatus;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load notifications when screen initializes
    try {
      context.read<NotificationBloc>().add(const LoadNotifications());
    } catch (e) {
      print("❌ Error loading notifications in alerts screen: $e");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    try {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<NotificationBloc>().add(const LoadMoreNotifications());
      }
    } catch (e) {
      print("❌ Error in scroll listener: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Alerts & Notifications'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: _showFilterSheet,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _refreshNotifications,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.notification_add_outlined),
            tooltip: 'Test Notifications',
            onSelected: (value) {
              switch (value) {
                case 'test_general':
                  _testNotification();
                  break;
                case 'test_ride_request':
                  _testRideRequest();
                  break;
                case 'test_ride_accepted':
                  _testRideAccepted();
                  break;
                case 'test_fcm':
                  _testFcmNotification();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'test_general',
                child: Row(
                  children: [
                    Icon(Icons.notifications, size: 16),
                    SizedBox(width: 8),
                    Text('Test General Notification'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_ride_request',
                child: Row(
                  children: [
                    Icon(Icons.local_taxi, size: 16),
                    SizedBox(width: 8),
                    Text('Test Ride Request'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_ride_accepted',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16),
                    SizedBox(width: 8),
                    Text('Test Ride Accepted'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test_fcm',
                child: Row(
                  children: [
                    Icon(Icons.cloud, size: 16),
                    SizedBox(width: 8),
                    Text('Test FCM Notification'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationLoaded) {
            return _buildNotificationList(state);
          }

          if (state is NotificationError) {
            return _buildErrorState(state.message);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildNotificationList(NotificationLoaded state) {
    final theme = Theme.of(context);
    final notifications = state.notifications.results;

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length + (state.hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => _onNotificationTap(notification),
            onMarkAsRead: () => _markAsRead(notification.id),
            onDelete: () => _deleteNotification(notification.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll receive notifications for new trip requests, updates, and important announcements',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshNotifications,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationFilterSheet(
        selectedType: _selectedType,
        selectedReadStatus: _selectedReadStatus,
        onApplyFilter: _applyFilter,
      ),
    );
  }

  void _applyFilter(app_notification.NotificationType? type, bool? readStatus) {
    setState(() {
      _selectedType = type;
      _selectedReadStatus = readStatus;
    });
    
    context.read<NotificationBloc>().add(LoadNotifications(
      type: type,
      isRead: readStatus,
    ));
  }

  Future<void> _refreshNotifications() async {
    context.read<NotificationBloc>().add(const RefreshNotifications());
  }

  void _onNotificationTap(app_notification.Notification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case app_notification.NotificationType.rideRequest:
        // Show ride request popup
        _showRideRequestPopup(notification);
        break;
      case app_notification.NotificationType.rideAccepted:
        // Navigate to active trip screen
        print("✅ Navigating to active trip");
        break;
      case app_notification.NotificationType.paymentReceived:
        // Navigate to wallet screen
        print("💰 Navigating to wallet");
        break;
      default:
        // Show notification details or navigate to notifications
        print("📢 Showing notification details");
        break;
    }
  }

  void _showRideRequestPopup(app_notification.Notification notification) async {
    try {
      final rideActionService = serviceLocator<RideActionService>();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => RideRequestPopup(
          notification: notification,
          onRideAction: (bookingId, accepted) async {
            try {
              if (accepted) {
                final trip = await rideActionService.acceptRide(bookingId);
                return trip;
              } else {
                // For reject, just return null to close popup
                await rideActionService.rejectRide(bookingId);
                return null;
              }
            } catch (e) {
              print("❌ Error handling ride action: $e");
              rethrow;
            }
          },
        ),
      );
    } catch (e) {
      print("❌ Error showing ride request popup: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error showing ride request popup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _markAsRead(int notificationId) {
    context.read<NotificationBloc>().add(MarkNotificationAsRead(notificationId));
  }

  void _deleteNotification(int notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(DeleteNotification(notificationId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _testNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.showTestNotification();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("❌ Error sending test notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testRideRequest() async {
    try {
      final notificationService = NotificationService();
      await notificationService.showTestRideRequest();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test ride request notification sent!'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      print("❌ Error sending test ride request notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test ride request notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testRideAccepted() async {
    try {
      final notificationService = NotificationService();
      await notificationService.showTestRideAccepted();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test ride accepted notification sent!'),
          backgroundColor: Colors.purple,
        ),
      );
    } catch (e) {
      print("❌ Error sending test ride accepted notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test ride accepted notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _testFcmNotification() async {
    try {
      await PushNotificationService.testIncomingNotification(
        type: 'booking_alert',
        title: 'New Ride Request #999',
        body: '₹300 • Electronics\nFrom: Test Pickup Location\nTo: Test Dropoff Location',
        data: {
          'type': 'booking_alert',
          'booking_id': '999',
          'estimated_fare': '300',
          'pickup_address': 'Test Pickup Location',
          'dropoff_address': 'Test Dropoff Location',
          'goods_type': 'Electronics',
        },
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test FCM notification sent!'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      print("❌ Error sending test FCM notification: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test FCM notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 