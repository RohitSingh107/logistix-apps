import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/stop_point_model.dart';
import '../../../../core/models/booking_model.dart';
import '../../domain/repositories/trip_repository.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  int _selectedTab = 0; // 0: All, 1: Active, 2: Completed, 3: Cancelled
  int _selectedDateFilter = 0; // 0: Today, 1: Week, 2: Month
  static const int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial trips
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripBloc>().add(const LoadTrips());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<TripBloc>().state;
      if (state is TripLoaded && state.hasNextPage && !state.isLoadingMore) {
        _currentPage++;
        context.read<TripBloc>().add(LoadMoreTrips(
          page: _currentPage,
          pageSize: _pageSize,
        ));
      }
    }
  }

  void _onRefresh() {
    _currentPage = 1;
    context.read<TripBloc>().add(const RefreshTrips());
  }

  void _onTripTap(Trip trip) {
    // Navigate to trip details for completed/cancelled trips
    // Navigate to active trip screen for in-progress trips
    if (trip.isCompleted || trip.isCancelled) {
      Navigator.of(context).pushNamed(
        '/trip-details',
        arguments: trip,
      );
    } else {
      Navigator.of(context).pushNamed(
        '/driver-trip',
        arguments: trip,
      );
    }
  }

  List<Trip> _filterTripsByTab(List<Trip> trips) {
    switch (_selectedTab) {
      case 0: // All
        return trips;
      case 1: // Active
        return trips.where((trip) => trip.status == TripStatus.accepted || trip.status == TripStatus.inProgress).toList();
      case 2: // Completed
        return trips.where((trip) => trip.status == TripStatus.completed).toList();
      case 3: // Cancelled
        return trips.where((trip) => trip.status == TripStatus.cancelled).toList();
      default:
        return trips;
    }
  }

  List<Trip> _filterTripsByDateRange(List<Trip> trips) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedDateFilter) {
      case 0: // Today
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 1: // Week
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 2: // Month
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        return trips;
    }
    
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return trips.where((trip) {
      final tripDate = trip.createdAt;
      return tripDate.isAfter(startDate.subtract(const Duration(days: 1))) && 
             tripDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  Map<String, dynamic> _calculateStatistics(List<Trip> trips) {
    final filteredByDate = _filterTripsByDateRange(trips);
    final tripsCount = filteredByDate.length;
    
    double totalEarnings = 0.0;
    for (var trip in filteredByDate) {
      // Use finalFare if available, otherwise use estimatedFare from bookingRequest
      if (trip.finalFare != null) {
        totalEarnings += trip.finalFare!;
      } else {
        totalEarnings += trip.bookingRequest.estimatedFare;
      }
    }
    
    return {
      'trips': tripsCount,
      'earnings': totalEarnings,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
          // Content
          Expanded(
            child: BlocProvider(
              create: (context) => TripBloc(serviceLocator<TripRepository>())
                ..add(const LoadTrips()),
              child: BlocBuilder<TripBloc, TripState>(
                builder: (context, state) {
                  if (state is TripInitial || state is TripLoading) {
                    return _buildLoadingState();
                  }
                  
                  if (state is TripError) {
                    return _buildErrorState(state.message);
                  }
                  
                  if (state is TripLoaded) {
                    final filteredTrips = _filterTripsByTab(state.trips);
                    if (filteredTrips.isEmpty) {
                      return _buildEmptyState(state.trips);
                    }
                    
                    return _buildTripList(state, filteredTrips);
                  }
                  
                  if (state is TripRefreshing) {
                    final filteredTrips = _filterTripsByTab(state.trips);
                    return _buildTripList(state, filteredTrips);
                  }
                  
                  if (state is TripLoadingMore) {
                    final filteredTrips = _filterTripsByTab(state.trips);
                    return _buildTripList(state, filteredTrips);
                  }
                  
                  return _buildLoadingState();
                },
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: 9,
      ),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.00, 0.00),
                end: Alignment(1.00, 1.00),
                colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Image.asset(
              'assets/images/logo without text/logo color.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'My Trips',
              style: TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Online',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed('/alerts');
                },
                child: Container(
                  width: 22,
                  height: 22,
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 22,
                    color: Color(0xFF0B1220),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildTabBar(),
        _buildDateFilterAndStats([]),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        _buildTabBar(),
        _buildDateFilterAndStats([]),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load trips',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TripBloc>().add(const LoadTrips());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(List<Trip> allTrips) {
    return Column(
      children: [
        _buildTabBar(),
        _buildDateFilterAndStats(allTrips),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No ${_getTabName()} trips',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ${_getTabName().toLowerCase()} trips will appear here',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getTabName() {
    switch (_selectedTab) {
      case 0:
        return 'All';
      case 1:
        return 'Active';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      default:
        return 'trips';
    }
  }

  Widget _buildDateFilterAndStats(List<Trip> trips) {
    // Apply tab filter first, then date filter in _calculateStatistics
    final filteredByTab = _filterTripsByTab(trips);
    final stats = _calculateStatistics(filteredByTab);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Date Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = 0;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: ShapeDecoration(
                    color: _selectedDateFilter == 0 ? const Color(0xFFFF6B00) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _selectedDateFilter == 0 ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: _selectedDateFilter == 0 ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = 1;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: ShapeDecoration(
                    color: _selectedDateFilter == 1 ? const Color(0xFFFF6B00) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _selectedDateFilter == 1 ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Week',
                    style: TextStyle(
                      color: _selectedDateFilter == 1 ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = 2;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: ShapeDecoration(
                    color: _selectedDateFilter == 2 ? const Color(0xFFFF6B00) : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: _selectedDateFilter == 2 ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    'Month',
                    style: TextStyle(
                      color: _selectedDateFilter == 2 ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Statistics Cards
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Trips',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stats['trips']}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Earnings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${stats['earnings'].toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF111111),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripList(dynamic state, List<Trip> trips) {
    final isLoadingMore = state is TripLoaded ? state.isLoadingMore : false;
    List<Trip> allTrips = [];
    if (state is TripLoaded) {
      allTrips = state.trips;
    } else if (state is TripRefreshing) {
      allTrips = state.trips;
    } else if (state is TripLoadingMore) {
      allTrips = state.trips;
    }
    
    return Column(
      children: [
        _buildTabBar(),
        _buildDateFilterAndStats(allTrips),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: trips.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == trips.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final trip = trips[index];
                return _buildTripCard(trip);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 9),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(9),
                decoration: ShapeDecoration(
                  color: _selectedTab == 0 ? const Color(0xFFFF6B00) : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: _selectedTab == 0 ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'All',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(9),
                decoration: ShapeDecoration(
                  color: _selectedTab == 1 ? const Color(0xFFFF6B00) : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: _selectedTab == 1 ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Active',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 2;
                });
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(9),
                decoration: ShapeDecoration(
                  color: _selectedTab == 2 ? const Color(0xFFFF6B00) : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE6E6E6),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Completed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 3;
                });
              },
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(9),
                decoration: ShapeDecoration(
                  color: _selectedTab == 3 ? const Color(0xFFFF6B00) : const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE6E6E6),
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Cancelled',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final booking = trip.bookingRequest;
    final stopPoints = booking.stopPoints ?? [];
    
    if (stopPoints.isEmpty) {
      // Fallback if no stop points
      return Container(
        padding: const EdgeInsets.all(13),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE6E6E6)),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('No stop points available'),
      );
    }
    
    final pickupStop = stopPoints.firstWhere(
      (stop) => stop.stopType == StopType.pickup,
      orElse: () => stopPoints.first,
    );
    final dropoffStop = stopPoints.firstWhere(
      (stop) => stop.stopType == StopType.dropoff,
      orElse: () => stopPoints.length > 1 ? stopPoints.last : pickupStop,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _onTripTap(trip),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE6E6E6),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.goodsType,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order #${trip.id} • ${_formatDate(trip.createdAt)}',
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(trip.status),
                ],
              ),
              const SizedBox(height: 8),
              // Route visualization
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dots and line
                  Container(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFFF7A1A),
                            shape: CircleBorder(),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 2,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE6E6E6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFFF7A1A),
                            shape: CircleBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Addresses
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                pickupStop.address.split(',').first,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dropoffStop.address.split(',').first,
                                style: const TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
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
              const SizedBox(height: 8),
              // ETA/Payment info and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildInfoBadge(trip),
                  Text(
                    '\$${trip.finalFare?.toStringAsFixed(2) ?? booking.estimatedFare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Action buttons
              _buildActionButtons(trip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TripStatus status) {
    String text;
    Color color;
    
    switch (status) {
      case TripStatus.accepted:
        text = 'Awaiting\nPickup';
        color = const Color(0xFFF59E0B);
        break;
      case TripStatus.inProgress:
        text = 'In Transit';
        color = const Color(0xFF16A34A);
        break;
      case TripStatus.completed:
        text = 'Delivered';
        color = const Color(0xFF16A34A);
        break;
      case TripStatus.cancelled:
        text = 'Cancelled';
        color = const Color(0xFFDC2626);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: status == TripStatus.accepted ? const Color(0xFF111111) : Colors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoBadge(Trip trip) {
    String text;
    
    if (trip.status == TripStatus.completed) {
      final paymentMode = trip.bookingRequest.paymentMode;
      String paymentText;
      switch (paymentMode) {
        case PaymentMode.cash:
          paymentText = 'Cash';
          break;
        case PaymentMode.wallet:
          paymentText = 'Wallet';
          break;
      }
      text = 'Paid • $paymentText';
    } else if (trip.status == TripStatus.cancelled) {
      text = 'Payment Refunded';
    } else if (trip.status == TripStatus.inProgress) {
      text = 'ETA 12 min'; // TODO: Calculate actual ETA
    } else {
      text = 'Driver 4 min away'; // TODO: Calculate actual driver distance
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(
        color: const Color(0xFF333333),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionButtons(Trip trip) {
    if (trip.status == TripStatus.completed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE6E6E6),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Invoice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE6E6E6),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh, size: 18, color: Color(0xFF111111)),
                  SizedBox(width: 8),
                  Text(
                    'Rebook',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (trip.status == TripStatus.cancelled) {
      return const SizedBox.shrink();
    } else {
      // Active/In Progress
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFF333333),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE6E6E6),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Chat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: ShapeDecoration(
                color: const Color(0xFFFF6B00),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFFF6B00),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: InkWell(
                onTap: () => _onTripTap(trip),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Track',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today, ${DateFormat('HH:mm').format(date)}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('d MMM, HH:mm').format(date);
    }
  }
}
