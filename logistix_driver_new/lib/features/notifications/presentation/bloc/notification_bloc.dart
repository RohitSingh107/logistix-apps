/**
 * notification_bloc.dart - Notification BLoC
 * 
 * Purpose:
 * - Manages notification state and business logic
 * - Handles notification loading, filtering, and status updates
 * - Provides reactive notification management
 * - Supports pagination and real-time updates
 * 
 * Key Logic:
 * - NotificationEvent: Defines all notification-related actions
 * - NotificationState: Represents different notification states
 * - Handles notification loading with pagination support
 * - Manages notification read/unread status
 * - Supports notification filtering by type and status
 * - Provides error handling and loading states
 * - Implements notification count tracking
 */

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/notification_model.dart';
import '../../domain/repositories/notification_repository.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final int? page;
  final int? pageSize;
  final NotificationType? type;
  final bool? isRead;

  const LoadNotifications({
    this.page,
    this.pageSize,
    this.type,
    this.isRead,
  });

  @override
  List<Object?> get props => [page, pageSize, type, isRead];
}

class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

class MarkNotificationAsRead extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

class DeleteNotification extends NotificationEvent {
  final int notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotifications extends NotificationEvent {
  const ClearAllNotifications();
}

class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

class LoadUnreadCount extends NotificationEvent {
  const LoadUnreadCount();
}

class AddNotification extends NotificationEvent {
  final Notification notification;

  const AddNotification(this.notification);

  @override
  List<Object?> get props => [notification];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final PaginatedNotificationList notifications;
  final bool hasReachedMax;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.hasReachedMax,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, hasReachedMax, unreadCount];

  NotificationLoaded copyWith({
    PaginatedNotificationList? notifications,
    bool? hasReachedMax,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  int _currentPage = 1;
  bool _hasReachedMax = false;
  NotificationType? _currentType;
  bool? _currentIsRead;

  NotificationBloc(this._notificationRepository) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<ClearAllNotifications>(_onClearAllNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<LoadUnreadCount>(_onLoadUnreadCount);
    on<AddNotification>(_onAddNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());
      
      _currentPage = event.page ?? 1;
      _currentType = event.type;
      _currentIsRead = event.isRead;
      _hasReachedMax = false;

      final notifications = await _notificationRepository.getNotifications(
        page: _currentPage,
        pageSize: event.pageSize ?? 20,
        type: _currentType,
        isRead: _currentIsRead,
      );

      final unreadCount = await _notificationRepository.getUnreadNotificationCount();

      _hasReachedMax = notifications.next == null;

      emit(NotificationLoaded(
        notifications: notifications,
        hasReachedMax: _hasReachedMax,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      print("❌ Error loading notifications: $e");
      emit(NotificationError("Failed to load notifications. Please try again."));
    }
  }

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (_hasReachedMax) return;

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final nextPage = _currentPage + 1;
        final moreNotifications = await _notificationRepository.getNotifications(
          page: nextPage,
          pageSize: 20,
          type: _currentType,
          isRead: _currentIsRead,
        );

        if (moreNotifications.results.isNotEmpty) {
          _currentPage = nextPage;
          _hasReachedMax = moreNotifications.next == null;

          final updatedResults = [
            ...currentState.notifications.results,
            ...moreNotifications.results,
          ];

          final updatedNotifications = PaginatedNotificationList(
            results: updatedResults,
            count: moreNotifications.count,
            next: moreNotifications.next,
            previous: moreNotifications.previous,
          );

          emit(currentState.copyWith(
            notifications: updatedNotifications,
            hasReachedMax: _hasReachedMax,
          ));
        } else {
          _hasReachedMax = true;
          emit(currentState.copyWith(hasReachedMax: true));
        }
      }
    } catch (e) {
      print("❌ Error loading more notifications: $e");
      // Don't emit error state for pagination failures
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markNotificationAsRead(event.notificationId);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedResults = currentState.notifications.results.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.markAsRead();
          }
          return notification;
        }).toList();

        final updatedNotifications = PaginatedNotificationList(
          results: updatedResults,
          count: currentState.notifications.count,
          next: currentState.notifications.next,
          previous: currentState.notifications.previous,
        );

        final unreadCount = await _notificationRepository.getUnreadNotificationCount();

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      print("❌ Error marking notification as read: $e");
      // Don't emit error state for read operations
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.markAllNotificationsAsRead();

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedResults = currentState.notifications.results
            .map((notification) => notification.markAsRead())
            .toList();

        final updatedNotifications = PaginatedNotificationList(
          results: updatedResults,
          count: currentState.notifications.count,
          next: currentState.notifications.next,
          previous: currentState.notifications.previous,
        );

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      }
    } catch (e) {
      print("❌ Error marking all notifications as read: $e");
      // Don't emit error state for read operations
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.deleteNotification(event.notificationId);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        final updatedResults = currentState.notifications.results
            .where((notification) => notification.id != event.notificationId)
            .toList();

        final updatedNotifications = PaginatedNotificationList(
          results: updatedResults,
          count: currentState.notifications.count - 1,
          next: currentState.notifications.next,
          previous: currentState.notifications.previous,
        );

        final unreadCount = await _notificationRepository.getUnreadNotificationCount();

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      print("❌ Error deleting notification: $e");
      // Don't emit error state for delete operations
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _notificationRepository.clearAllNotifications();

      emit(const NotificationLoaded(
        notifications: PaginatedNotificationList(
          results: [],
          count: 0,
        ),
        hasReachedMax: true,
        unreadCount: 0,
      ));
    } catch (e) {
      print("❌ Error clearing notifications: $e");
      emit(NotificationError("Failed to clear notifications. Please try again."));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _currentPage = 1;
      _hasReachedMax = false;

      final notifications = await _notificationRepository.getNotifications(
        page: _currentPage,
        pageSize: 20,
        type: _currentType,
        isRead: _currentIsRead,
      );

      final unreadCount = await _notificationRepository.getUnreadNotificationCount();

      _hasReachedMax = notifications.next == null;

      emit(NotificationLoaded(
        notifications: notifications,
        hasReachedMax: _hasReachedMax,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      print("❌ Error refreshing notifications: $e");
      emit(NotificationError("Failed to refresh notifications. Please try again."));
    }
  }

  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await _notificationRepository.getUnreadNotificationCount();

      final currentState = state;
      if (currentState is NotificationLoaded) {
        emit(currentState.copyWith(unreadCount: unreadCount));
      }
    } catch (e) {
      print("❌ Error loading unread count: $e");
      // Don't emit error state for unread count
    }
  }

  Future<void> _onAddNotification(
    AddNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Store the notification locally
      await _notificationRepository.storeNotificationLocally(event.notification);

      final currentState = state;
      if (currentState is NotificationLoaded) {
        // Add the new notification to the beginning of the list
        final updatedResults = [event.notification, ...currentState.notifications.results];

        final updatedNotifications = PaginatedNotificationList(
          results: updatedResults,
          count: currentState.notifications.count + 1,
          next: currentState.notifications.next,
          previous: currentState.notifications.previous,
        );

        final unreadCount = await _notificationRepository.getUnreadNotificationCount();

        emit(currentState.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      print("❌ Error adding notification: $e");
      // Don't emit error state for add operations
    }
  }
} 