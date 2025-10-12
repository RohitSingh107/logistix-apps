/// driver_trip_screen.dart - Driver Trip Screen
/// 
/// Purpose:
/// - Shows trip details after driver accepts a ride
/// - Provides navigation and trip management features
/// - Similar to Uber's customer interface but for drivers
/// 
/// Key Features:
/// - Trip details display (pickup, dropoff, fare)
/// - Navigation integration
/// - Trip status management
/// - Action buttons (start trip, complete trip)
/// - Real-time updates
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/trip_status_service.dart';

class DriverTripScreen extends StatefulWidget {
  final Trip trip;

  const DriverTripScreen({
    super.key,
    required this.trip,
  });

  @override
  State<DriverTripScreen> createState() => _DriverTripScreenState();
}

class _DriverTripScreenState extends State<DriverTripScreen> {
  bool _isLoading = false;
  TripStatus _currentStatus = TripStatus.accepted;
  late final TripStatusService _tripStatusService;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.trip.status;
    _tripStatusService = serviceLocator<TripStatusService>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final booking = widget.trip.bookingRequest;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Active Trip'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Column(
        children: [
          // Trip Status Header
          _buildTripStatusHeader(theme),
          
          // Trip Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pickup Section
                  _buildLocationSection(
                    theme,
                    'Pickup',
                    booking.pickupAddress,
                    Icons.location_on,
                    Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Dropoff Section
                  _buildLocationSection(
                    theme,
                    'Dropoff',
                    booking.dropoffAddress,
                    Icons.location_on,
                    Colors.red,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Trip Details Card
                  _buildTripDetailsCard(theme, booking),
                  
                  const SizedBox(height: 24),
                  
                  // Customer Details Card
                  _buildCustomerDetailsCard(theme, booking),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripStatusHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(),
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusText(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trip ID: ${widget.trip.id}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(
    ThemeData theme,
    String title,
    String? address,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address ?? 'Address not available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetailsCard(ThemeData theme, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Estimated Fare', booking.formattedEstimatedFare),
          _buildDetailRow('Goods Type', booking.goodsType),
          _buildDetailRow('Goods Quantity', booking.goodsQuantity),
          _buildPaymentModeRow(booking),
          _buildPaymentStatusRow(),
          _buildDetailRow('Pickup Time', booking.formattedPickupTime),
        ],
      ),
    );
  }

  Widget _buildCustomerDetailsCard(ThemeData theme, Booking booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Sender', booking.senderName),
          _buildDetailRow('Sender Phone', booking.senderPhone),
          _buildDetailRow('Receiver', booking.receiverName),
          _buildDetailRow('Receiver Phone', booking.receiverPhone),
          if (booking.instructions?.isNotEmpty == true)
            _buildDetailRow('Instructions', booking.instructions!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeRow(Booking booking) {
    final isCashPayment = booking.paymentMode.toString().split('.').last == 'cash';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Payment Mode',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  booking.paymentModeText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCashPayment ? Colors.orange : null,
                  ),
                ),
                if (isCashPayment) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: const Text(
                      'CASH',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusRow() {
    final isPaymentDone = widget.trip.isPaymentDone;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              'Payment Status',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  isPaymentDone ? Icons.check_circle : Icons.pending,
                  color: isPaymentDone ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isPaymentDone ? 'Payment Received' : 'Payment Pending',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isPaymentDone ? Colors.green : Colors.orange,
                  ),
                ),
                if (isPaymentDone) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: const Text(
                      'PAID',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    final availableTransitions = _tripStatusService.getAvailableTransitions(_currentStatus);
    final booking = widget.trip.bookingRequest;
    final isCashPayment = booking.paymentMode.toString().split('.').last == 'cash';
    
    return Column(
      children: [
        // Cash Collected button (only for cash payments when trip is in progress)
        if (isCashPayment && _currentStatus == TripStatus.inProgress) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _collectCash,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Cash Collected',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Primary action button based on current status
        if (availableTransitions.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _updateTripStatus(availableTransitions.first),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStatusButtonColor(availableTransitions.first),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _getNextStatusButtonText(availableTransitions.first),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Cancel button (always available for non-final states)
        if (_currentStatus != TripStatus.completed && _currentStatus != TripStatus.cancelled) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => _updateTripStatus(TripStatus.cancelled),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel Trip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
        
        // Status display for final states
        if (_currentStatus == TripStatus.completed || _currentStatus == TripStatus.cancelled) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: _getStatusButtonColor(_currentStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusButtonColor(_currentStatus),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _tripStatusService.getStatusIcon(_currentStatus),
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  _tripStatusService.getStatusButtonText(_currentStatus),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getStatusButtonColor(_currentStatus),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusButtonColor(TripStatus status) {
    switch (status) {
      case TripStatus.accepted:
        return Colors.blue;
      case TripStatus.inProgress:
        return Colors.orange;
      case TripStatus.completed:
        return Colors.green;
      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  String _getNextStatusButtonText(TripStatus nextStatus) {
    switch (nextStatus) {
      case TripStatus.inProgress:
        return 'Start Trip';
      case TripStatus.completed:
        return 'Complete Trip';
      case TripStatus.cancelled:
        return 'Cancel Trip';
      case TripStatus.accepted:
        return 'Accept Trip';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case TripStatus.accepted:
        return Icons.check_circle;
      case TripStatus.inProgress:
        return Icons.directions_car;
      case TripStatus.completed:
        return Icons.flag;
      case TripStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case TripStatus.accepted:
        return 'Trip Accepted - Ready to Start';
      case TripStatus.inProgress:
        return 'Trip in Progress';
      case TripStatus.completed:
        return 'Trip Completed';
      case TripStatus.cancelled:
        return 'Trip Cancelled';
    }
  }

  void _collectCash() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("💰 Collecting cash for trip ${widget.trip.id}");
      
      // Send cash collection update with payment done flag
      await _tripStatusService.sendCashCollectionUpdate(
        widget.trip.id,
        'Cash is Collected',
      );

      setState(() {
        _isLoading = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash collection recorded successfully! Payment marked as done.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording cash collection: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _updateTripStatus(TripStatus newStatus) async {
    // Show confirmation dialog for cancellations
    if (newStatus == TripStatus.cancelled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Trip'),
          content: const Text('Are you sure you want to cancel this trip?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("🔄 Updating trip ${widget.trip.id} status to ${newStatus.name}");
      
      // Call the API to update trip status
      await _tripStatusService.updateTripStatus(
        widget.trip.id,
        newStatus,
      );

      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });

      // Show success message
      String successMessage;
      switch (newStatus) {
        case TripStatus.inProgress:
          successMessage = 'Trip started successfully! You are now in progress.';
          break;
        case TripStatus.completed:
          successMessage = 'Trip completed successfully!';
          break;
        case TripStatus.cancelled:
          successMessage = 'Trip cancelled';
          break;
        default:
          successMessage = 'Trip status updated successfully!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: _getStatusButtonColor(newStatus),
        ),
      );

      // Navigate back to home after completion or cancellation
      if (newStatus == TripStatus.completed || newStatus == TripStatus.cancelled) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating trip status: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
} 