/**
 * notification_repository.dart - Notification Repository Interface
 * 
 * Purpose:
 * - Defines the contract for notification-related data operations
 * - Provides abstraction layer for notification management
 * - Ensures consistent notification data access patterns across the application
 * 
 * Key Logic:
 * - Abstract repository interface following domain-driven design
 * - Manages notification retrieval, storage, and status updates
 * - Supports paginated notification listing and filtering
 * - Handles notification read/unread status management
 * - Returns structured notification models for type safety
 * - Follows async/await pattern for all notification operations
 * - Supports comprehensive notification management functionality
 */

import '../../../../core/models/notification_model.dart';

abstract class NotificationRepository {
  /// Get paginated list of notifications
  Future<PaginatedNotificationList> getNotifications({
    int? page,
    int? pageSize,
    NotificationType? type,
    bool? isRead,
  });
  
  /// Get a specific notification by ID
  Future<Notification?> getNotificationById(int notificationId);
  
  /// Mark a notification as read
  Future<Notification> markNotificationAsRead(int notificationId);
  
  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead();
  
  /// Delete a notification
  Future<void> deleteNotification(int notificationId);
  
  /// Clear all notifications
  Future<void> clearAllNotifications();
  
  /// Get unread notification count
  Future<int> getUnreadNotificationCount();
  
  /// Store a notification locally (for offline support)
  Future<void> storeNotificationLocally(Notification notification);
  
  /// Get locally stored notifications
  Future<List<Notification>> getLocalNotifications();
} 