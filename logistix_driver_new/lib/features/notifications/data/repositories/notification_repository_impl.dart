/**
 * notification_repository_impl.dart - Notification Repository Implementation
 * 
 * Purpose:
 * - Implements the NotificationRepository interface
 * - Handles notification storage, retrieval, and management
 * - Provides both local and remote notification operations
 * - Manages notification state and persistence
 * 
 * Key Logic:
 * - Uses SharedPreferences for local notification storage
 * - Implements API client for remote notification operations
 * - Handles notification serialization and deserialization
 * - Provides offline-first notification management
 * - Supports notification filtering and pagination
 * - Manages notification read/unread status
 */

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_endpoints.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;
  final SharedPreferences _sharedPreferences;
  static const String _localNotificationsKey = 'local_notifications';

  NotificationRepositoryImpl(this._apiClient, this._sharedPreferences);

  @override
  Future<PaginatedNotificationList> getNotifications({
    int? page,
    int? pageSize,
    NotificationType? type,
    bool? isRead,
  }) async {
    try {
      // Since API endpoints don't exist, work offline-only
      return _getLocalNotificationsPaginated(
        page: page, 
        pageSize: pageSize,
        type: type,
        isRead: isRead,
      );
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return const PaginatedNotificationList(
        results: [],
        count: 0,
      );
    }
  }

  @override
  Future<Notification?> getNotificationById(int notificationId) async {
    try {
      // Get from local storage only
      final localNotifications = await getLocalNotifications();
      return localNotifications.firstWhere(
        (notification) => notification.id == notificationId,
        orElse: () => throw Exception('Notification not found'),
      );
    } catch (e) {
      print('❌ Error getting notification by ID: $e');
      return null;
    }
  }

  @override
  Future<Notification> markNotificationAsRead(int notificationId) async {
    try {
      // Update locally only since API doesn't exist
      final localNotifications = await getLocalNotifications();
      final notificationIndex = localNotifications.indexWhere(
        (notification) => notification.id == notificationId,
      );
      
      if (notificationIndex != -1) {
        final updatedNotification = localNotifications[notificationIndex].markAsRead();
        localNotifications[notificationIndex] = updatedNotification;
        await _saveLocalNotifications(localNotifications);
        return updatedNotification;
      }
      
      throw Exception('Notification not found');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      // Update locally only since API doesn't exist
      final localNotifications = await getLocalNotifications();
      final updatedNotifications = localNotifications.map((notification) => notification.markAsRead()).toList();
      await _saveLocalNotifications(updatedNotifications);
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(int notificationId) async {
    try {
      // Remove from local storage only since API doesn't exist
      final localNotifications = await getLocalNotifications();
      localNotifications.removeWhere((notification) => notification.id == notificationId);
      await _saveLocalNotifications(localNotifications);
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  @override
  Future<void> clearAllNotifications() async {
    try {
      // Clear local storage only since API doesn't exist
      await _saveLocalNotifications([]);
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      // Count from local storage only since API doesn't exist
      final localNotifications = await getLocalNotifications();
      return localNotifications.where((notification) => !notification.isRead).length;
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  @override
  Future<void> storeNotificationLocally(Notification notification) async {
    final localNotifications = await getLocalNotifications();
    
    // Check if notification already exists
    final existingIndex = localNotifications.indexWhere((n) => n.id == notification.id);
    
    if (existingIndex != -1) {
      // Update existing notification
      localNotifications[existingIndex] = notification;
    } else {
      // Add new notification at the beginning
      localNotifications.insert(0, notification);
    }
    
    // Keep only the latest 100 notifications to prevent storage issues
    if (localNotifications.length > 100) {
      localNotifications.removeRange(100, localNotifications.length);
    }
    
    await _saveLocalNotifications(localNotifications);
  }

  @override
  Future<List<Notification>> getLocalNotifications() async {
    try {
      final notificationsJson = _sharedPreferences.getString(_localNotificationsKey);
      if (notificationsJson == null) return [];
      
      final List<dynamic> notificationsList = jsonDecode(notificationsJson);
      return notificationsList
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error loading local notifications: $e');
      return [];
    }
  }

  /// Save notifications to local storage
  Future<void> _saveLocalNotifications(List<Notification> notifications) async {
    try {
      final notificationsJson = jsonEncode(
        notifications.map((notification) => notification.toJson()).toList(),
      );
      await _sharedPreferences.setString(_localNotificationsKey, notificationsJson);
    } catch (e) {
      print('❌ Error saving local notifications: $e');
    }
  }

  /// Update a specific notification in local storage
  Future<void> _updateLocalNotification(Notification updatedNotification) async {
    final localNotifications = await getLocalNotifications();
    final notificationIndex = localNotifications.indexWhere(
      (notification) => notification.id == updatedNotification.id,
    );
    
    if (notificationIndex != -1) {
      localNotifications[notificationIndex] = updatedNotification;
      await _saveLocalNotifications(localNotifications);
    }
  }

  /// Get paginated local notifications
  PaginatedNotificationList _getLocalNotificationsPaginated({
    int? page,
    int? pageSize,
    NotificationType? type,
    bool? isRead,
  }) {
    final localNotifications = _sharedPreferences.getString(_localNotificationsKey);
    if (localNotifications == null) {
      return const PaginatedNotificationList(
        results: [],
        count: 0,
      );
    }
    
    try {
      final List<dynamic> notificationsList = jsonDecode(localNotifications);
      final notifications = notificationsList
          .map((json) => Notification.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Apply filters
      var filteredNotifications = notifications;
      
      if (type != null) {
        filteredNotifications = filteredNotifications.where((n) => n.type == type).toList();
      }
      
      if (isRead != null) {
        filteredNotifications = filteredNotifications.where((n) => n.isRead == isRead).toList();
      }
      
      final pageNum = page ?? 1;
      final size = pageSize ?? 20;
      final startIndex = (pageNum - 1) * size;
      final endIndex = startIndex + size;
      
      final paginatedResults = filteredNotifications.sublist(
        startIndex,
        endIndex > filteredNotifications.length ? filteredNotifications.length : endIndex,
      );
      
      return PaginatedNotificationList(
        results: paginatedResults,
        count: filteredNotifications.length,
        next: endIndex < filteredNotifications.length ? '${pageNum + 1}' : null,
        previous: pageNum > 1 ? '${pageNum - 1}' : null,
      );
    } catch (e) {
      print('❌ Error parsing local notifications: $e');
      return const PaginatedNotificationList(
        results: [],
        count: 0,
      );
    }
  }
} 