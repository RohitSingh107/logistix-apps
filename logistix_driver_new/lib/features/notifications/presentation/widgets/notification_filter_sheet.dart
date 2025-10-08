/// notification_filter_sheet.dart - Notification Filter Sheet
/// 
/// Purpose:
/// - Provides filtering options for notifications
/// - Allows filtering by notification type and read status
/// - Shows filter controls in a bottom sheet
/// - Handles filter state management
/// 
/// Key Logic:
/// - Shows notification type filter options
/// - Provides read/unread status filter
/// - Handles filter application and reset
/// - Uses bottom sheet for filter UI
/// - Supports multiple filter combinations
library;

import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart' as app_notification;

class NotificationFilterSheet extends StatefulWidget {
  final app_notification.NotificationType? selectedType;
  final bool? selectedReadStatus;
  final Function(app_notification.NotificationType?, bool?) onApplyFilter;

  const NotificationFilterSheet({
    super.key,
    this.selectedType,
    this.selectedReadStatus,
    required this.onApplyFilter,
  });

  @override
  State<NotificationFilterSheet> createState() => _NotificationFilterSheetState();
}

class _NotificationFilterSheetState extends State<NotificationFilterSheet> {
  app_notification.NotificationType? _selectedType;
  bool? _selectedReadStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedReadStatus = widget.selectedReadStatus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(theme),
          _buildHeader(theme),
          _buildTypeFilter(theme),
          _buildReadStatusFilter(theme),
          _buildActions(theme),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildHandle(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Filter Notifications',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(theme, null, 'All'),
              _buildTypeChip(theme, app_notification.NotificationType.rideRequest, 'Ride Request'),
              _buildTypeChip(theme, app_notification.NotificationType.rideAccepted, 'Ride Accepted'),
              _buildTypeChip(theme, app_notification.NotificationType.paymentReceived, 'Payment'),
              _buildTypeChip(theme, app_notification.NotificationType.walletTopup, 'Wallet'),
              _buildTypeChip(theme, app_notification.NotificationType.systemUpdate, 'System'),
              _buildTypeChip(theme, app_notification.NotificationType.promotion, 'Promotion'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, app_notification.NotificationType? type, String label) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  Widget _buildReadStatusFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Read Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildReadStatusChip(theme, null, 'All'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadStatusChip(theme, false, 'Unread'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadStatusChip(theme, true, 'Read'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadStatusChip(ThemeData theme, bool? readStatus, String label) {
    final isSelected = _selectedReadStatus == readStatus;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedReadStatus = selected ? readStatus : null;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilter,
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _selectedReadStatus = null;
    });
  }

  void _applyFilter() {
    widget.onApplyFilter(_selectedType, _selectedReadStatus);
    Navigator.of(context).pop();
  }
} 