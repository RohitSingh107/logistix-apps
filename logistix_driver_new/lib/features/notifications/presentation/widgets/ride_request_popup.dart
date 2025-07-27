/**
 * ride_request_popup.dart - Ride Request Popup Widget
 * 
 * Purpose:
 * - Shows ride request details in a popup dialog
 * - Allows drivers to accept or reject rides
 * - Displays booking information clearly
 * - Handles ride request actions
 * 
 * Key Logic:
 * - Shows pickup and dropoff locations
 * - Displays fare and goods information
 * - Provides accept/reject buttons
 * - Handles booking actions
 * - Shows loading states during actions
 */

import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart' as app_notification;

class RideRequestPopup extends StatefulWidget {
  final app_notification.Notification notification;
  final Function(String bookingId, bool accepted) onRideAction;

  const RideRequestPopup({
    super.key,
    required this.notification,
    required this.onRideAction,
  });

  @override
  State<RideRequestPopup> createState() => _RideRequestPopupState();
}

class _RideRequestPopupState extends State<RideRequestPopup> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.notification.data;
    
    final bookingId = data?['booking_id'] ?? 'N/A';
    final estimatedFare = data?['estimated_fare'] ?? 'N/A';
    final pickupAddress = data?['pickup_address'] ?? 'N/A';
    final dropoffAddress = data?['dropoff_address'] ?? 'N/A';
    final goodsType = data?['goods_type'] ?? 'N/A';
    final goodsQuantity = data?['goods_quantity'] ?? 'N/A';
    final paymentMode = data?['payment_mode'] ?? 'N/A';
    final pickupTime = data?['pickup_time'] ?? 'N/A';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, bookingId),
            const SizedBox(height: 20),
            _buildFareSection(theme, estimatedFare),
            const SizedBox(height: 16),
            _buildLocationSection(theme, pickupAddress, dropoffAddress),
            const SizedBox(height: 16),
            _buildDetailsSection(theme, goodsType, goodsQuantity, paymentMode, pickupTime),
            const SizedBox(height: 20),
            _buildActionButtons(theme, bookingId),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String bookingId) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.local_taxi,
            color: theme.colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Ride Request',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Booking #$bookingId',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareSection(ThemeData theme, String estimatedFare) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.currency_rupee,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Estimated Fare',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '₹$estimatedFare',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(ThemeData theme, String pickupAddress, String dropoffAddress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildLocationItem(
          theme,
          Icons.location_on,
          'Pickup',
          pickupAddress,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildLocationItem(
          theme,
          Icons.location_on_outlined,
          'Dropoff',
          dropoffAddress,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildLocationItem(ThemeData theme, IconData icon, String label, String address, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
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

  Widget _buildDetailsSection(ThemeData theme, String goodsType, String goodsQuantity, String paymentMode, String pickupTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailItem(theme, 'Goods Type', goodsType),
        const SizedBox(height: 8),
        _buildDetailItem(theme, 'Quantity', goodsQuantity),
        const SizedBox(height: 8),
        _buildDetailItem(theme, 'Payment', paymentMode),
        const SizedBox(height: 8),
        _buildDetailItem(theme, 'Pickup Time', pickupTime),
      ],
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          ': ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, String bookingId) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => _handleRideAction(bookingId, false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: theme.colorScheme.error),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reject',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handleRideAction(bookingId, true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Accept',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _handleRideAction(String bookingId, bool accepted) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (accepted) {
        // Accept the ride
        final trip = await widget.onRideAction(bookingId, accepted);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          // Show success message with trip details
          _showAcceptanceSuccessDialog(trip);
        }
      } else {
        // Reject the ride
        await widget.onRideAction(bookingId, accepted);
        
        if (mounted) {
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ride rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAcceptanceSuccessDialog(dynamic trip) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Ride Accepted!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have successfully accepted this ride.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (trip != null) ...[
              Text(
                'Trip ID: ${trip.id}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${trip.statusText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to trip screen or home
              Navigator.of(context).pushReplacementNamed('/home');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
} 