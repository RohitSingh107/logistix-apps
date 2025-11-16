/// active_trips_screen.dart - Active Trip Screen (Version 2)
/// 
/// Purpose:
/// - Display active trip with new UI design
/// - Show trip details in bottom sheet
/// - Provide trip management actions
/// 
/// Key Features:
/// - Bottom sheet with trip information
/// - Action buttons (Navigate, Details, Payment, Call, Message, Cancel, Start Pickup)
/// - Trip status management and updates
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/models/trip_model.dart';
import '../../../../core/models/booking_model.dart';
import '../../../../core/models/stop_point_model.dart';
import '../../../../core/services/overlay_permission_service.dart';
import '../../../../core/services/trip_status_service.dart';
import '../../../../core/di/service_locator.dart';

class ActiveTripsScreen extends StatefulWidget {
  final Trip? trip;
  final Booking? booking;
  final bool isViewOnly; // If true, hide action buttons and contact buttons

  const ActiveTripsScreen({
    super.key,
    this.trip,
    this.booking,
    this.isViewOnly = false,
  });

  @override
  State<ActiveTripsScreen> createState() => _ActiveTripsScreenState();
}

class _ActiveTripsScreenState extends State<ActiveTripsScreen> {
  late final TripStatusService _tripStatusService;
  String? _selectedCancelReason;
  bool _isCanceled = false;
  String? _canceledReasonTitle;
  String? _canceledReasonSubtitle;
  bool _pickupStarted = false;
  int _pickupTimerSeconds = 0;
  int _loadingTimerSeconds = 135; // 02:15 in seconds
  bool _isWaiting = false;
  bool _isLoading = false;
  bool _isMarkArrivedLoading = false;
  bool _isStartWaitingLoading = false;
  bool _isCancelLoading = false;
  bool _isPauseLoading = false;
  DateTime? _loadingStartTime;

  @override
  void initState() {
    super.initState();
    _tripStatusService = serviceLocator<TripStatusService>();
    _requestOverlayPermissionIfNeeded();
    if (_pickupStarted) {
      _startPickupTimer();
    }
  }

  void _requestOverlayPermissionIfNeeded() async {
    final hasPermission = await OverlayPermissionService.isOverlayPermissionGranted();
    if (!hasPermission && mounted) {
      await OverlayPermissionService.requestOverlayPermission(context);
    }
  }

  void _startPickupTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _pickupStarted) {
        setState(() {
          _pickupTimerSeconds++;
        });
        _startPickupTimer();
      }
    });
  }

  void _startLoadingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isWaiting) {
        setState(() {
          _loadingTimerSeconds++;
        });
        _startLoadingTimer();
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Mark Arrived - Update trip status to IN_PROGRESS and send update message
  Future<void> _handleMarkArrived() async {
    final tripId = widget.trip?.id;
    if (tripId == null) {
      _showError('Trip ID not found');
      return;
    }

    if (_isMarkArrivedLoading || _isLoading) return;

    setState(() {
      _isMarkArrivedLoading = true;
      _isLoading = true;
      _pickupStarted = true;
      _startPickupTimer();
    });

    try {
      // Send update message
      await _tripStatusService.sendTripUpdateMessage(tripId, 'Reached pickup point');
      
      // Update status to IN_PROGRESS if not already
      final currentStatus = widget.trip?.status ?? TripStatus.accepted;
      if (currentStatus == TripStatus.accepted) {
        await _tripStatusService.updateTripStatus(tripId, TripStatus.inProgress);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Arrived at pickup point'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to mark arrived: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isMarkArrivedLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  /// Start Waiting - Send update message and start loading timer
  Future<void> _handleStartWaiting() async {
    final tripId = widget.trip?.id;
    if (tripId == null) {
      _showError('Trip ID not found');
      return;
    }

    if (_isStartWaitingLoading || _isLoading) return;

    setState(() {
      _isStartWaitingLoading = true;
      _isLoading = true;
      _isWaiting = true;
      _loadingStartTime = DateTime.now();
      _startLoadingTimer();
    });

    try {
      await _tripStatusService.sendTripUpdateMessage(tripId, 'Started waiting at pickup');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Waiting timer started'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to start waiting: ${e.toString()}');
        setState(() {
          _isWaiting = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartWaitingLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  /// Pause/Resume Waiting Timer
  Future<void> _handlePauseTimer() async {
    final tripId = widget.trip?.id;
    if (tripId == null) {
      _showError('Trip ID not found');
      return;
    }

    if (_isPauseLoading || _isLoading) return;

    setState(() {
      _isPauseLoading = true;
      _isLoading = true;
    });

    try {
      setState(() {
        _isWaiting = !_isWaiting;
        if (_isWaiting) {
          _startLoadingTimer();
        }
      });

      await _tripStatusService.sendTripUpdateMessage(
        tripId,
        _isWaiting ? 'Resumed waiting timer' : 'Paused waiting timer',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _isWaiting ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(_isWaiting ? 'Timer resumed' : 'Timer paused'),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to ${_isWaiting ? 'resume' : 'pause'} timer: ${e.toString()}');
        setState(() {
          _isWaiting = !_isWaiting; // Revert on error
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPauseLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  /// Cancel Trip - Update status to CANCELLED
  Future<void> _handleCancelTrip(String? reason) async {
    final tripId = widget.trip?.id;
    if (tripId == null) {
      _showError('Trip ID not found');
      return;
    }

    if (_isCancelLoading || _isLoading) return;

    setState(() {
      _isCancelLoading = true;
      _isLoading = true;
    });

    try {
      // Send cancel reason as update message
      if (reason != null) {
        await _tripStatusService.sendTripUpdateMessage(tripId, 'Trip cancelled: $reason');
      }
      
      // Update status to CANCELLED
      await _tripStatusService.updateTripStatus(tripId, TripStatus.cancelled);

      if (mounted) {
        setState(() {
          _isCanceled = true;
          final reasonMap = {
            'customer_not_available': ('Customer not available', 'Customer is not responding'),
            'wrong_address': ('Wrong address', 'Address provided was incorrect'),
            'vehicle_breakdown': ('Vehicle breakdown', 'Vehicle has broken down'),
            'other': ('Other', 'Trip cancelled by driver'),
          };
          final reasonData = reasonMap[reason ?? 'other'];
          if (reasonData != null) {
            _canceledReasonTitle = reasonData.$1;
            _canceledReasonSubtitle = reasonData.$2;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Trip cancelled successfully'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back after a delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to cancel trip: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCancelTripBottomSheet() {
    // Reset selection when opening the bottom sheet
    setState(() {
      _selectedCancelReason = null;
    });
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCancelTripBottomSheet(),
    );
  }

  Widget _buildCancelTripBottomSheet() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setSheetState) {
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
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    const SizedBox(height: 10),
                    // Header
                    Row(
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cancel Trip',
                            style: TextStyle(
                              color: const Color(0xFF0B1220),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Cancel reasons
                    _buildCancelReasonOption(
                      'Customer not available',
                      'Customer is not responding or not at location',
                      'customer_not_available',
                      setSheetState,
                    ),
                    const SizedBox(height: 12),
                    _buildCancelReasonOption(
                      'Wrong address',
                      'The pickup/dropoff address is incorrect',
                      'wrong_address',
                      setSheetState,
                    ),
                    const SizedBox(height: 12),
                    _buildCancelReasonOption(
                      'Vehicle breakdown',
                      'My vehicle has broken down',
                      'vehicle_breakdown',
                      setSheetState,
                    ),
                    const SizedBox(height: 12),
                    _buildCancelReasonOption(
                      'Other',
                      'Specify another reason',
                      'other',
                      setSheetState,
                    ),
                    const SizedBox(height: 24),
                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCancelReason != null && !_isCancelLoading && !_isLoading
                            ? () async {
                                Navigator.of(context).pop();
                                await _handleCancelTrip(_selectedCancelReason);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedCancelReason != null && !_isCancelLoading && !_isLoading
                              ? const Color(0xFF111827)
                              : const Color(0xFF111827).withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isCancelLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Cancel Trip',
                                style: TextStyle(
                                  color: _selectedCancelReason != null && !_isCancelLoading && !_isLoading
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCancelReasonOption(String title, String subtitle, String value, StateSetter setSheetState) {
    final isSelected = _selectedCancelReason == value;
    return InkWell(
      onTap: () {
        setSheetState(() {
          _selectedCancelReason = value;
        });
        setState(() {
          _selectedCancelReason = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFFFF6B00),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0B1220),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripId = widget.trip?.id ?? 4822;
    final bookingData = widget.booking ?? widget.trip?.bookingRequest;
    
    // Get trip details
    final distance = '2.1'; // Default distance
    final eta = '6'; // Default ETA
    
    // Get stop points
    final stopPoints = bookingData?.stopPoints ?? widget.trip?.stopPoints ?? [];
    
    // Get customer name
    final customerName = bookingData?.senderName ?? 'Ankit Sharma';
    final orderId = bookingData != null ? '#A${bookingData.id}' : '#A9831';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                    // Back button
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 1,
                              color: Color(0xFFE5E7EB),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: Color(0xFF0B1220),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                    Expanded(
                      child: Text(
                        widget.isViewOnly ? 'Trip Details' : 'Active Trip',
                        style: TextStyle(
                          color: const Color(0xFF0B1220),
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
                          child: Text(
                            'Online',
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
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
              ),
          // Content Area - Trip Details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 13,
                  left: 17,
                  right: 17,
                  bottom: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Trip ID and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Trip #LD-$tripId',
                                style: const TextStyle(
                                  color: Color(0xFF0B1220),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Progress indicators
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFF6B00),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 28,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: _pickupStarted ? const Color(0xFFFF6B00) : const Color(0xFFF3F4F6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    width: 28,
                                    height: 6,
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: ShapeDecoration(
                              color: _getStatusColor(),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: const TextStyle(
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
                      // Navigate Button
                      if (!widget.isViewOnly)
                        InkWell(
                          onTap: () {
                            if (stopPoints.isNotEmpty) {
                              final nextStop = stopPoints.first;
                              // Prefer address over coordinates for better route calculation
                              if (nextStop.address.isNotEmpty) {
                                _openGoogleMapsNavigationWithAddress(nextStop.address);
                              } else {
                                // Fallback to coordinates if address not available
                                final coords = nextStop.coordinates;
                                if (coords != null && 
                                    coords['latitude'] != null && 
                                    coords['longitude'] != null) {
                                  final lat = coords['latitude']!;
                                  final lng = coords['longitude']!;
                                  // Validate coordinates are within valid range
                                  if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                                    _openGoogleMapsNavigation(lat, lng);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invalid coordinates for navigation'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Location information not available'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: ShapeDecoration(
                              color: const Color(0xFF111827),
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                  width: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Navigate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (widget.isViewOnly)
                        const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      // Stop Points List
                      ...stopPoints.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stop = entry.value;
                        final isPickup = stop.stopType == StopType.pickup;
                        final isLast = index == stopPoints.length - 1;
                        final isFinal = isLast && !isPickup;
                        
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          margin: EdgeInsets.only(bottom: index < stopPoints.length - 1 ? 8 : 0),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: ShapeDecoration(
                                  color: isPickup ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Icon(
                                  isPickup ? Icons.arrow_upward : Icons.arrow_downward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.address.split(',').first,
                                      style: const TextStyle(
                                        color: Color(0xFF0B1220),
                                        fontSize: 15,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      stop.address,
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                          child: Text(
                                            index == 0 ? 'ETA $eta min' : 'Stop ${index + 1}',
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                          child: Text(
                                            isFinal ? 'Final' : (isPickup ? 'Pickup' : 'Drop-off'),
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 12,
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
                              if (!widget.isViewOnly)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Location button
                                    InkWell(
                                      onTap: () {
                                        final coords = stop.coordinates;
                                        if (coords != null && 
                                            coords['latitude'] != null && 
                                            coords['longitude'] != null) {
                                          final lat = coords['latitude']!;
                                          final lng = coords['longitude']!;
                                          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
                                            if (stop.address.isNotEmpty) {
                                              _openGoogleMapsNavigationWithAddress(stop.address);
                                            } else {
                                              _openGoogleMapsNavigation(lat, lng);
                                            }
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 22,
                                        height: 22,
                                        padding: const EdgeInsets.all(1),
                                        margin: const EdgeInsets.only(right: 8),
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
                                        child: const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: Color(0xFF0B1220),
                                        ),
                                      ),
                                    ),
                                    // Phone button
                                    if (stop.contactPhone != null)
                                      InkWell(
                                        onTap: () {
                                          _makePhoneCall(stop.contactPhone!);
                                        },
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          padding: const EdgeInsets.all(1),
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
                                          child: const Icon(
                                            Icons.phone_outlined,
                                            size: 16,
                                            color: Color(0xFF0B1220),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }),
                      // Route summary
                      if (stopPoints.length > 1)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${stopPoints.length} stops in this route',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: ShapeDecoration(
                                  color: const Color(0xFF111827),
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFE5E7EB),
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: const Text(
                                  'Optimize route',
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
                        ),
                      const SizedBox(height: 8),
                      // Pickup Timer and Distance
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
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pickup timer',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatTimer(_pickupTimerSeconds),
                                    style: const TextStyle(
                                      color: Color(0xFF0B1220),
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
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Distance',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$distance km',
                                    style: const TextStyle(
                                      color: Color(0xFF0B1220),
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
                      // Customer and Order
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
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Customer',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    customerName,
                                    style: const TextStyle(
                                      color: Color(0xFF0B1220),
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
                                    color: Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order',
                                    style: TextStyle(
                                      color: Color(0xFF6B7280),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    orderId,
                                    style: const TextStyle(
                                      color: Color(0xFF0B1220),
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
                      // Call and Message buttons
                      if (!widget.isViewOnly)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (bookingData != null && stopPoints.isNotEmpty) {
                                    final phone = stopPoints.first.contactPhone ?? bookingData.senderPhone;
                                    _makePhoneCall(phone);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF111827),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        ' Call',
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
                                  if (bookingData != null && stopPoints.isNotEmpty) {
                                    final phone = stopPoints.first.contactPhone ?? bookingData.senderPhone;
                                    _sendMessage(phone);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF111827),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.message,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        ' Message',
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
                      if (widget.isViewOnly)
                        const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      // Loading time at pickup
                      if (!widget.isViewOnly)
                        Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(9),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Loading time at pickup',
                                  style: TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  _formatTimer(_loadingTimerSeconds),
                                  style: const TextStyle(
                                    color: Color(0xFF0B1220),
                                    fontSize: 15,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF3F4F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: _loadingTimerSeconds / 300.0, // 5 minutes = 300 seconds
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF6B00),
                                    borderRadius: BorderRadius.all(Radius.circular(999)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Free 05:00 • Extra wait fee applies after',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                            child: InkWell(
                              onTap: (_isPauseLoading || _isLoading) ? null : _handlePauseTimer,
                                    child: Opacity(
                                      opacity: (_isPauseLoading || _isLoading) ? 0.6 : 1.0,
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
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
                                        child: _isPauseLoading
                                            ? Center(
                                                child: SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      const Color(0xFF0B1220),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _isWaiting ? Icons.pause : Icons.play_arrow,
                                                    size: 18,
                                                    color: const Color(0xFF0B1220),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _isWaiting ? 'Pause' : 'Resume',
                                                    style: const TextStyle(
                                                      color: Color(0xFF0B1220),
                                                      fontSize: 13,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ),
                      if (widget.isViewOnly)
                        const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      // Current Status Card - Show only the current status
                      _buildCurrentStatusCard(),
                      const SizedBox(height: 8),
                      // Action Buttons
                      if (!widget.isViewOnly)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: (_isStartWaitingLoading || _isLoading) ? null : _handleStartWaiting,
                              child: Opacity(
                                opacity: (_isStartWaitingLoading || _isLoading) ? 0.6 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF111827),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isStartWaitingLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.timer,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Start Waiting',
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
                          ),
                          // Only show Mark Arrived button if status is not already IN_PROGRESS
                          if ((widget.trip?.status ?? TripStatus.accepted) != TripStatus.inProgress) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: (_isMarkArrivedLoading || _isLoading) ? null : _handleMarkArrived,
                                child: Opacity(
                                  opacity: (_isMarkArrivedLoading || _isLoading) ? 0.6 : 1.0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFFF6B00),
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                          width: 1,
                                          color: Color(0xFFFF6B00),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: _isMarkArrivedLoading
                                        ? Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Mark Arrived',
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
                            ),
                          ],
                        ],
                      ),
                      if (widget.isViewOnly)
                        const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      // Cancel Trip button
                      if (!widget.isViewOnly)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: (_isCancelLoading || _isLoading) ? null : _showCancelTripBottomSheet,
                              child: Opacity(
                                opacity: (_isCancelLoading || _isLoading) ? 0.6 : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF111827),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 1,
                                        color: Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isCancelLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              ' Cancel Trip',
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    final tripStatus = widget.trip?.status ?? TripStatus.accepted;
    final bookingRequest = widget.trip?.bookingRequest;
    final stopPoints = bookingRequest?.stopPoints ?? <StopPoint>[];
    
    String title;
    String statusText;
    bool isCompleted;
    IconData icon;
    
    // Determine current status based on trip state
    if (tripStatus == TripStatus.completed) {
      title = 'Final delivery completed';
      statusText = 'Completed';
      isCompleted = true;
      icon = Icons.check;
    } else if (tripStatus == TripStatus.cancelled) {
      title = 'Trip cancelled';
      statusText = 'Cancelled';
      isCompleted = false;
      icon = Icons.close;
    } else if (tripStatus == TripStatus.inProgress) {
      // If in progress, check if we've reached pickup
      if (_pickupStarted) {
        // Check if we're at a dropoff stop
        if (stopPoints.length > 1) {
          // For multi-stop trips, show current stop
          final currentStopIndex = _getCurrentStopIndex();
          if (currentStopIndex > 0 && currentStopIndex < stopPoints.length) {
            title = 'Dropped at Stop $currentStopIndex';
            statusText = 'In Progress';
            isCompleted = false;
            icon = Icons.radio_button_unchecked;
          } else {
            title = 'Reached pickup point';
            statusText = 'Now';
            isCompleted = true;
            icon = Icons.check;
          }
        } else {
          title = 'Reached pickup point';
          statusText = 'Now';
          isCompleted = true;
          icon = Icons.check;
        }
      } else {
        title = 'Reached pickup point';
        statusText = 'Now';
        isCompleted = true;
        icon = Icons.check;
      }
    } else {
      // Trip is accepted - show "Started towards pickup"
      title = 'Started towards pickup';
      statusText = 'Now';
      isCompleted = true;
      icon = Icons.check;
    }
    
    return _buildStatusCard(title, statusText, isCompleted, icon);
  }
  
  int _getCurrentStopIndex() {
    // This is a placeholder - you may need to track which stop is current
    // For now, return 0 (first stop/pickup)
    return 0;
  }

  String _getStatusText() {
    final tripStatus = widget.trip?.status ?? TripStatus.accepted;
    
    switch (tripStatus) {
      case TripStatus.accepted:
        return 'Accepted';
      case TripStatus.inProgress:
        return 'On the way';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor() {
    final tripStatus = widget.trip?.status ?? TripStatus.accepted;
    
    switch (tripStatus) {
      case TripStatus.accepted:
        return const Color(0xFF3B82F6); // Blue
      case TripStatus.inProgress:
        return const Color(0xFF16A34A); // Green
      case TripStatus.completed:
        return const Color(0xFF16A34A); // Green
      case TripStatus.cancelled:
        return const Color(0xFFDC2626); // Red
    }
  }

  Widget _buildStatusCard(String title, String status, bool isCompleted, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
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
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: ShapeDecoration(
              color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFF3F4F6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
            child: Text(
              status,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openGoogleMapsNavigationWithAddress(String address) async {
    // Use address for navigation - this works better than coordinates
    // URL encode the address to handle special characters
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$encodedAddress&travelmode=driving'
    );
    
    try {
      // Try to open in Google Maps app first
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If app launch fails, try platform default (will open in browser if app not available)
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open navigation. Please install Google Maps.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _openGoogleMapsNavigation(double latitude, double longitude) async {
    // Use Google Maps directions URL with coordinates
    // This format works when address is not available
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving'
    );
    
    try {
      // Try to open in Google Maps app first
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      // If app launch fails, try platform default (will open in browser if app not available)
      try {
        await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      } catch (e2) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open navigation. Please install Google Maps.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    // Sanitize phone number - remove spaces and keep only digits and +
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (sanitizedPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid phone number'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      // Use tel: URI to open phone dialer with number pre-filled
      final url = Uri.parse('tel:$sanitizedPhone');
      
      // Try external application mode first (opens dialer app)
      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        // Fallback to platform default
        try {
          await launchUrl(url, mode: LaunchMode.platformDefault);
        } catch (e2) {
          // If both fail, show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open phone dialer'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening phone dialer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage(String phone) async {
    // Sanitize phone number - remove spaces and keep only digits and +
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (sanitizedPhone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid phone number'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    try {
      final url = Uri.parse('sms:$sanitizedPhone');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open messaging app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening messaging: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
