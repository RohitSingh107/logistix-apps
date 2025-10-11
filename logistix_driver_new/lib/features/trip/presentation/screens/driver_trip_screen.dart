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
import '../../../../core/config/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.trip.status;
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
          _buildDetailRow('Payment Mode', booking.paymentModeText),
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

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (_currentStatus == TripStatus.accepted) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _startTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Start Trip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ] else if (_currentStatus == TripStatus.started) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeTrip,
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
                      'Complete Trip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : _cancelTrip,
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
    );
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case TripStatus.accepted:
        return Icons.check_circle;
      case TripStatus.started:
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
        return 'Ride Accepted';
      case TripStatus.started:
        return 'Trip in Progress';
      case TripStatus.completed:
        return 'Trip Completed';
      case TripStatus.cancelled:
        return 'Trip Cancelled';
    }
  }

  void _startTrip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement start trip API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _currentStatus = TripStatus.started;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip started successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeTrip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement complete trip API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      setState(() {
        _currentStatus = TripStatus.completed;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trip completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home after completion
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing trip: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelTrip() async {
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

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Implement cancel trip API call
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        
        setState(() {
          _currentStatus = TripStatus.cancelled;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Trip cancelled'),
            backgroundColor: Colors.orange,
          ),
        );

        // Navigate back to home after cancellation
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 