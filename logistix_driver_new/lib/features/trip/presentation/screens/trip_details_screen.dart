/// trip_details_screen.dart - Trip Details Screen
/// 
/// Purpose:
/// - Display detailed information about a completed or past trip
/// - Show route, payment breakdown, and customer information
/// - Provide actions like viewing trip history and sharing receipt
/// 
/// Key Features:
/// - Map view showing the route
/// - Trip information (ID, date, status)
/// - Route details with pickup and dropoff locations
/// - Payment breakdown
/// - Customer information
/// - Action buttons (Support, Invoice, Trip History, Share Receipt)
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/stop_point_model.dart';

class TripDetailsScreen extends StatelessWidget {
  final Trip? trip;
  final Booking? booking;

  const TripDetailsScreen({
    super.key,
    this.trip,
    this.booking,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (date == today) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return DateFormat('h:mm a').format(dateTime);
  }

  Widget _buildStopPointsList(Booking? bookingData, Trip? trip) {
    // Get stop points from trip or booking
    List<StopPoint>? stopPoints = trip?.stopPoints ?? bookingData?.stopPoints;
    
    // If no stop points, show fallback pickup/dropoff
    if (stopPoints == null || stopPoints.isEmpty) {
      String pickupAddress = bookingData?.pickupAddress ?? 'Blue Mall Entrance A';
      String pickupLocation = 'Sector 21, Noida • Gate 3';
      String dropoffAddress = bookingData?.dropoffAddress ?? 'Green Park';
      String dropoffLocation = 'Block D, New Delhi';
      
      return Column(
        children: [
          _buildStopPointItem(
            address: pickupAddress,
            location: pickupLocation,
            stopType: StopType.pickup,
            time: trip?.loadingStartTime ?? trip?.createdAt,
            isFirst: true,
            isLast: false,
            stopPoint: null,
          ),
          const SizedBox(height: 16),
          _buildStopPointItem(
            address: dropoffAddress,
            location: dropoffLocation,
            stopType: StopType.dropoff,
            time: trip?.unloadingEndTime ?? trip?.updatedAt,
            isFirst: false,
            isLast: true,
            stopPoint: null,
          ),
        ],
      );
    }
    
    // Sort stop points by order
    final sortedStops = List<StopPoint>.from(stopPoints);
    sortedStops.sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    
    return Column(
      children: List.generate(sortedStops.length, (index) {
        final stop = sortedStops[index];
        final isFirst = index == 0;
        final isLast = index == sortedStops.length - 1;
        
        // Determine time based on stop type
        DateTime? time;
        if (stop.stopType == StopType.pickup) {
          time = trip?.loadingStartTime ?? trip?.createdAt;
        } else if (stop.stopType == StopType.dropoff) {
          time = trip?.unloadingEndTime ?? trip?.updatedAt;
        }
        
        return Column(
          children: [
            _buildStopPointItem(
              address: stop.address,
              location: stop.location,
              stopType: stop.stopType,
              time: time,
              contactName: stop.contactName,
              contactPhone: stop.contactPhone,
              notes: stop.notes,
              isFirst: isFirst,
              isLast: isLast,
              stopPoint: stop,
            ),
            if (!isLast) const SizedBox(height: 16),
          ],
        );
      }),
    );
  }

  void _showStopPointDetails(BuildContext context, StopPoint stop, DateTime? time) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildStopPointDetailsBottomSheet(context, stop, time),
    );
  }

  Widget _buildStopPointDetailsBottomSheet(BuildContext context, StopPoint stop, DateTime? time) {
    // Get icon and color based on stop type
    IconData icon;
    Color iconColor;
    String typeLabel;
    
    switch (stop.stopType) {
      case StopType.pickup:
        icon = Icons.location_on;
        iconColor = const Color(0xFF16A34A);
        typeLabel = 'Pickup';
        break;
      case StopType.dropoff:
        icon = Icons.location_on;
        iconColor = const Color(0xFFDC2626);
        typeLabel = 'Dropoff';
        break;
      case StopType.waypoint:
        icon = Icons.location_on;
        iconColor = const Color(0xFFFF6B00);
        typeLabel = 'Waypoint';
        break;
    }

    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 13,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: ShapeDecoration(
                        color: iconColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            typeLabel,
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (time != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(time),
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Address Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Address',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stop.address,
                        style: const TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (stop.location.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Location',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stop.location,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Contact Information
                if (stop.contactName != null || stop.contactPhone != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (stop.contactName != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 18,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stop.contactName!,
                                  style: const TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (stop.contactPhone != null) const SizedBox(height: 8),
                        ],
                        if (stop.contactPhone != null) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  stop.contactPhone!,
                                  style: const TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // TODO: Implement call functionality
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                // Notes
                if (stop.notes != null && stop.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stop.notes!,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Stop Order
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stop Order',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: ShapeDecoration(
                          color: iconColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          '${stop.stopOrder}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopPointItem({
    required String address,
    String? location,
    required StopType stopType,
    DateTime? time,
    String? contactName,
    String? contactPhone,
    String? notes,
    required bool isFirst,
    required bool isLast,
    StopPoint? stopPoint,
  }) {
    // Get icon and color based on stop type
    IconData icon;
    Color iconColor;
    String typeLabel;
    
    switch (stopType) {
      case StopType.pickup:
        icon = Icons.location_on;
        iconColor = const Color(0xFF16A34A);
        typeLabel = 'Pickup';
        break;
      case StopType.dropoff:
        icon = Icons.location_on;
        iconColor = const Color(0xFFDC2626);
        typeLabel = 'Drop';
        break;
      case StopType.waypoint:
        icon = Icons.location_on;
        iconColor = const Color(0xFFFF6B00);
        typeLabel = 'Stop';
        break;
    }
    
    return Builder(
      builder: (context) => InkWell(
        onTap: stopPoint != null ? () => _showStopPointDetails(context, stopPoint, time) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Icon with connecting line
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                color: iconColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(height: 4),
              Container(
                width: 2,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                address,
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (location != null) ...[
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (contactName != null || contactPhone != null) ...[
                const SizedBox(height: 4),
                Text(
                  contactName != null && contactPhone != null
                      ? '$contactName • $contactPhone'
                      : contactName ?? contactPhone ?? '',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (notes != null && notes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              if (time != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF3F4F6),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: Text(
                    '$typeLabel ${_formatTime(time)}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripId = trip?.id ?? 4824;
    final bookingData = booking ?? trip?.bookingRequest;
    final tripStatus = trip?.status ?? TripStatus.completed;
    final createdAt = trip?.createdAt ?? DateTime.now();
    final finalFare = trip?.finalFare ?? 260.0;
    final finalDistance = trip?.finalDistance ?? '6.4';
    final finalDuration = trip?.finalDuration ?? 22;
    final paymentMode = bookingData?.paymentMode ?? PaymentMode.wallet;

    // Calculate payment breakdown (example values)
    final baseFare = 140.0;
    final distanceFare = 96.0;
    final timeFare = 24.0;
    final promotions = 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 16,
                  right: 16,
                  bottom: 9,
                ),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE6E6E6),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/logo without text/logo color.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Trip Details',
                        style: TextStyle(
                          color: const Color(0xFF111111),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF3F4F6),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFE6E6E6),
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            'Online',
                            style: TextStyle(
                              color: const Color(0xFF9CA3AF),
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
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Map View
              Container(
                width: double.infinity,
                height: 220,
                decoration: ShapeDecoration(
                  image: DecorationImage(
                    image: NetworkImage("https://placehold.co/375x220"),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE6E6E6),
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating Info Cards
                    Positioned(
                      left: 12,
                      top: 15,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 7,
                            ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Color(0xFF111111),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$finalDuration min',
                                  style: TextStyle(
                                    color: const Color(0xFF111111),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 7,
                            ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.straighten,
                                  size: 16,
                                  color: Color(0xFF111111),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$finalDistance km',
                                  style: TextStyle(
                                    color: const Color(0xFF111111),
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 7,
                            ),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: Color(0xFF111111),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tripStatus == TripStatus.completed ? 'Completed' : 'Cancelled',
                                  style: TextStyle(
                                    color: const Color(0xFF111111),
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
                  ],
                ),
              ),
            ],
          ),
          // Bottom Sheet
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              builder: (context, scrollController) => Container(
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE6E6E6),
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 13,
                      left: 17,
                      right: 17,
                      bottom: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF3F4F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Trip ID and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '#LD-$tripId',
                                  style: TextStyle(
                                    color: const Color(0xFF111111),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 3,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE6E6E6),
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: Text(
                                    _formatDateTime(createdAt),
                                    style: TextStyle(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: ShapeDecoration(
                                color: tripStatus == TripStatus.completed
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFDC2626),
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFE6E6E6),
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                tripStatus == TripStatus.completed ? 'Completed' : 'Cancelled',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Route Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(1),
                          clipBehavior: Clip.antiAlias,
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
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 12,
                                  right: 12,
                                  bottom: 11,
                                ),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFE6E6E6),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Route',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFE6E6E6),
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: Text(
                                        '$finalDistance km • $finalDuration min',
                                        style: TextStyle(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: _buildStopPointsList(bookingData, trip),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Payment Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(1),
                          clipBehavior: Clip.antiAlias,
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
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 12,
                                  right: 12,
                                  bottom: 11,
                                ),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFE6E6E6),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Payment',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFE6E6E6),
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: Text(
                                        paymentMode == PaymentMode.wallet
                                            ? 'Paid Online'
                                            : 'Cash',
                                        style: TextStyle(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Base Fare',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '₹${baseFare.toInt()}',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Distance ($finalDistance km)',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '₹${distanceFare.toInt()}',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Time ($finalDuration min)',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '₹${timeFare.toInt()}',
                                          style: TextStyle(
                                            color: const Color(0xFF111111),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Promotions',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '₹${promotions.toInt()}',
                                          style: TextStyle(
                                            color: const Color(0xFF9CA3AF),
                                            fontSize: 13,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 9),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.only(top: 9),
                                      decoration: ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFE6E6E6),
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Earned',
                                            style: TextStyle(
                                              color: const Color(0xFF111111),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '₹${finalFare.toInt()}',
                                            style: TextStyle(
                                              color: const Color(0xFF111111),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Customer Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(1),
                          clipBehavior: Clip.antiAlias,
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
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 12,
                                  right: 12,
                                  bottom: 11,
                                ),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFE6E6E6),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Customer',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 3,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                            width: 1,
                                            color: Color(0xFFE6E6E6),
                                          ),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                      child: Text(
                                        '5★',
                                        style: TextStyle(
                                          color: const Color(0xFF9CA3AF),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: ShapeDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage("https://placehold.co/36x36"),
                                              fit: BoxFit.fill,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                bookingData?.senderName ?? 'Ankit Sharma',
                                                style: TextStyle(
                                                  color: const Color(0xFF111111),
                                                  fontSize: 15,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                paymentMode == PaymentMode.wallet
                                                    ? 'Paid Online • UPI'
                                                    : 'Cash Payment',
                                                style: TextStyle(
                                                  color: const Color(0xFF9CA3AF),
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
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(9),
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Order ID',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9CA3AF),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '#A9831',
                                                  style: TextStyle(
                                                    color: const Color(0xFF111111),
                                                    fontSize: 15,
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
                                            padding: const EdgeInsets.all(9),
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
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Contact',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9CA3AF),
                                                    fontSize: 12,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Hidden',
                                                  style: TextStyle(
                                                    color: const Color(0xFF111111),
                                                    fontSize: 15,
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
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle Support
                                            },
                                            child: Container(
                                              height: 44,
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
                                                  const Icon(
                                                    Icons.help_outline,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    ' Support',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              // TODO: Handle Invoice
                                            },
                                            child: Container(
                                              height: 44,
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
                                                  const Icon(
                                                    Icons.receipt_long,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    ' Invoice',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  height: 48,
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
                                      const Icon(
                                        Icons.history,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ' Trip History',
                                        textAlign: TextAlign.center,
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // TODO: Handle Share Receipt
                                },
                                child: Container(
                                  height: 48,
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.share,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        ' Share Receipt',
                                        textAlign: TextAlign.center,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE6E6E6),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16,
            right: 16.03,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomNavItem(Icons.home_outlined, 'Home', false, () {
                Navigator.of(context).pushReplacementNamed('/home');
              }),
              _buildBottomNavItem(Icons.local_shipping, 'Trips', true, () {
                // Already on trips screen
              }),
              _buildBottomNavItem(Icons.account_balance_wallet_outlined, 'Earnings', false, () {
                Navigator.of(context).pushNamed('/wallet');
              }),
              _buildBottomNavItem(Icons.notifications_outlined, 'Alerts', false, () {
                Navigator.of(context).pushNamed('/alerts');
              }),
              _buildBottomNavItem(Icons.settings_outlined, 'Profile', false, () {
                Navigator.of(context).pushNamed('/settings');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? const Color(0xFF111111)
                    : const Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF111111)
                      : const Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

