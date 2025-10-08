/// notification_model.dart - Notification Data Models
/// 
/// Purpose:
/// - Defines data models for push notifications and in-app alerts
/// - Handles notification storage, display, and management
/// - Provides scalable notification system for production
/// 
/// Key Logic:
/// - NotificationType enum: Categorizes different notification types
/// - Notification model: Core notification entity with all necessary fields
/// - NotificationRequest: API request model for notification operations
/// - PaginatedNotificationList: Handles paginated notification responses
/// - Uses JSON serialization with proper field mapping
/// - Supports notification status tracking (read/unread)
/// - Includes notification actions and deep linking
library;

import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'notification_model.g.dart';

enum NotificationType {
  @JsonValue('RIDE_REQUEST')
  rideRequest,
  @JsonValue('RIDE_ACCEPTED')
  rideAccepted,
  @JsonValue('RIDE_STARTED')
  rideStarted,
  @JsonValue('RIDE_COMPLETED')
  rideCompleted,
  @JsonValue('PAYMENT_RECEIVED')
  paymentReceived,
  @JsonValue('WALLET_TOPUP')
  walletTopup,
  @JsonValue('SYSTEM_UPDATE')
  systemUpdate,
  @JsonValue('PROMOTION')
  promotion,
  @JsonValue('GENERAL')
  general,
}

enum NotificationPriority {
  @JsonValue('LOW')
  low,
  @JsonValue('NORMAL')
  normal,
  @JsonValue('HIGH')
  high,
  @JsonValue('URGENT')
  urgent,
}

@JsonSerializable()
class Notification extends BaseModel {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionText;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.isRead,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.actionText,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        priority,
        isRead,
        data,
        imageUrl,
        actionUrl,
        actionText,
        createdAt,
        readAt,
      ];

  /// Create a notification from Firebase RemoteMessage
  factory Notification.fromRemoteMessage(Map<String, dynamic> messageData) {
    // Generate a unique ID that fits within 32-bit integer range
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch % 100000; // Last 5 digits
    final random = (now.microsecond % 1000); // Last 3 digits
    final id = timestamp * 1000 + random;
    
    return Notification(
      id: id,
      title: messageData['title'] ?? 'Notification',
      body: messageData['body'] ?? '',
      type: _parseNotificationType(messageData['type']),
      priority: _parseNotificationPriority(messageData['priority']),
      isRead: false,
      data: messageData['data'] ?? {},
      imageUrl: messageData['image_url'],
      actionUrl: messageData['action_url'],
      actionText: messageData['action_text'],
      createdAt: DateTime.now(),
    );
  }

  /// Mark notification as read
  Notification markAsRead() {
    return Notification(
      id: id,
      title: title,
      body: body,
      type: type,
      priority: priority,
      isRead: true,
      data: data,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      actionText: actionText,
      createdAt: createdAt,
      readAt: DateTime.now(),
    );
  }

  /// Get notification icon based on type
  String get icon {
    switch (type) {
      case NotificationType.rideRequest:
        return '🚗';
      case NotificationType.rideAccepted:
        return '✅';
      case NotificationType.rideStarted:
        return '🚀';
      case NotificationType.rideCompleted:
        return '🎉';
      case NotificationType.paymentReceived:
        return '💰';
      case NotificationType.walletTopup:
        return '💳';
      case NotificationType.systemUpdate:
        return '🔧';
      case NotificationType.promotion:
        return '🎁';
      case NotificationType.general:
        return '📢';
    }
  }

  /// Get notification color based on priority
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return '#4CAF50'; // Green
      case NotificationPriority.normal:
        return '#2196F3'; // Blue
      case NotificationPriority.high:
        return '#FF9800'; // Orange
      case NotificationPriority.urgent:
        return '#F44336'; // Red
    }
  }

  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toUpperCase()) {
      case 'RIDE_REQUEST':
        return NotificationType.rideRequest;
      case 'RIDE_ACCEPTED':
        return NotificationType.rideAccepted;
      case 'RIDE_STARTED':
        return NotificationType.rideStarted;
      case 'RIDE_COMPLETED':
        return NotificationType.rideCompleted;
      case 'PAYMENT_RECEIVED':
        return NotificationType.paymentReceived;
      case 'WALLET_TOPUP':
        return NotificationType.walletTopup;
      case 'SYSTEM_UPDATE':
        return NotificationType.systemUpdate;
      case 'PROMOTION':
        return NotificationType.promotion;
      default:
        return NotificationType.general;
    }
  }

  static NotificationPriority _parseNotificationPriority(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'LOW':
        return NotificationPriority.low;
      case 'HIGH':
        return NotificationPriority.high;
      case 'URGENT':
        return NotificationPriority.urgent;
      default:
        return NotificationPriority.normal;
    }
  }
}

@JsonSerializable()
class NotificationRequest extends BaseModel {
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionText;

  const NotificationRequest({
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.actionText,
  });

  factory NotificationRequest.fromJson(Map<String, dynamic> json) => _$NotificationRequestFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$NotificationRequestToJson(this);

  @override
  List<Object?> get props => [title, body, type, priority, data, imageUrl, actionUrl, actionText];
}

@JsonSerializable()
class PaginatedNotificationList extends BaseModel {
  final List<Notification> results;
  final int count;
  final String? next;
  final String? previous;

  const PaginatedNotificationList({
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  factory PaginatedNotificationList.fromJson(Map<String, dynamic> json) => _$PaginatedNotificationListFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PaginatedNotificationListToJson(this);

  @override
  List<Object?> get props => [results, count, next, previous];
} 