/// ride_request_popup.dart - Ride Request Popup Widget
/// 
/// Purpose:
/// - Shows ride request details in a popup dialog
/// - Allows drivers to accept or reject rides
/// - Displays booking information clearly
/// - Handles ride request actions
/// 
/// Key Logic:
/// - Shows pickup and dropoff locations
/// - Displays fare and goods information
/// - Provides accept/reject buttons
/// - Handles booking actions
/// - Shows loading states during actions
library;

import 'package:flutter/material.dart';
import '../../../../core/models/notification_model.dart' as app_notification;
import '../../../../main.dart' show navigatorKey;

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
    final data = widget.notification.data;
    
    final bookingId = data?['booking_id']?.toString() ?? 'N/A';
    // Handle estimated_fare as String or num
    double estimatedFare = 186.0;
    final fareValue = data?['estimated_fare'];
    if (fareValue != null) {
      if (fareValue is num) {
        estimatedFare = fareValue.toDouble();
      } else if (fareValue is String) {
        estimatedFare = double.tryParse(fareValue) ?? 186.0;
      }
    }
    final pickupAddress = data?['pickup_address']?.toString() ?? '12 Market St';
    final dropoffAddress = data?['dropoff_address']?.toString() ?? '48 Riverside Ave, West End';
    final paymentMode = data?['payment_mode']?.toString() ?? 'WALLET';
    final vehicleType = data?['vehicle_type']?.toString() ?? 'Bike';
    final distance = data?['distance']?.toString() ?? '6.8';
    final eta = data?['eta']?.toString() ?? '9';
    final estimatedDuration = data?['estimated_duration']?.toString() ?? '18';
    final stopPoints = data?['stop_points'] as List?;
    final stopCount = stopPoints != null ? stopPoints.length : 0;
    
    // Parse stop points if available
    List<Map<String, dynamic>> parsedStopPoints = [];
    if (stopPoints != null && stopPoints.isNotEmpty) {
      parsedStopPoints = stopPoints
          .map((sp) => sp as Map<String, dynamic>)
          .toList();
      // Sort by stop_order if available
      parsedStopPoints.sort((a, b) {
        final orderA = a['stop_order'] ?? a['stopOrder'] ?? 0;
        final orderB = b['stop_order'] ?? b['stopOrder'] ?? 0;
        return (orderA as num).compareTo(orderB as num);
      });
    } else {
      // Fallback to pickup and dropoff if no stop points
      parsedStopPoints = [
        {
          'address': data?['pickup_location']?.toString() ?? pickupAddress,
          'stop_type': 'PICKUP',
          'stop_order': 0,
        },
        {
          'address': data?['dropoff_location']?.toString() ?? dropoffAddress,
          'stop_type': 'DROPOFF',
          'stop_order': 1,
        },
      ];
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 343,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: 17,
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Drag Handle
            Container(
              width: 44,
              height: 6,
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 44,
                height: 4,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE5E7EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            _buildHeader(),
            const SizedBox(height: 12),
            // Distance, Pickup, ETA Card
            _buildInfoCard(distance, pickupAddress, eta),
            const SizedBox(height: 12),
            // Route Visualization
            _buildRouteSection(parsedStopPoints),
            const SizedBox(height: 12),
            // Tags
            _buildTags(vehicleType, paymentMode, stopCount),
            const SizedBox(height: 12),
            // Fare Section
            _buildFareSection(estimatedFare, estimatedDuration),
            const SizedBox(height: 4),
            // Action Buttons
            _buildActionButtons(bookingId),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              child: const Icon(
                Icons.local_shipping,
                size: 24,
                color: Color(0xFF0B1220),
              ),
            ),
            const SizedBox(width: 8),
            const SizedBox(
              width: 135.56,
              height: 20,
              child: Text(
                'New Trip Request',
                style: TextStyle(
                  color: Color(0xFF0B1220),
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: ShapeDecoration(
            color: const Color(0xFF111827),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: const SizedBox(
            width: 41.70,
            height: 15,
            child: Text(
              'Priority',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String distance, String pickupAddress, String eta) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: ShapeDecoration(
        color: const Color(0xFF111827),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 68),
            padding: const EdgeInsets.only(right: 16.17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 49.58,
                  height: 15,
                  child: Text(
                    'Distance',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  width: 51.83,
                  height: 20,
                  child: Text(
                    '$distance km',
                    style: const TextStyle(
                      color: Color(0xFF0B1220),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 38.47,
                        height: 15,
                        child: Text(
                          'Pickup',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 88.16,
                        height: 19,
                        child: Text(
                          pickupAddress,
                          style: const TextStyle(
                            color: Color(0xFF0B1220),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 22.22,
                      height: 15,
                      child: Text(
                        'ETA',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 39.44,
                      height: 19,
                      child: Text(
                        '$eta min',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFF0B1220),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildRouteSection(List<Map<String, dynamic>> stopPoints) {
    if (stopPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(top: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < stopPoints.length; i++) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: ShapeDecoration(
                    color: _getStopPointColor(stopPoints[i]['stop_type']?.toString() ?? ''),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (i < stopPoints.length - 1)
                  Container(
                    width: 2,
                    height: 58,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      width: 2,
                      height: 54,
                      decoration: const BoxDecoration(color: Color(0xFFE5E7EB)),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < stopPoints.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: i < stopPoints.length - 1 ? 8 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        child: Icon(
                          _getStopPointIcon(stopPoints[i]['stop_type']?.toString() ?? ''),
                          size: 18,
                          color: const Color(0xFF0B1220),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              child: Text(
                                _getStopPointLabel(stopPoints[i]['stop_type']?.toString() ?? '', i),
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              child: Text(
                                stopPoints[i]['address']?.toString() ?? 'N/A',
                                style: const TextStyle(
                                  color: Color(0xFF0B1220),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
    );
  }

  Color _getStopPointColor(String stopType) {
    switch (stopType.toUpperCase()) {
      case 'PICKUP':
        return const Color(0xFF16A34A); // Green for pickup
      case 'DROPOFF':
        return const Color(0xFFDC2626); // Red for dropoff
      case 'WAYPOINT':
        return const Color(0xFFFF6B00); // Orange for waypoint
      default:
        return const Color(0xFFFF6B00);
    }
  }

  IconData _getStopPointIcon(String stopType) {
    switch (stopType.toUpperCase()) {
      case 'PICKUP':
        return Icons.arrow_upward;
      case 'DROPOFF':
        return Icons.arrow_downward;
      case 'WAYPOINT':
        return Icons.location_on;
      default:
        return Icons.location_on;
    }
  }

  String _getStopPointLabel(String stopType, int index) {
    switch (stopType.toUpperCase()) {
      case 'PICKUP':
        return 'From';
      case 'DROPOFF':
        return 'To';
      case 'WAYPOINT':
        return 'Stop ${index + 1}';
      default:
        return index == 0 ? 'From' : 'To';
    }
  }

  Widget _buildTags(String vehicleType, String paymentMode, int stopCount) {
    final vehicleTypeText = vehicleType == 'BIKE' ? 'Bike' : 
                           vehicleType == 'CAR' ? 'Car' : 
                           vehicleType == 'VAN' ? 'Van' : vehicleType;
    final paymentModeText = paymentMode == 'WALLET' ? 'Cashless' : 'Cash';
    final stopText = stopCount > 0 ? '$stopCount Stops' : 'Direct';

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: ShapeDecoration(
            color: const Color(0xFFFAFAFB),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: SizedBox(
            width: 26.44,
            height: 16,
            child: Text(
              vehicleTypeText,
              style: const TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7.60),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: ShapeDecoration(
            color: const Color(0xFFFAFAFB),
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 1,
                color: Color(0xFFE5E7EB),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: SizedBox(
            width: 56.66,
            height: 16,
            child: Text(
              paymentModeText,
              style: const TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (stopCount > 0) ...[
          const SizedBox(width: 7.60),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAFB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: SizedBox(
              width: 47.06,
              height: 16,
              child: Text(
                stopText,
                style: const TextStyle(
                  color: Color(0xFF0B1220),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFareSection(double estimatedFare, String estimatedDuration) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 55.86,
                      height: 15,
                      child: Text(
                        'Total Fare',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 72.58,
                      height: 21,
                      child: Text(
                        '₹ ${estimatedFare.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF0B1220),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 9.34),
                const SizedBox(
                  width: 92.19,
                  height: 15,
                  child: Text(
                    'Base + Distance',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
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
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: ShapeDecoration(
              color: const Color(0xFFFAFAFB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 1,
                  color: Color(0xFFE5E7EB),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: SizedBox(
              width: 73.23,
              height: 16,
              child: Text(
                'Est. $estimatedDuration mins',
                style: const TextStyle(
                  color: Color(0xFF0B1220),
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String bookingId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: _isLoading ? null : () => _handleRideAction(bookingId, false),
              child: Container(
                width: 150.50,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
                decoration: ShapeDecoration(
                  color: const Color(0xFF111827),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 44.53,
                            height: 19,
                            child: Text(
                              'Reject',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _isLoading ? null : () => _handleRideAction(bookingId, true),
              child: Container(
                width: 150.50,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFFF6B00),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 50.84,
                            height: 19,
                            child: Text(
                              'Accept',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRideAction(String bookingId, bool accepted) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (accepted) {
        // Disable accept button immediately
        setState(() {
          _isLoading = true;
        });
        
        // Accept the ride
        final trip = await widget.onRideAction(bookingId, accepted);
        
        if (mounted) {
          // Close the popup first
          Navigator.of(context).pop();
          
          // Navigate to active trip screen after accepting using global navigator key
          Future.delayed(const Duration(milliseconds: 500), () {
            if (navigatorKey.currentContext != null) {
              Navigator.of(navigatorKey.currentContext!).pushReplacementNamed(
                '/driver-trip',
                arguments: trip,
              );
            }
          });
        }
      } else {
        // Reject the ride - just close the popup
        await widget.onRideAction(bookingId, accepted);
        
        if (mounted) {
          Navigator.of(context).pop();
          // No snackbar for reject - just close the popup
        }
      }
    } catch (e) {
      print("❌ Error in _handleRideAction: $e");
      if (mounted) {
        // Close the popup first
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting booking: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

} 