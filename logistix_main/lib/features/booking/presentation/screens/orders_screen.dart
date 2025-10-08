/// orders_screen.dart - Order History and Management Interface
/// 
/// Purpose:
/// - Displays comprehensive order history with different order states
/// - Provides tabbed interface for ongoing, completed, and cancelled orders
/// - Manages order list pagination and real-time updates
/// 
/// Key Logic:
/// - Implements tabbed interface for different order categories
/// - Fetches booking list and trip details from BookingService
/// - Provides pagination support for large order lists
/// - Shows order status, dates, addresses, and fare information
/// - Navigates to detailed trip view for each order
/// - Implements pull-to-refresh for updated order data
/// - Filters orders by status (ongoing, completed, cancelled)
/// - Displays appropriate empty states for each category
/// - Handles loading states and error conditions gracefully

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/services/booking_service.dart';
import '../../data/models/booking_list_response.dart';
import '../../data/models/trip_detail.dart';
import 'trip_details_screen.dart';

enum OrderType { ongoing, completed, cancelled }

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late final BookingService _bookingService;
  late final TabController _tabController;
  
  // Pagination constants
  static const int _pageSize = 10;
  
  // Data lists
  List<BookingListItem> _allBookings = [];
  List<TripDetail> _allTrips = [];
  
  // Loading states
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  
  // Pagination state for each tab
  Map<OrderType, int> _currentPages = {
    OrderType.ongoing: 1,
    OrderType.completed: 1,
    OrderType.cancelled: 1,
  };
  
  Map<OrderType, bool> _hasMoreData = {
    OrderType.ongoing: true,
    OrderType.completed: true,
    OrderType.cancelled: true,
  };
  
  Map<OrderType, List<dynamic>> _paginatedOrders = {
    OrderType.ongoing: [],
    OrderType.completed: [],
    OrderType.cancelled: [],
  };

  // Scroll controllers for each tab
  late ScrollController _ongoingScrollController;
  late ScrollController _completedScrollController;
  late ScrollController _cancelledScrollController;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService(serviceLocator());
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize scroll controllers
    _ongoingScrollController = ScrollController();
    _completedScrollController = ScrollController();
    _cancelledScrollController = ScrollController();
    
    // Add scroll listeners
    _ongoingScrollController.addListener(() => _onScroll(OrderType.ongoing));
    _completedScrollController.addListener(() => _onScroll(OrderType.completed));
    _cancelledScrollController.addListener(() => _onScroll(OrderType.cancelled));
    
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ongoingScrollController.dispose();
    _completedScrollController.dispose();
    _cancelledScrollController.dispose();
    super.dispose();
  }

  void _onScroll(OrderType orderType) {
    ScrollController controller;
    switch (orderType) {
      case OrderType.ongoing:
        controller = _ongoingScrollController;
        break;
      case OrderType.completed:
        controller = _completedScrollController;
        break;
      case OrderType.cancelled:
        controller = _cancelledScrollController;
        break;
    }

    if (controller.position.pixels >= controller.position.maxScrollExtent * 0.9) {
      _loadMoreData(orderType);
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
      _error = null;
    });

    try {
      // Load initial data from API
      final bookingListResponse = await _bookingService.getBookingList();
      final tripList = await _bookingService.getTripList();
      
      setState(() {
        _allBookings = bookingListResponse.bookingRequests;
        _allTrips = tripList;
        _isInitialLoading = false;
      });

      // Populate initial pages for each tab
      _populateInitialPages();
      
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitialLoading = false;
      });
    }
  }

  void _populateInitialPages() {
    // Get all orders for each category
    final ongoingOrders = _getOngoingOrders();
    final completedOrders = _getCompletedOrders();
    final cancelledOrders = _getCancelledOrders();

    setState(() {
      // Load first page for each tab
      _paginatedOrders[OrderType.ongoing] = ongoingOrders.take(_pageSize).toList();
      _paginatedOrders[OrderType.completed] = completedOrders.take(_pageSize).toList();
      _paginatedOrders[OrderType.cancelled] = cancelledOrders.take(_pageSize).toList();

      // Update hasMore flags
      _hasMoreData[OrderType.ongoing] = ongoingOrders.length > _pageSize;
      _hasMoreData[OrderType.completed] = completedOrders.length > _pageSize;
      _hasMoreData[OrderType.cancelled] = cancelledOrders.length > _pageSize;
    });
  }

  Future<void> _loadMoreData(OrderType orderType) async {
    if (_isLoadingMore || !_hasMoreData[orderType]!) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      List<dynamic> allOrdersForType;
      switch (orderType) {
        case OrderType.ongoing:
          allOrdersForType = _getOngoingOrders();
          break;
        case OrderType.completed:
          allOrdersForType = _getCompletedOrders();
          break;
        case OrderType.cancelled:
          allOrdersForType = _getCancelledOrders();
          break;
      }

      final currentPage = _currentPages[orderType]!;
      final startIndex = currentPage * _pageSize;
      final endIndex = (startIndex + _pageSize).clamp(0, allOrdersForType.length);
      
      if (startIndex < allOrdersForType.length) {
        final newItems = allOrdersForType.sublist(startIndex, endIndex);
        
        setState(() {
          _paginatedOrders[orderType]!.addAll(newItems);
          _currentPages[orderType] = currentPage + 1;
          _hasMoreData[orderType] = endIndex < allOrdersForType.length;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData[orderType] = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  List<dynamic> _getOngoingOrders() {
    final ongoingBookings = _allBookings.where((booking) => 
      booking.status == 'REQUESTED' || 
      booking.status == 'SEARCHING' || 
      booking.status == 'ACCEPTED'
    ).toList();
    
    // Sort by creation date (newest first)
    ongoingBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ongoingBookings;
  }

  List<dynamic> _getCompletedOrders() {
    final completedBookings = _allBookings.where((booking) => 
      booking.status == 'COMPLETED' || 
      (booking.isAccepted && booking.tripId != null)
    ).toList();
    
    final completedTrips = _allTrips.where((trip) => 
      trip.status == 'COMPLETED' && trip.isPaymentDone
    ).toList();
    
    final allCompleted = [...completedBookings, ...completedTrips];
    // Sort by creation date (newest first)
    allCompleted.sort((a, b) {
      final aDate = a is BookingListItem ? a.createdAt : (a as TripDetail).createdAt;
      final bDate = b is BookingListItem ? b.createdAt : (b as TripDetail).createdAt;
      return bDate.compareTo(aDate);
    });
    
    return allCompleted;
  }

  List<dynamic> _getCancelledOrders() {
    final cancelledBookings = _allBookings.where((booking) => 
      booking.status == 'CANCELLED'
    ).toList();
    
    final cancelledTrips = _allTrips.where((trip) => 
      trip.status == 'CANCELLED'
    ).toList();
    
    final allCancelled = [...cancelledBookings, ...cancelledTrips];
    // Sort by creation date (newest first)
    allCancelled.sort((a, b) {
      final aDate = a is BookingListItem ? a.createdAt : (a as TripDetail).createdAt;
      final bDate = b is BookingListItem ? b.createdAt : (b as TripDetail).createdAt;
      return bDate.compareTo(aDate);
    });
    
    return allCancelled;
  }

  Future<void> _refreshData() async {
    // Reset pagination state
    setState(() {
      _currentPages = {
        OrderType.ongoing: 1,
        OrderType.completed: 1,
        OrderType.cancelled: 1,
      };
      _hasMoreData = {
        OrderType.ongoing: true,
        OrderType.completed: true,
        OrderType.cancelled: true,
      };
      _paginatedOrders = {
        OrderType.ongoing: [],
        OrderType.completed: [],
        OrderType.cancelled: [],
      };
    });
    
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickActions(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Quick Actions'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
        title: Text(
          'My Orders',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.labelMedium,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_empty_rounded, size: 16),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Ongoing',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_paginatedOrders[OrderType.ongoing]!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_getOngoingOrders().length}',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Completed',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_paginatedOrders[OrderType.completed]!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_getCompletedOrders().length}',
                            style: TextStyle(
                              color: theme.colorScheme.onSecondary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cancel_outlined, size: 16),
                      const SizedBox(width: 4),
                      const Flexible(
                        child: Text(
                          'Cancelled',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_paginatedOrders[OrderType.cancelled]!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_getCancelledOrders().length}',
                            style: TextStyle(
                              color: theme.colorScheme.onError,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isInitialLoading
          ? _buildLoadingState(theme)
          : _error != null
              ? _buildErrorState(theme)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOrdersTab(theme, OrderType.ongoing, _ongoingScrollController),
                    _buildOrdersTab(theme, OrderType.completed, _completedScrollController),
                    _buildOrdersTab(theme, OrderType.cancelled, _cancelledScrollController),
                  ],
                ),
    );
  }

  Widget _buildOrdersTab(ThemeData theme, OrderType orderType, ScrollController scrollController) {
    final orders = _paginatedOrders[orderType]!;
    final hasMore = _hasMoreData[orderType]!;
    
    if (orders.isEmpty && !_isInitialLoading) {
      return _buildEmptyState(theme, orderType);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: orders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            // Loading indicator at the bottom
            return _buildLoadingMoreIndicator(theme);
          }
          
          final order = orders[index];
          return _buildOrderCard(theme, order, orderType);
        },
      ),
    );
  }

  Widget _buildLoadingMoreIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      alignment: Alignment.center,
      child: _isLoadingMore
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Loading more orders...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            )
          : Text(
              'Scroll to load more',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading your orders...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Unable to load orders',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please check your internet connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, OrderType orderType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getOrderTypeIcon(orderType),
                size: 64,
                color: theme.colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _getOrderTypeTitle(orderType),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _getOrderTypeMessage(orderType),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(ThemeData theme, dynamic order, OrderType type) {
    if (order is BookingListItem) {
      return _buildBookingCard(theme, order, type);
    } else if (order is TripDetail) {
      return _buildTripCard(theme, order, type);
    }
    return const SizedBox.shrink();
  }

  Widget _buildBookingCard(ThemeData theme, BookingListItem booking, OrderType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _onBookingTapped(booking),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: booking.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: booking.statusColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      booking.statusMessage,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: booking.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(booking.createdAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Route information
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 40,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.shortPickupAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          booking.shortDropoffAddress,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Bottom row with goods and fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${booking.goodsType} • ${booking.goodsQuantity}',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${booking.estimatedFare.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(ThemeData theme, TripDetail trip, OrderType type) {
    final booking = trip.bookingRequest;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _onTripTapped(trip),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with trip status and driver info
              Row(
                children: [
                  _buildDriverAvatar(theme, trip.driver),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.driver?.user.fullName ?? 'Driver',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              trip.driver?.rating.toStringAsFixed(1) ?? '0.0',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTripStatusColor(trip.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(
                        color: _getTripStatusColor(trip.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getTripStatusMessage(trip.status),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getTripStatusColor(trip.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              
              // Route information
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getShortAddress(booking.pickupAddress),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _getShortAddress(booking.dropoffAddress),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Show call/message buttons only if trip is not completed and payment not done
              if (!(trip.isCompleted && trip.isPaymentDone)) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement call functionality
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement message functionality
                        },
                        icon: const Icon(Icons.message, size: 16),
                        label: const Text('Message'),
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

  void _onBookingTapped(BookingListItem booking) {
    if (booking.tripId != null && booking.isAccepted) {
      // Navigate to trip details if booking is accepted and has trip_id
      _navigateToTripDetails(booking.tripId!);
    } else {
      // Navigate to booking details for other cases
      _navigateToBookingDetails(booking);
    }
  }

  void _onTripTapped(TripDetail trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(tripDetail: trip),
      ),
    );
  }

  void _navigateToTripDetails(int tripId) async {
    try {
      final tripDetail = await _bookingService.getTripDetail(tripId);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(tripDetail: tripDetail),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load trip details: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToBookingDetails(BookingListItem booking) {
    // Since BookingDetailsScreen expects different parameters, 
    // we'll show a simple dialog for now or create a booking details viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking #${booking.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${booking.statusMessage}'),
            const SizedBox(height: AppSpacing.sm),
            Text('From: ${booking.pickupAddress}'),
            const SizedBox(height: AppSpacing.sm),
            Text('To: ${booking.dropoffAddress}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Goods: ${booking.goodsType} (${booking.goodsQuantity})'),
            const SizedBox(height: AppSpacing.sm),
            Text('Fare: ₹${booking.estimatedFare.toStringAsFixed(0)}'),
            const SizedBox(height: AppSpacing.sm),
            Text('Payment: ${booking.paymentMode}'),
          ],
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

  String _getShortAddress(String address) {
    final parts = address.split(',');
    return parts.length > 2 ? '${parts[0]}, ${parts[1]}' : address;
  }

  Widget _buildDriverAvatar(ThemeData theme, Driver? driver) {
    final String initial = driver?.user.firstName.substring(0, 1).toUpperCase() ?? 'D';
    
    if (driver?.user.profilePicture != null && driver!.user.profilePicture!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: ClipOval(
          child: Image.network(
            'http://localhost:8000${driver.user.profilePicture}',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary,
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
  }

  Color _getTripStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return const Color(0xFF2196F3); // Blue
      case 'LOADING_STARTED':
      case 'UNLOADING_STARTED':
        return const Color(0xFFFF9800); // Orange
      case 'LOADING_DONE':
      case 'REACHED_DESTINATION':
        return const Color(0xFF4CAF50); // Green
      case 'COMPLETED':
        return const Color(0xFF4CAF50); // Green
      case 'CANCELLED':
        return const Color(0xFFE91E63); // Red
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  String _getTripStatusMessage(String status) {
    switch (status) {
      case 'ACCEPTED':
        return 'On the way';
      case 'LOADING_STARTED':
        return 'Loading';
      case 'LOADING_DONE':
        return 'In transit';
      case 'REACHED_DESTINATION':
        return 'Arrived';
      case 'UNLOADING_STARTED':
        return 'Unloading';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.ongoing:
        return Icons.hourglass_empty_rounded;
      case OrderType.completed:
        return Icons.check_circle_outline_rounded;
      case OrderType.cancelled:
        return Icons.cancel_outlined;
    }
  }

  String _getOrderTypeTitle(OrderType type) {
    switch (type) {
      case OrderType.ongoing:
        return 'Ongoing Orders';
      case OrderType.completed:
        return 'Completed Orders';
      case OrderType.cancelled:
        return 'Cancelled Orders';
    }
  }

  String _getOrderTypeMessage(OrderType type) {
    switch (type) {
      case OrderType.ongoing:
        return 'You don\'t have any active orders at the moment.\nNew bookings will appear here.';
      case OrderType.completed:
        return 'Your completed deliveries will appear here.\nKeep track of your order history.';
      case OrderType.cancelled:
        return 'You haven\'t cancelled any orders.\nCancelled orders will be shown here.';
    }
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.add_shopping_cart,
                      title: 'New Booking',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/booking');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.schedule,
                      title: 'Scheduled',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/scheduled-booking');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.repeat,
                      title: 'Recurring',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/recurring-booking');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      icon: Icons.support_agent,
                      title: 'Support',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/support-center');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 