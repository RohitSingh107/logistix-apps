import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:logistix_driver/models/notification_model.dart';
import 'package:logistix_driver/screens/home_screen.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final _notificationController = StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream => _notificationController.stream;

  Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        debugPrint('Notification title: ${message.notification?.title}');
        debugPrint('Notification body: ${message.notification?.body}');
        
        // Create notification model and add to stream
        final notification = NotificationModel.fromRemoteMessage(message);
        debugPrint('Created notification model: ${notification.title} - ${notification.body}');
        _notificationController.add(notification);
        debugPrint('Added notification to stream');
        
        // Log notification received event
        await _analytics.logEvent(
          name: 'notification_received',
          parameters: {
            'notification_title': message.notification?.title ?? '',
            'notification_body': message.notification?.body ?? '',
            'message_id': message.messageId ?? '',
            'timestamp': message.sentTime?.millisecondsSinceEpoch ?? 0,
          },
        );
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint('Message opened from background: ${message.data}');
      
      // Create notification model and add to stream
      final notification = NotificationModel.fromRemoteMessage(message);
      _notificationController.add(notification);
      
      // Log notification opened event
      await _analytics.logEvent(
        name: 'notification_opened',
        parameters: {
          'notification_title': message.notification?.title ?? '',
          'notification_body': message.notification?.body ?? '',
          'message_id': message.messageId ?? '',
          'timestamp': message.sentTime?.millisecondsSinceEpoch ?? 0,
        },
      );
    });

    // Get FCM token and print it
    String? token = await _firebaseMessaging.getToken();
    print('==========================================');
    print('FCM Token: $token');
    print('==========================================');
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      print('==========================================');
      print('FCM Token Refreshed: $token');
      print('==========================================');
      
      // Log token refresh event
      await _analytics.logEvent(
        name: 'fcm_token_refreshed',
        parameters: {
          'new_token': token,
        },
      );
    });
  }

  void dispose() {
    _notificationController.close();
  }
}

// This needs to be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  
  // Note: Analytics events cannot be logged in background handlers
  // as the Firebase instance is not available
} 