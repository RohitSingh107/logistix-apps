/// test_booking_acceptance.dart - Test Booking Acceptance Widget
/// 
/// Purpose:
/// - Provides a simple interface to test booking acceptance functionality
/// - Allows developers to input a booking ID and test the accept flow
/// - Shows detailed logs and error messages for debugging
/// 
/// Key Logic:
/// - Input field for booking ID
/// - Test button to trigger acceptance
/// - Real-time status updates and error handling
/// - Detailed logging for debugging purposes
library;

import 'package:flutter/material.dart';
import '../../../../core/services/ride_action_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/network/api_client.dart';

class TestBookingAcceptance extends StatefulWidget {
  const TestBookingAcceptance({super.key});

  @override
  State<TestBookingAcceptance> createState() => _TestBookingAcceptanceState();
}

class _TestBookingAcceptanceState extends State<TestBookingAcceptance> {
  final TextEditingController _bookingIdController = TextEditingController();
  bool _isLoading = false;
  String _status = 'Ready to test';
  Trip? _acceptedTrip;

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking Acceptance'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading ? Icons.hourglass_empty : Icons.info,
                          color: _isLoading ? Colors.orange : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking ID',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bookingIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter booking ID (e.g., 123)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testAcceptBooking,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Test Accept Booking'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _testDirectAPI,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Test Direct API Call'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sample Booking IDs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Booking IDs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildSampleIdChip('1'),
                        _buildSampleIdChip('2'),
                        _buildSampleIdChip('3'),
                        _buildSampleIdChip('10'),
                        _buildSampleIdChip('20'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results Section
            if (_acceptedTrip != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trip Accepted Successfully!',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTripInfo(_acceptedTrip!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSampleIdChip(String id) {
    return ActionChip(
      label: Text(id),
      onPressed: () {
        _bookingIdController.text = id;
      },
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildTripInfo(Trip trip) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Trip ID', trip.id.toString()),
        _buildInfoRow('Status', trip.statusText),
        _buildInfoRow('Driver', '${trip.driver.user.firstName} ${trip.driver.user.lastName}'),
        _buildInfoRow('Pickup', trip.bookingRequest.pickupAddress ?? 'Address not available'),
        _buildInfoRow('Dropoff', trip.bookingRequest.dropoffAddress ?? 'Address not available'),
        _buildInfoRow('Fare', trip.formattedFinalFare),
        _buildInfoRow('Payment Mode', trip.bookingRequest.paymentModeText),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _testAcceptBooking() async {
    final bookingId = _bookingIdController.text.trim();
    
    if (bookingId.isEmpty) {
      setState(() {
        _status = 'Please enter a booking ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing booking acceptance...';
      _acceptedTrip = null;
    });

    try {
      final rideActionService = serviceLocator<RideActionService>();
      final trip = await rideActionService.acceptRide(bookingId);
      
      setState(() {
        _isLoading = false;
        _status = '✅ Booking accepted successfully!';
        _acceptedTrip = trip;
      });
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking $bookingId accepted successfully! Trip ID: ${trip.id}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Error: $e';
        _acceptedTrip = null;
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting booking: $e'),
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

  Future<void> _testDirectAPI() async {
    final bookingId = _bookingIdController.text.trim();
    
    if (bookingId.isEmpty) {
      setState(() {
        _status = 'Please enter a booking ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing direct API call...';
      _acceptedTrip = null;
    });

    try {
      final apiClient = serviceLocator<ApiClient>();
      final response = await apiClient.post(
        '/api/booking/accept/',
        data: {
          'booking_request_id': int.parse(bookingId),
        },
      );
      
      setState(() {
        _isLoading = false;
        _status = '✅ Direct API call successful!';
      });
      
      // Show raw response
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('API Response'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status Code: ${response.statusCode}'),
                  const SizedBox(height: 8),
                  const Text('Response Data:'),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      response.data.toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Direct API Error: $e';
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Direct API Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
} 