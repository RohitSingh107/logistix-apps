import 'package:flutter/material.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'dart:async';

class TripScreen extends StatefulWidget {
  final Map<String, dynamic> tripData;

  const TripScreen({super.key, required this.tripData});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  late Map<String, dynamic> trip;
  late Map<String, dynamic> bookingRequest;
  late DateTime bookingAcceptedTime;
  Timer? _elapsedTimer;
  String _elapsedTime = '';
  final AuthService _authService = AuthService();
  bool _isUpdatingStatus = false;
  bool _isUpdatingPayment = false;

  @override
  void initState() {
    super.initState();
    trip = widget.tripData['trip'];
    bookingRequest = trip['booking_request'];
    bookingAcceptedTime = DateTime.parse(trip['created_at']);
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _updateElapsedTime();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsedTime();
    });
  }

  void _updateElapsedTime() {
    final now = DateTime.now();
    final elapsed = now.difference(bookingAcceptedTime);
    
    setState(() {
      if (elapsed.inHours > 0) {
        _elapsedTime = '${elapsed.inHours}h ${elapsed.inMinutes % 60}m ${elapsed.inSeconds % 60}s';
      } else if (elapsed.inMinutes > 0) {
        _elapsedTime = '${elapsed.inMinutes}m ${elapsed.inSeconds % 60}s';
      } else {
        _elapsedTime = '${elapsed.inSeconds}s';
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateTripStatus(String newStatus, String successMessage) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final result = await _authService.updateTripStatus(trip['id'], newStatus);
      
      if (result != null && mounted) {
        // Update the trip data with the new status
        setState(() {
          trip = result['trip'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? successMessage),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  void _handleStatusTransition(String currentStatus) {
    switch (currentStatus) {
      case 'ACCEPTED':
        _updateTripStatus('TRIP_STARTED', 'Trip started successfully');
        break;
      case 'TRIP_STARTED':
        _updateTripStatus('LOADING_STARTED', 'Loading started successfully');
        break;
      case 'LOADING_STARTED':
        _updateTripStatus('LOADING_DONE', 'Loading completed successfully');
        break;
      case 'LOADING_DONE':
        _updateTripStatus('REACHED_DESTINATION', 'Reached destination successfully');
        break;
      case 'REACHED_DESTINATION':
        _updateTripStatus('UNLOADING_STARTED', 'Unloading started successfully');
        break;
      case 'UNLOADING_STARTED':
        _updateTripStatus('UNLOADING_DONE', 'Unloading completed successfully');
        break;
      case 'UNLOADING_DONE':
        _updateTripStatusAndCompleteTrip();
        break;
    }
  }

  Future<void> _updateTripStatusAndCompleteTrip() async {
    if (_isUpdatingStatus) return;

    // Check if payment is required and not done
    final paymentMode = bookingRequest['payment_mode'] ?? '';
    final isPaymentDone = trip['is_payment_done'] ?? false;
    
    if (paymentMode == 'CASH' && !isPaymentDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark payment as received before completing the trip.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      // First update trip status to COMPLETED
      final tripResult = await _authService.updateTripStatus(trip['id'], 'COMPLETED');
      
      if (tripResult != null && mounted) {
        // Update the trip data with the new status
        setState(() {
          trip = tripResult['trip'];
        });
        
        // Then update driver availability to true
        final driverResult = await _authService.updateDriverAvailability(true);
        
        if (driverResult != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tripResult['message'] ?? 'Trip completed successfully'}\nYou are now available for new bookings.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tripResult['message'] ?? 'Trip completed successfully'}\nWarning: Could not update availability status.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to complete trip. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _updatePaymentStatus(bool isPaymentDone) async {
    if (_isUpdatingPayment) return;

    setState(() {
      _isUpdatingPayment = true;
    });

    try {
      final result = await _authService.updatePaymentStatus(trip['id'], isPaymentDone);
      
      if (result != null && mounted) {
        setState(() {
          trip = result['trip'];
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPaymentDone 
                ? 'Payment marked as received' 
                : 'Payment marked as pending'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update payment status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating payment status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingPayment = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripStatus = trip['status'] ?? 'ACCEPTED';
    final canGoBack = tripStatus == 'COMPLETED';
    
    return PopScope(
      canPop: canGoBack, // Allow back navigation only when trip is completed
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trip Details'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: canGoBack, // Show back button only when trip is completed
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.tripData['message'] ?? 'Booking accepted successfully',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Trip Status
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Booking Details
            _buildBookingDetailsCard(),
            const SizedBox(height: 16),

            // Payment Status Card (only for CASH payments)
            if (bookingRequest['payment_mode'] == 'CASH')
              _buildPaymentStatusCard(),
            if (bookingRequest['payment_mode'] == 'CASH')
              const SizedBox(height: 16),

            // Contact Information
            _buildContactCard(),
            const SizedBox(height: 16),

            // Trip Actions
            _buildActionButtons(),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trip['status'] ?? 'ACCEPTED',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Fare: ₹${trip['final_fare']?.toString() ?? '0'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Elapsed Time Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 20, color: Colors.blue.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Elapsed Time: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  Text(
                    _elapsedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.inventory, 'Goods', 
                '${bookingRequest['goods_quantity']} ${bookingRequest['goods_type']}'),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.payment, 'Payment Mode', 
                bookingRequest['payment_mode'] ?? 'N/A'),
            const SizedBox(height: 16),
            _buildLocationSection('Pickup', 
                bookingRequest['pickup_address'] ?? 'N/A',
                bookingRequest['pickup_time'] ?? ''),
            const SizedBox(height: 12),
            _buildLocationSection('Dropoff', 
                bookingRequest['dropoff_address'] ?? 'N/A', ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactRow('Sender', 
                bookingRequest['sender_name'] ?? 'N/A',
                bookingRequest['sender_phone'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildContactRow('Receiver', 
                bookingRequest['receiver_name'] ?? 'N/A',
                bookingRequest['receiver_phone'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final tripStatus = trip['status'] ?? 'ACCEPTED';
    
    // Get button text and icon based on current status
    String buttonText;
    IconData buttonIcon;
    
    switch (tripStatus) {
      case 'ACCEPTED':
        buttonText = 'Start Trip';
        buttonIcon = Icons.play_arrow;
        break;
      case 'TRIP_STARTED':
        buttonText = 'Start Loading';
        buttonIcon = Icons.inventory;
        break;
      case 'LOADING_STARTED':
        buttonText = 'Loading Complete';
        buttonIcon = Icons.check_circle;
        break;
      case 'LOADING_DONE':
        buttonText = 'Mark Reached';
        buttonIcon = Icons.location_on;
        break;
      case 'REACHED_DESTINATION':
        buttonText = 'Start Unloading';
        buttonIcon = Icons.unarchive;
        break;
      case 'UNLOADING_STARTED':
        buttonText = 'Unloading Complete';
        buttonIcon = Icons.check_circle_outline;
        break;
      case 'UNLOADING_DONE':
        buttonText = 'Complete Trip';
        buttonIcon = Icons.flag;
        break;
      case 'COMPLETED':
        buttonText = 'Trip Completed';
        buttonIcon = Icons.done_all;
        break;
      default:
        buttonText = 'Update Status';
        buttonIcon = Icons.update;
    }
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _isUpdatingStatus || tripStatus == 'COMPLETED' 
                ? null 
                : () => _handleStatusTransition(tripStatus),
            icon: _isUpdatingStatus 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(buttonIcon),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: tripStatus == 'COMPLETED' 
                  ? Colors.grey 
                  : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        // Show "Back to Home" button when trip is completed
        if (tripStatus == 'COMPLETED') ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.home),
              label: const Text('Back to Home'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildLocationSection(String type, String address, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              type == 'Pickup' ? Icons.location_on : Icons.location_off,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              type,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(String type, String name, String phone) {
    return Row(
      children: [
        Icon(Icons.person, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$type: $name',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                phone,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Make phone call
          },
          icon: const Icon(Icons.phone),
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildPaymentStatusCard() {
    final isPaymentDone = trip['is_payment_done'] ?? false;
    final tripStatus = trip['status'] ?? 'ACCEPTED';
    final isCompleted = tripStatus == 'COMPLETED';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPaymentDone ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPaymentDone ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isPaymentDone ? Icons.payment : Icons.pending,
                        color: isPaymentDone ? Colors.green.shade600 : Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash Payment',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isPaymentDone ? Colors.green.shade800 : Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              '₹${trip['final_fare']?.toString() ?? '0'}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isPaymentDone ? Colors.green.shade700 : Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2,
                        child: Switch(
                          value: isPaymentDone,
                          onChanged: (_isUpdatingPayment || isCompleted) 
                              ? null 
                              : (value) => _updatePaymentStatus(value),
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.green,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.orange.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isPaymentDone 
                              ? 'Payment received and confirmed' 
                              : 'Mark as received when customer pays',
                          style: TextStyle(
                            fontSize: 14,
                            color: isPaymentDone ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                        ),
                      ),
                      if (_isUpdatingPayment) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPaymentDone ? Colors.green.shade600 : Colors.orange.shade600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!isPaymentDone && !isCompleted) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Trip cannot be completed until payment is received',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 