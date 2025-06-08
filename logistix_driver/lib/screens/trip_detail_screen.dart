import 'package:flutter/material.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TripDetailScreen extends StatefulWidget {
  final int tripId;
  final String tripDisplayId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
    required this.tripDisplayId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _tripDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTripDetail();
  }

  Future<void> _fetchTripDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.getTripDetail(widget.tripId);
      if (response != null && mounted) {
        setState(() {
          _tripDetail = response['trip'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trip details: $e'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'ACCEPTED':
        return Colors.blue;
      case 'TRIP_STARTED':
        return Colors.orange;
      case 'LOADING_STARTED':
      case 'LOADING_DONE':
        return Colors.purple;
      case 'REACHED_DESTINATION':
      case 'UNLOADING_STARTED':
      case 'UNLOADING_DONE':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip ${widget.tripDisplayId}'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tripDetail == null
              ? const Center(
                  child: Text('Failed to load trip details'),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTripDetail,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(),
                        const SizedBox(height: 16),
                        _buildRouteCard(),
                        const SizedBox(height: 16),
                        _buildGoodsCard(),
                        const SizedBox(height: 16),
                        _buildContactCard(),
                        const SizedBox(height: 16),
                        _buildTimingCard(),
                        const SizedBox(height: 16),
                        _buildPaymentCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final status = _tripDetail!['status'] ?? '';
    final statusColor = _getStatusColor(status);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                _formatStatus(status),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            if (_tripDetail!['is_payment_done'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'PAID',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildRouteCard() {
    final bookingRequest = _tripDetail!['booking_request'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.my_location, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        bookingRequest['pickup_address'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Drop-off Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        bookingRequest['dropoff_address'] ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoodsCard() {
    final bookingRequest = _tripDetail!['booking_request'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goods Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookingRequest['goods_quantity']} ${bookingRequest['goods_type']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pickup Time: ${_formatDateTime(bookingRequest['pickup_time'])}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    final bookingRequest = _tripDetail!['booking_request'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              'Sender',
              bookingRequest['sender_name'] ?? 'N/A',
              bookingRequest['sender_phone'] ?? '',
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              'Receiver',
              bookingRequest['receiver_name'] ?? 'N/A',
              bookingRequest['receiver_phone'] ?? '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(String label, String name, String phone) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                phone,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: phone.isNotEmpty ? () => _makePhoneCall(phone) : null,
          icon: const Icon(Icons.phone, color: Colors.green),
        ),
      ],
    );
  }

  Widget _buildTimingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trip Timeline',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimingRow('Trip Started', _tripDetail!['created_at']),
            if (_tripDetail!['loading_start_time'] != null)
              _buildTimingRow('Loading Started', _tripDetail!['loading_start_time']),
            if (_tripDetail!['loading_end_time'] != null)
              _buildTimingRow('Loading Completed', _tripDetail!['loading_end_time']),
            if (_tripDetail!['unloading_start_time'] != null)
              _buildTimingRow('Unloading Started', _tripDetail!['unloading_start_time']),
            if (_tripDetail!['unloading_end_time'] != null)
              _buildTimingRow('Unloading Completed', _tripDetail!['unloading_end_time']),
            if (_tripDetail!['payment_time'] != null)
              _buildTimingRow('Payment Completed', _tripDetail!['payment_time']),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingRow(String label, String? dateTimeStr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            _formatDateTime(dateTimeStr),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final bookingRequest = _tripDetail!['booking_request'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payment, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Fare:'),
                          Text('₹${bookingRequest['estimated_fare']}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Final Fare:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${_tripDetail!['final_fare']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Mode:'),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: bookingRequest['payment_mode'] == 'CASH' 
                                  ? Colors.green.withOpacity(0.1) 
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              bookingRequest['payment_mode'] ?? 'N/A',
                              style: TextStyle(
                                color: bookingRequest['payment_mode'] == 'CASH' 
                                    ? Colors.green 
                                    : Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 