/**
 * notification_tile.dart - Notification Tile Widget
 * 
 * Purpose:
 * - Displays individual notification items in a list
 * - Shows notification content, type, and status
 * - Provides actions for notification management
 * - Handles notification interactions
 * 
 * Key Logic:
 * - Shows notification icon based on type
 * - Displays read/unread status with visual indicators
 * - Provides swipe actions for quick actions
 * - Shows notification timestamp and priority
 * - Handles notification tap and long press
 * - Supports notification actions (mark as read, delete)
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/notification_model.dart' as app_notification;

class NotificationTile extends StatelessWidget {
  final app_notification.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final theme = Theme.of(context);
      final isRead = notification.isRead;
      
      return Dismissible(
        key: Key(notification.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: theme.colorScheme.error,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        onDismissed: (direction) => onDelete(),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isRead ? 1 : 2,
          color: isRead 
              ? theme.colorScheme.surface 
              : theme.colorScheme.surface.withOpacity(0.95),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotificationIcon(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNotificationHeader(theme),
                        const SizedBox(height: 4),
                        _buildNotificationBody(theme),
                        const SizedBox(height: 8),
                        _buildNotificationFooter(theme),
                      ],
                    ),
                  ),
                  _buildNotificationActions(theme),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print("❌ Error building notification tile: $e");
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("Error displaying notification"),
        ),
      );
    }
  }

  Widget _buildNotificationIcon(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getNotificationColor(theme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          notification.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildNotificationHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            notification.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
              color: notification.isRead 
                  ? theme.colorScheme.onSurface.withOpacity(0.7)
                  : theme.colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!notification.isRead)
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }

  Widget _buildNotificationBody(ThemeData theme) {
    return Text(
      notification.body,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildNotificationFooter(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          _formatTimestamp(notification.createdAt),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        _buildPriorityChip(theme),
      ],
    );
  }

  Widget _buildNotificationActions(ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      onSelected: (value) {
        switch (value) {
          case 'mark_read':
            onMarkAsRead();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.isRead)
          const PopupMenuItem(
            value: 'mark_read',
            child: Row(
              children: [
                Icon(Icons.mark_email_read, size: 16),
                SizedBox(width: 8),
                Text('Mark as Read'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    Color chipColor;
    String priorityText;
    
    switch (notification.priority) {
      case app_notification.NotificationPriority.low:
        chipColor = Colors.green;
        priorityText = 'Low';
        break;
      case app_notification.NotificationPriority.normal:
        chipColor = Colors.blue;
        priorityText = 'Normal';
        break;
      case app_notification.NotificationPriority.high:
        chipColor = Colors.orange;
        priorityText = 'High';
        break;
      case app_notification.NotificationPriority.urgent:
        chipColor = Colors.red;
        priorityText = 'Urgent';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        priorityText,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getNotificationColor(ThemeData theme) {
    switch (notification.type) {
      case app_notification.NotificationType.rideRequest:
        return Colors.blue;
      case app_notification.NotificationType.rideAccepted:
        return Colors.green;
      case app_notification.NotificationType.rideStarted:
        return Colors.orange;
      case app_notification.NotificationType.rideCompleted:
        return Colors.purple;
      case app_notification.NotificationType.paymentReceived:
        return Colors.green;
      case app_notification.NotificationType.walletTopup:
        return Colors.blue;
      case app_notification.NotificationType.systemUpdate:
        return Colors.grey;
      case app_notification.NotificationType.promotion:
        return Colors.amber;
      case app_notification.NotificationType.general:
        return theme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 