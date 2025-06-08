import 'package:flutter/material.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:logistix_driver/screens/trip_detail_screen.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = false;
  int _totalTrips = 0;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrips({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _trips.clear();
      }
    });

    try {
      final response = await _authService.getDriverTrips(
        page: _currentPage,
        pageSize: 10,
      );

      if (response != null && mounted) {
        setState(() {
          _totalTrips = response['count'] ?? 0;
          final newTrips = List<Map<String, dynamic>>.from(response['results'] ?? []);
          
          if (refresh) {
            _trips = newTrips;
          } else {
            _trips.addAll(newTrips);
          }
          
          _hasMore = response['next'] != null;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Error fetching trips: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trips: $e'),
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

  List<Map<String, dynamic>> _getFilteredTrips(String filter) {
    switch (filter) {
      case 'active':
        return _trips.where((trip) => 
          trip['status'] != 'COMPLETED' && 
          trip['status'] != 'CANCELLED'
        ).toList();
      case 'completed':
        return _trips.where((trip) => 
          trip['status'] == 'COMPLETED'
        ).toList();
      case 'cancelled':
        return _trips.where((trip) => 
          trip['status'] == 'CANCELLED'
        ).toList();
      default:
        return _trips;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats Cards
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Trips',
                  _totalTrips.toString(),
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  _getFilteredTrips('active').length.toString(),
                  Icons.schedule,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _getFilteredTrips('completed').length.toString(),
                  Icons.check_circle,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Cancelled',
                  _getFilteredTrips('cancelled').length.toString(),
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
        
        // Tab Bar
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
                      tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
              Tab(text: 'All'),
            ],
        ),
        
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildActiveTrips(),
              _buildCompletedTrips(),
              _buildCancelledTrips(),
              _buildAllTrips(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrips() {
    return _buildTripsList('active');
  }

  Widget _buildCompletedTrips() {
    return _buildTripsList('completed');
  }

  Widget _buildCancelledTrips() {
    return _buildTripsList('cancelled');
  }

  Widget _buildAllTrips() {
    return _buildTripsList('all');
  }

  Widget _buildTripsList(String filter) {
    final filteredTrips = _getFilteredTrips(filter);
    
    if (_isLoading && _trips.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredTrips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter == 'all' ? '' : filter} trips found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${filter == 'all' ? '' : filter} trips will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchTrips(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: filteredTrips.length + (_hasMore && filter == 'all' ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredTrips.length) {
            // Load more button
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _fetchTrips(),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Load More'),
                ),
              ),
            );
          }

          final trip = filteredTrips[index];
          final bookingRequest = trip['booking_request'];
          
          return _buildTripCardFromApi(trip, bookingRequest);
        },
      ),
    );
  }

  Widget _buildTripCardFromApi(Map<String, dynamic> trip, Map<String, dynamic> bookingRequest) {
    final status = trip['status'] ?? '';
    final isActive = status != 'COMPLETED' && status != 'CANCELLED';
    
    Color statusColor;
    switch (status) {
      case 'COMPLETED':
        statusColor = Colors.green;
        break;
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      case 'ACCEPTED':
        statusColor = Colors.blue;
        break;
      case 'TRIP_STARTED':
        statusColor = Colors.orange;
        break;
      case 'LOADING_STARTED':
      case 'LOADING_DONE':
        statusColor = Colors.purple;
        break;
      case 'REACHED_DESTINATION':
      case 'UNLOADING_STARTED':
      case 'UNLOADING_DONE':
        statusColor = Colors.teal;
        break;
      default:
        statusColor = Colors.grey;
    }

    final createdAt = DateTime.parse(trip['created_at']);
    final timeAgo = _formatTimeAgo(createdAt);

    return _buildTripCard(
      tripId: 'TRP${trip['id']}',
      fromLocation: bookingRequest['pickup_address'] ?? '',
      toLocation: bookingRequest['dropoff_address'] ?? '',
      status: status,
      statusColor: statusColor,
      fare: '₹${trip['final_fare']?.toString() ?? '0'}',
      goods: '${bookingRequest['goods_quantity']} ${bookingRequest['goods_type']}',
      time: timeAgo,
      paymentMode: bookingRequest['payment_mode'] ?? '',
      isActive: isActive,
      apiTripId: trip['id'],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  Widget _buildTripCard({
    required String tripId,
    required String fromLocation,
    required String toLocation,
    required String status,
    required Color statusColor,
    required String fare,
    required String goods,
    required String time,
    required String paymentMode,
    required bool isActive,
    int? apiTripId,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: apiTripId != null ? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(
                tripId: apiTripId,
                tripDisplayId: tripId,
              ),
            ),
          );
        } : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Trip ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tripId,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Route Information
            Row(
              children: [
                Icon(Icons.my_location, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fromLocation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    toLocation,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Trip Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goods',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        goods,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        paymentMode,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      fare,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Action Buttons for Active Trips
            if (isActive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: View trip details
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Continue trip
                      },
                      icon: const Icon(Icons.navigation),
                      label: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}