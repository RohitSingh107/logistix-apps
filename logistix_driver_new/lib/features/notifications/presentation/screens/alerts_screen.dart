/// alerts_screen.dart - Alerts and Notifications Screen
/// 
/// Purpose:
/// - Displays all notifications and alerts for the driver
/// - Provides notification management (read/unread, delete)
/// - Shows notification history with pagination
/// - Handles notification actions and navigation
/// 
/// Key Logic:
/// - Uses NotificationBloc for state management
/// - Displays notifications in a scrollable list
/// - Supports pull-to-refresh and infinite scrolling
/// - Shows notification badges and read/unread status
/// - Provides notification filtering and search
/// - Handles notification actions (mark as read, delete)
/// - Shows empty state when no notifications
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/notification_model.dart' as app_notification;
import '../../../../core/services/push_notification_service.dart';
import '../bloc/notification_bloc.dart';
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
  int _selectedFilterTab = 0; // 0: All, 1: Earnings, 2: Trips
  bool _showUnreadOnly = false;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NotificationLoading) {
              return Column(
                children: [
                  _buildTopBar(),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              );
            }

            if (state is NotificationLoaded) {
              return _buildNotificationList(state);
            }

            if (state is NotificationError) {
              return Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: _buildErrorState(state.message),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildEmptyState(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: 9,
      ),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Image.asset(
              'assets/images/logo without text/logo color.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Alerts',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 22, height: 22), // Spacer for alignment
        ],
      ),
    );
  }

  List<app_notification.Notification> _filterNotifications(List<app_notification.Notification> notifications) {
    var filtered = notifications;
    
    // Apply filter tab
    if (_selectedFilterTab == 1) { // Earnings
      filtered = filtered.where((n) => 
        n.type == app_notification.NotificationType.paymentReceived ||
        n.type == app_notification.NotificationType.walletTopup
      ).toList();
    } else if (_selectedFilterTab == 2) { // Trips
      filtered = filtered.where((n) => 
        n.type == app_notification.NotificationType.rideRequest ||
        n.type == app_notification.NotificationType.rideAccepted ||
        n.type == app_notification.NotificationType.rideStarted ||
        n.type == app_notification.NotificationType.rideCompleted
      ).toList();
    }
    
    // Apply unread filter
    if (_showUnreadOnly) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }
    
    return filtered;
  }

  Map<String, List<app_notification.Notification>> _groupNotifications(List<app_notification.Notification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final recent = <app_notification.Notification>[];
    final earlier = <app_notification.Notification>[];
    
    for (var notification in notifications) {
      if (notification.createdAt.isAfter(yesterday)) {
        recent.add(notification);
      } else {
        earlier.add(notification);
      }
    }
    
    return {
      'recent': recent,
      'earlier': earlier,
    };
  }

  String _getNotificationCategory(app_notification.Notification notification) {
    switch (notification.type) {
      case app_notification.NotificationType.paymentReceived:
      case app_notification.NotificationType.walletTopup:
        return 'Earnings';
      case app_notification.NotificationType.rideRequest:
      case app_notification.NotificationType.rideAccepted:
      case app_notification.NotificationType.rideStarted:
      case app_notification.NotificationType.rideCompleted:
        return 'Trips';
      case app_notification.NotificationType.systemUpdate:
        return 'Account';
      default:
        return 'Account';
    }
  }

  IconData _getNotificationIcon(app_notification.Notification notification) {
    switch (notification.type) {
      case app_notification.NotificationType.paymentReceived:
      case app_notification.NotificationType.walletTopup:
        return Icons.account_balance_wallet;
      case app_notification.NotificationType.rideRequest:
      case app_notification.NotificationType.rideAccepted:
      case app_notification.NotificationType.rideStarted:
      case app_notification.NotificationType.rideCompleted:
        return Icons.local_shipping;
      case app_notification.NotificationType.systemUpdate:
      case app_notification.NotificationType.promotion:
      case app_notification.NotificationType.general:
        return Icons.notifications;
    }
  }

  Widget _buildNotificationList(NotificationLoaded state) {
    final allNotifications = state.notifications.results;
    final filteredNotifications = _filterNotifications(allNotifications);
    final grouped = _groupNotifications(filteredNotifications);
    final recent = grouped['recent'] ?? [];
    final earlier = grouped['earlier'] ?? [];

    if (filteredNotifications.isEmpty) {
      return Column(
        children: [
          _buildTopBar(),
          _buildFilterSection(),
          Expanded(
            child: _buildEmptyState(),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTopBar(),
        _buildFilterSection(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshNotifications,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (recent.isNotEmpty) _buildNotificationSection('Recent', recent),
                  if (recent.isNotEmpty && earlier.isNotEmpty) const SizedBox(height: 12),
                  if (earlier.isNotEmpty) _buildNotificationSection('Earlier', earlier),
                  if (!state.hasReachedMax)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _buildMarkAllReadButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(1),
            clipBehavior: Clip.antiAlias,
            decoration: ShapeDecoration(
              color: const Color(0xFF333333),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFE6E6E6),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedFilterTab == 0 ? const Color(0xFFFF6B00) : Colors.transparent,
                      ),
                      child: Text(
                        'All',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedFilterTab == 1 ? const Color(0xFFFF6B00) : Colors.transparent,
                      ),
                      child: Text(
                        'Earnings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFilterTab = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedFilterTab == 2 ? const Color(0xFFFF6B00) : Colors.transparent,
                      ),
                      child: Text(
                        'Trips',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showUnreadOnly = !_showUnreadOnly;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _showUnreadOnly ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: _showUnreadOnly ? const Color(0xFFFF6B00) : const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Unread',
                        style: TextStyle(
                          color: _showUnreadOnly ? const Color(0xFFFF6B00) : const Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _clearAllNotifications,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.clear,
                        size: 14,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<app_notification.Notification> notifications) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 12,
              left: 12,
              right: 12,
              bottom: 8,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.asMap().entries.map((entry) {
              final index = entry.key;
              final notification = entry.value;
              final isLast = index == notifications.length - 1;
              
              return Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: 12,
                  left: 12,
                  right: 12,
                  bottom: isLast ? 12 : 13,
                ),
                decoration: isLast ? null : BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: const Color(0xFFE6E6E6),
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => _onNotificationTap(notification),
                  child: _buildNotificationItem(notification),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(app_notification.Notification notification) {
    final category = _getNotificationCategory(notification);
    final dateFormat = DateFormat('dd MMM, HH:mm');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    String timeText;
    if (notification.createdAt.isAfter(today)) {
      timeText = 'Today, ${DateFormat('HH:mm').format(notification.createdAt)}';
    } else if (notification.createdAt.isAfter(yesterday)) {
      timeText = 'Yesterday, ${DateFormat('HH:mm').format(notification.createdAt)}';
    } else {
      timeText = dateFormat.format(notification.createdAt);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getNotificationIcon(notification),
          size: 22,
          color: const Color(0xFF111111),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE6E6E6),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                notification.body,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeText,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarkAllReadButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: _markAllAsRead,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: ShapeDecoration(
            color: const Color(0xFF333333),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE6E6E6),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const Text(
                'Mark all read',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    // Get all unread notifications and mark them as read
    final state = context.read<NotificationBloc>().state;
    if (state is NotificationLoaded) {
      final unreadNotifications = state.notifications.results.where((n) => !n.isRead).toList();
      for (var notification in unreadNotifications) {
        context.read<NotificationBloc>().add(MarkNotificationAsRead(notification.id));
      }
    }
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete all notifications
              final state = context.read<NotificationBloc>().state;
              if (state is NotificationLoaded) {
                for (var notification in state.notifications.results) {
                  context.read<NotificationBloc>().add(DeleteNotification(notification.id));
                }
              }
            },
            child: const Text('Clear'),
          ),
        ],
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
                
                // Show success message and redirect to trip screen
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Booking accepted successfully! Trip ID: ${trip.id}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Redirect to trip screen after successful acceptance
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      Navigator.of(context).pushNamed(
                        '/driver-trip',
                        arguments: trip,
                      );
                    }
                  });
                }
                
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