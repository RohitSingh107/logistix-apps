/**
 * push_notification_service.dart - Push Notification Service
 * 
 * Purpose:
 * - Handles Firebase Cloud Messaging (FCM) initialization
 * - Manages FCM token retrieval and printing
 * - Configures notification permissions and settings
 * - Handles foreground and background notifications
 */

import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  /// Initialize push notifications
  static Future<void> initialize() async {
    try {
      print("🔥 Initializing Push Notification Service...");
      
      // Request notification permissions
      await _requestPermissions();
      
      // Get and print FCM token
      await _getFCMToken();
      
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
  
  /// Configure message handlers for different app states
  static void _configureMessageHandlers() {
    print("📬 Configuring message handlers...");
    
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("🔔 Foreground message received:");
      _printMessageDetails(message);
      // You can show in-app notification here
    });
    
    // Handle messages when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📱 Background message tapped:");
      _printMessageDetails(message);
      // Handle navigation when notification is tapped
    });
    
    // Handle messages when app is terminated
    _handleTerminatedAppMessages();
  }
  
  /// Handle messages when app is launched from terminated state
  static Future<void> _handleTerminatedAppMessages() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    
    if (initialMessage != null) {
      print("🚀 App launched from notification:");
      _printMessageDetails(initialMessage);
      // Handle initial navigation
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
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🔔 Background message received:");
  print("   Title: ${message.notification?.title ?? 'No title'}");
  print("   Body: ${message.notification?.body ?? 'No body'}");
  print("   Data: ${message.data}");
} 