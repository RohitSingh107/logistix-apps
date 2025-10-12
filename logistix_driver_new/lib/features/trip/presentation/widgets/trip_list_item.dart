/// trip_list_item.dart - Trip List Item Widget
/// 
/// Purpose:
/// - Displays individual trip information in a card format
/// - Shows trip details, status, and actions
/// - Handles trip navigation and status display
/// 
/// Key Logic:
/// - Trip card with status indicator and color coding
/// - Trip details: pickup/dropoff, fare, date, status
/// - Action buttons for trip management
/// - Responsive design with proper spacing and typography
/// - Status-based styling (accepted, started, completed, cancelled)
library;

import 'package:flutter/material.dart';
import '../../../../core/models/trip_model.dart';

class TripListItem extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;

  const TripListItem({
    super.key,
    required this.trip,
    this.onTap,
    this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(theme),
                  Text(
                    trip.formattedFinalFare,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Trip details
              _buildTripDetails(theme),
              const SizedBox(height: 12),
              
              // Pickup and dropoff locations
              _buildLocationInfo(theme),
              const SizedBox(height: 12),
              
              // Trip metadata
              _buildTripMetadata(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    Color statusColor;
    String statusText;
    
    switch (trip.status) {
      case TripStatus.accepted:
        statusColor = Colors.orange;
        statusText = 'Accepted';
        break;
      case TripStatus.inProgress:
        statusColor = Colors.blue;
        statusText = 'In Progress';
        break;
      case TripStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case TripStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTripDetails(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.local_shipping_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Trip #${trip.id}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trip.hasUpdates)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${trip.totalUpdates} updates',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationInfo(ThemeData theme) {
    // Get pickup and dropoff addresses from stop_points
    String pickupAddress = 'Pickup location';
    String dropoffAddress = 'Dropoff location';
    
    if (trip.bookingRequest.stopPoints != null && trip.bookingRequest.stopPoints!.isNotEmpty) {
      // Sort by stop_order to get the correct sequence
      final sortedStops = List.from(trip.bookingRequest.stopPoints!);
      sortedStops.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
      
      pickupAddress = sortedStops.first.address;
      dropoffAddress = sortedStops.last.address;
    }

    return Column(
      children: [
        _buildLocationRow(
          theme,
          Icons.radio_button_checked,
          'Pickup',
          pickupAddress,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildLocationRow(
          theme,
          Icons.location_on,
          'Dropoff',
          dropoffAddress,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildLocationRow(
    ThemeData theme,
    IconData icon,
    String label,
    String address,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripMetadata(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildMetadataItem(
            theme,
            Icons.access_time,
            'Created',
            _formatDate(trip.createdAt),
          ),
        ),
        if (trip.finalDuration != null)
          Expanded(
            child: _buildMetadataItem(
              theme,
              Icons.timer_outlined,
              'Duration',
              trip.formattedFinalDuration,
            ),
          ),
        if (trip.finalDistance != null)
          Expanded(
            child: _buildMetadataItem(
              theme,
              Icons.straighten,
              'Distance',
              trip.formattedFinalDistance,
            ),
          ),
      ],
    );
  }

  Widget _buildMetadataItem(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
