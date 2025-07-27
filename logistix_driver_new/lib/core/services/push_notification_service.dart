/**
 * push_notification_service.dart - Push Notification Service
 * 
 * Purpose:
 * - Handles Firebase Cloud Messaging (FCM) initialization
 * - Manages FCM token retrieval and printing
 * - Configures notification permissions and settings
 * - Handles foreground and background notifications
 * - Integrates with enhanced notification service
 */

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../network/api_client.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../di/service_locator.dart';
import '../../features/driver/domain/repositories/driver_repository.dart';
import 'notification_service.dart';
import '../models/notification_model.dart' as app_notification;

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final NotificationService _notificationService = NotificationService();
  
  /// Initialize push notifications
  static Future<void> initialize({
    UserRepository? userRepository,
    AuthService? authService,
  }) async {
    try {
      print("🔥 Initializing Push Notification Service...");
      
      // Initialize enhanced notification service
      await _notificationService.initialize();
      
      // Request notification permissions
      await _requestPermissions();
      
      // Get and print FCM token
      final fcmToken = await _getFCMToken();
      
      // Update FCM token on server if user is authenticated
      if (fcmToken != null && 
          userRepository != null && 
          authService != null) {
        await _updateFcmTokenOnServer(fcmToken, userRepository, authService);
        await _updateDriverFcmTokenOnServer(fcmToken, authService);
      }
      
      // Configure message handlers
      _configureMessageHandlers();
      
      print("✅ Push Notification Service initialized successfully");
    } catch (e) {
      print("❌ Error initializing Push Notification Service: $e");
    }
  }
  
  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      print("📱 Requesting notification permissions...");
      
      // For iOS and Android 13+
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("✅ Notification permissions granted");
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print("⚠️ Provisional notification permissions granted");
      } else {
        print("❌ Notification permissions denied");
      }
      
      // For Android, also request POST_NOTIFICATIONS permission
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (status != PermissionStatus.granted) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      print("❌ Error requesting permissions: $e");
    }
  }
  
  /// Get and print FCM token
  static Future<String?> _getFCMToken() async {
    try {
      print("🔑 Getting FCM token...");
      
      String? token = await _firebaseMessaging.getToken();
      
      if (token != null) {
        print("🎯 FCM TOKEN: $token");
        print("📋 You can copy this token for testing push notifications");
        
        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((String newToken) {
          print("🔄 FCM Token refreshed: $newToken");
          // Update both user and driver FCM tokens when refreshed
          _handleTokenRefresh(newToken);
        });
        
        return token;
      } else {
        print("❌ Failed to get FCM token");
        return null;
      }
    } catch (e) {
      print("❌ Error getting FCM token: $e");
      return null;
    }
  }
  
  /// Handle FCM token refresh
  static Future<void> _handleTokenRefresh(String newToken) async {
    try {
      print("🔄 Handling FCM token refresh...");
      
      final authService = serviceLocator<AuthService>();
      final userRepository = serviceLocator<UserRepository>();
      
      // Update user FCM token
      await _updateFcmTokenOnServer(newToken, userRepository, authService);
      
      // Update driver FCM token
      await _updateDriverFcmTokenOnServer(newToken, authService);
      
      print("✅ FCM token refresh handled successfully");
    } catch (e) {
      print("❌ Error handling FCM token refresh: $e");
    }
  }
  
  /// Configure message handlers for different app states
  static void _configureMessageHandlers() {
    print("📬 Configuring message handlers...");
    
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground message received:");
      _printMessageDetails(message);
      
      // Show in-app notification using enhanced notification service
      _showInAppNotification(message);
    });
    
    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📱 Background message tapped:");
      _printMessageDetails(message);
      // Handle navigation when notification is tapped
      _handleNotificationNavigation(message);
    });
    
    // Handle messages when app is terminated
    _handleTerminatedAppMessages();
  }
  
  /// Show in-app notification for foreground messages
  static void _showInAppNotification(RemoteMessage message) {
    try {
      final data = message.data;
      final notification = message.notification;
      
      print("🔔 Processing notification: ${notification?.title}");
      
      // Create notification object
      final notificationData = {
        'title': notification?.title ?? data['title'] ?? 'Notification',
        'body': notification?.body ?? data['body'] ?? '',
        'type': data['type'] ?? 'GENERAL',
        'priority': data['priority'] ?? 'NORMAL',
        'data': data,
        'image_url': data['image_url'],
        'action_url': data['action_url'],
        'action_text': data['action_text'],
      };
      
      // Show custom notification
      _notificationService.showCustomNotification(
        title: notificationData['title'],
        body: notificationData['body'],
        type: _parseNotificationType(notificationData['type']),
        priority: _parseNotificationPriority(notificationData['priority']),
        data: notificationData['data'],
        imageUrl: notificationData['image_url'],
        actionUrl: notificationData['action_url'],
        actionText: notificationData['action_text'],
      );
      
      // If this is a ride request, show the popup
      if (data['type'] == 'booking_alert' || data['type'] == 'booking_request') {
        _showRideRequestPopup(data);
      }
      
      print("✅ In-app notification processed successfully");
      
    } catch (e) {
      print("❌ Error showing in-app notification: $e");
      // Don't let notification errors crash the app
    }
  }

  /// Show ride request popup
  static void _showRideRequestPopup(Map<String, dynamic> data) {
    try {
      print("🚗 Showing ride request popup for booking: ${data['booking_id']}");
      
      // Create a notification object for the popup
      final notification = app_notification.Notification(
        id: _generateNotificationId(),
        title: 'New Ride Request #${data['booking_id']}',
        body: '₹${data['estimated_fare']} • ${data['goods_type']}\nFrom: ${data['pickup_address']}\nTo: ${data['dropoff_address']}',
        type: app_notification.NotificationType.rideRequest,
        priority: app_notification.NotificationPriority.high,
        isRead: false,
        data: data,
        createdAt: DateTime.now(),
      );
      
      // Show the popup (this will be handled by the UI layer)
      _notificationService.showRideRequestPopup(notification);
      
    } catch (e) {
      print("❌ Error showing ride request popup: $e");
    }
  }

  /// Generate a unique notification ID
  static int _generateNotificationId() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch % 100000;
    final random = (now.microsecond % 1000);
    return timestamp * 1000 + random;
  }
  
  /// Handle notification navigation
  static void _handleNotificationNavigation(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'] ?? 'GENERAL';
      
      // Handle navigation based on notification type
      switch (type.toUpperCase()) {
        case 'RIDE_REQUEST':
          print("🚗 Navigating to ride request");
          // TODO: Navigate to ride request screen
          break;
        case 'RIDE_ACCEPTED':
          print("✅ Navigating to active trip");
          // TODO: Navigate to active trip screen
          break;
        case 'PAYMENT_RECEIVED':
          print("💰 Navigating to wallet");
          // TODO: Navigate to wallet screen
          break;
        default:
          print("📢 Navigating to notifications");
          // TODO: Navigate to notifications screen
          break;
      }
    } catch (e) {
      print("❌ Error handling notification navigation: $e");
    }
  }
  
  /// Handle messages when app is launched from terminated state
  static Future<void> _handleTerminatedAppMessages() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      print("🚀 App launched from notification:");
      _printMessageDetails(initialMessage);
      // Handle initial navigation
      _handleNotificationNavigation(initialMessage);
    }
  }
  
  /// Print message details for debugging
  static void _printMessageDetails(RemoteMessage message) {
    print("📋 Message Details:");
    print("   Title: ${message.notification?.title ?? 'No title'}");
    print("   Body: ${message.notification?.body ?? 'No body'}");
    print("   Data: ${message.data}");
    print("   Message ID: ${message.messageId}");
    
    if (message.notification?.android != null) {
      print("   Android: ${message.notification!.android}");
    }
    
    if (message.notification?.apple != null) {
      print("   Apple: ${message.notification!.apple}");
    }
  }
  
  /// Parse notification type from string
  static app_notification.NotificationType _parseNotificationType(String? type) {
    if (type == null) return app_notification.NotificationType.general;
    
    switch (type.toUpperCase()) {
      case 'RIDE_REQUEST':
      case 'BOOKING_REQUEST':
      case 'BOOKING_ALERT':
        return app_notification.NotificationType.rideRequest;
      case 'RIDE_ACCEPTED':
      case 'BOOKING_ACCEPTED':
        return app_notification.NotificationType.rideAccepted;
      case 'RIDE_STARTED':
        return app_notification.NotificationType.rideStarted;
      case 'RIDE_COMPLETED':
        return app_notification.NotificationType.rideCompleted;
      case 'PAYMENT_RECEIVED':
        return app_notification.NotificationType.paymentReceived;
      case 'WALLET_TOPUP':
        return app_notification.NotificationType.walletTopup;
      case 'SYSTEM_UPDATE':
        return app_notification.NotificationType.systemUpdate;
      case 'PROMOTION':
        return app_notification.NotificationType.promotion;
      default:
        return app_notification.NotificationType.general;
    }
  }
  
  /// Parse notification priority from string
  static app_notification.NotificationPriority _parseNotificationPriority(String? priority) {
    if (priority == null) return app_notification.NotificationPriority.normal;
    
    switch (priority.toUpperCase()) {
      case 'LOW':
        return app_notification.NotificationPriority.low;
      case 'HIGH':
        return app_notification.NotificationPriority.high;
      case 'URGENT':
        return app_notification.NotificationPriority.urgent;
      default:
        return app_notification.NotificationPriority.normal;
    }
  }
  
  /// Get current FCM token (for external use)
  static Future<String?> getCurrentToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print("❌ Error getting current FCM token: $e");
      return null;
    }
  }
  
  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print("✅ Subscribed to topic: $topic");
    } catch (e) {
      print("❌ Error subscribing to topic '$topic': $e");
    }
  }
  
  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print("✅ Unsubscribed from topic: $topic");
    } catch (e) {
      print("❌ Error unsubscribing from topic '$topic': $e");
    }
  }
  
  /// Update FCM token on server when user logs in
  static Future<void> updateTokenOnLogin(
    UserRepository userRepository,
    AuthService authService,
  ) async {
    try {
      print("🔑 Updating FCM token after login...");
      final fcmToken = await getCurrentToken();
      if (fcmToken != null) {
        await _updateFcmTokenOnServer(fcmToken, userRepository, authService);
        await _updateDriverFcmTokenOnServer(fcmToken, authService);
      } else {
        print("❌ No FCM token available to update");
      }
    } catch (e) {
      print("❌ Failed to update FCM token after login: $e");
    }
  }
  
  /// Update FCM token on server if user is authenticated
  static Future<void> _updateFcmTokenOnServer(
    String fcmToken,
    UserRepository userRepository,
    AuthService authService,
  ) async {
    try {
      // Check if user is authenticated
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        print("📱 User not authenticated, skipping FCM token update");
        return;
      }
      
      print("🔄 Updating user FCM token on server...");
      await userRepository.updateFcmToken(fcmToken);
      print("✅ User FCM token successfully updated on server");
    } catch (e) {
      print("❌ Failed to update user FCM token on server: $e");
      // Don't throw error as this shouldn't prevent app initialization
    }
  }
  
  /// Update driver FCM token on server if user is authenticated
  static Future<void> _updateDriverFcmTokenOnServer(
    String fcmToken,
    AuthService authService,
  ) async {
    try {
      // Check if user is authenticated
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        print("📱 User not authenticated, skipping driver FCM token update");
        return;
      }
      
      print("🔄 Updating driver FCM token on server...");
      
      // Get driver repository and update driver FCM token
      final driverRepository = serviceLocator<DriverRepository>();
      await driverRepository.updateDriverFcmToken(fcmToken);
      
      print("✅ Driver FCM token successfully updated on server");
    } catch (e) {
      print("❌ Failed to update driver FCM token on server: $e");
      // Don't throw error as this shouldn't prevent app initialization
    }
  }
  
  /// Update driver FCM token on server (public method for external use)
  static Future<void> updateDriverFcmToken() async {
    try {
      print("🔑 Updating driver FCM token...");
      final fcmToken = await getCurrentToken();
      if (fcmToken != null) {
        final authService = serviceLocator<AuthService>();
        await _updateDriverFcmTokenOnServer(fcmToken, authService);
      } else {
        print("❌ No FCM token available to update driver profile");
      }
    } catch (e) {
      print("❌ Failed to update driver FCM token: $e");
    }
  }

  /// Test method to simulate incoming FCM notification
  static Future<void> testIncomingNotification({
    String type = 'booking_alert',
    String title = 'Test Notification',
    String body = 'This is a test notification',
    Map<String, dynamic>? data,
  }) async {
    try {
      print("🧪 Testing incoming notification: $type");
      
      // Create a mock RemoteMessage
      final mockMessage = RemoteMessage(
        data: data ?? {
          'type': type,
          'booking_id': '999',
          'estimated_fare': '300',
          'pickup_address': 'Test Pickup Location',
          'dropoff_address': 'Test Dropoff Location',
          'goods_type': 'Test Goods',
        },
        notification: RemoteNotification(
          title: title,
          body: body,
        ),
        messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      // Process the mock message
      _showInAppNotification(mockMessage);
      
      print("✅ Test notification processed successfully");
    } catch (e) {
      print("❌ Error testing incoming notification: $e");
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message received:");
  print("   Title: ${message.notification?.title ?? 'No title'}");
  print("   Body: ${message.notification?.body ?? 'No body'}");
  print("   Data: ${message.data}");
} 