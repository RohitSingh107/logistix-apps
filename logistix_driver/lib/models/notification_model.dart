import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  final String? title;
  final String? body;
  final String? messageId;
  final DateTime? timestamp;
  final Map<String, dynamic> data;

  NotificationModel({
    this.title,
    this.body,
    this.messageId,
    this.timestamp,
    this.data = const {},
  });

  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    return NotificationModel(
      title: message.notification?.title,
      body: message.notification?.body,
      messageId: message.messageId,
      timestamp: message.sentTime,
      data: message.data,
    );
  }
} 