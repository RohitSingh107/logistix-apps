/// home_screen.dart - Driver Application Dashboard
/// 
/// Purpose:
/// - Provides the main dashboard screen for drivers
/// - Shows driver profile, earnings, performance, and availability
/// - Provides quick navigation to other screens
/// 
/// Key Logic:
/// - Displays driver availability toggle and profile information
/// - Shows driver earnings, rating, and status
/// - Provides quick actions to navigate to other screens
/// - Implements availability management for accepting/declining bookings
/// - Loads and displays driver profile information
/// - Handles first-time user driver profile creation
/// - Manages 500 errors by opening create driver profile screen
library;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/user_model.dart';
import '../../../../features/driver/domain/repositories/driver_repository.dart';
import '../../../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DriverRepository _driverRepository;
  late final WalletRepository _walletRepository;
  late final LocationService _locationService;
  late final AuthService _authService;
  Map<String, dynamic>? _driverProfile;
  double _walletBalance = 0.0;
  bool _isAvailable = false;
  bool _isUpdatingAvailability = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _driverRepository = serviceLocator<DriverRepository>();
    _walletRepository = serviceLocator<WalletRepository>();
    _locationService = serviceLocator<LocationService>();
    _authService = serviceLocator<AuthService>();
    _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        await Future.wait([
          _fetchDriverProfile(),
          _fetchWalletBalance(),
        ]);
      } else {
        // Navigate back to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      // If we can't check authentication, try to fetch profile anyway
      await Future.wait([
        _fetchDriverProfile(),
        _fetchWalletBalance(),
      ]);
    }
  }

  Future<void> _fetchDriverProfile() async {
    try {
      // Add timeout to prevent hanging
      final driver = await _driverRepository.getDriverProfile().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Timeout fetching driver profile');
          throw Exception('Timeout fetching driver profile');
        },
      );
      
      final profile = driver.toJson();
      
      if (mounted) {
        setState(() {
          _driverProfile = profile;
          _isAvailable = profile['is_available'] ?? false;
          _isInitialized = true;
        });
        
        // Start location tracking if driver is already available
        if (_isAvailable) {
          await _locationService.startLocationTracking();
        }
        
        // Update driver FCM token when profile is fetched successfully
        _updateDriverFcmToken();
      } else {
        // Profile is null - automatically navigate to create driver profile
        debugPrint('No driver profile found - navigating to create profile screen');
        if (mounted) {
          _navigateToCreateDriverProfile();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
      
      // Check if it's a DioException to handle different error types
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        
        // Handle 500 errors or profile not found - open create driver page
        if (statusCode == 500 || statusCode == 404) {
          if (mounted) {
            _navigateToCreateDriverProfile();
            return;
          }
        }
      }
      
      // For other errors, also navigate to create driver profile
      debugPrint('Unknown error - navigating to create driver profile');
      if (mounted) {
        _navigateToCreateDriverProfile();
        return;
      }
    }
  }

  /// Fetch wallet balance from API
  Future<void> _fetchWalletBalance() async {
    try {
      final balance = await _walletRepository.getWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalance = balance;
        });
      }
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
      // Set balance to 0.0 on error
      if (mounted) {
        setState(() {
          _walletBalance = 0.0;
        });
      }
    }
  }

  /// Update driver FCM token when profile is fetched
  Future<void> _updateDriverFcmToken() async {
    try {
      await PushNotificationService.updateDriverFcmToken();
    } catch (e) {
      debugPrint('Warning: Failed to update driver FCM token on home screen load: $e');
    }
  }

  void _navigateToCreateDriverProfile() {
    Navigator.of(context).pushReplacementNamed('/driver/create');
  }

  @override
  void dispose() {
    // Stop location tracking when screen is disposed
    _locationService.stopLocationTracking();
    super.dispose();
  }

  Future<void> _toggleAvailability() async {
    if (_isUpdatingAvailability) return;

    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      final newAvailability = !_isAvailable;
      final updatedDriver = await _driverRepository.updateDriverProfile(
        isAvailable: newAvailability,
      );
      
      if (mounted) {
        setState(() {
          _driverProfile = updatedDriver.toJson();
          _isAvailable = updatedDriver.isAvailable;
        });
        
        // Handle location tracking based on availability
        if (_isAvailable) {
          // Start location tracking when driver becomes available
          await _locationService.startLocationTracking();
          debugPrint('📍 Started location tracking for available driver');
        } else {
          // Stop location tracking when driver becomes unavailable
          _locationService.stopLocationTracking();
          debugPrint('📍 Stopped location tracking for unavailable driver');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAvailable 
                ? 'You are now available for bookings' 
                : 'You are now offline'),
            backgroundColor: _isAvailable ? Colors.green : Colors.orange,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update availability. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingAvailability = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: const Color(0xFFFF6B00),
          ),
        ),
      );
    }

    final profile = _driverProfile;
    final userName = profile != null && profile['user'] != null
        ? '${(profile['user'] as User).firstName ?? 'Driver'}'
        : 'Driver';
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _fetchDriverProfile(),
              _fetchWalletBalance(),
            ]);
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        // Fallback to gradient if image not found
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
                                      'Logistix Driver',
                                      style: TextStyle(
                                        color: const Color(0xFF111111),
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                                  ),
                                  const Spacer(),
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
                                          color: _isAvailable ? const Color(0xFF16A34A) : const Color(0xFFF3F4F6),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: _isAvailable ? const Color(0xFF16A34A) : const Color(0xFFE6E6E6),
                                            ),
                                            borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
                                          _isAvailable ? 'Online' : 'Go Online',
                                          style: TextStyle(
                                            color: _isAvailable ? Colors.white : const Color(0xFF9CA3AF),
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
                            // Main Content
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 12,
                                top: 24,
      ),
      child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                                  // Profile Card
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(13),
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                        Text(
                                                    'Hi, $userName',
                                                    style: TextStyle(
                                                      color: const Color(0xFF111111),
                                                      fontSize: 16,
                                                      fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                                              Container(
                                                width: 28,
                                                height: 28,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: ShapeDecoration(
                                                  image: profile != null &&
                                                          profile['user'] != null &&
                                                          (profile['user'] as User).profilePicture != null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            (profile['user'] as User).profilePicture!,
                                                          ),
                                                          fit: BoxFit.fill,
                                                        )
                                                      : null,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  color: profile == null ||
                                                          profile['user'] == null ||
                                                          (profile['user'] as User).profilePicture == null
                                                      ? const Color(0xFFE6E6E6)
                                                      : null,
                        ),
                                                child: profile == null ||
                                                        profile['user'] == null ||
                                                        (profile['user'] as User).profilePicture == null
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 18,
                                                        color: Color(0xFF9CA3AF),
                                                      )
                                                    : null,
                      ),
                  ],
                ),
              ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: ShapeDecoration(
                                                  color: const Color(0xFF16A34A),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              SizedBox(
                                                width: 54.92,
                                                child: Text(
                                                  'Available',
                                                  style: TextStyle(
                                                    color: const Color(0xFF9CA3AF),
                                                    fontSize: 13,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                ),
              ),
                                              const SizedBox(width: 6),
                                              GestureDetector(
                                                onTap: _isUpdatingAvailability ? null : _toggleAvailability,
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  width: 44,
                                                  height: 24,
                                                  decoration: ShapeDecoration(
                                                    color: _isAvailable ? const Color(0xFFFF6B00).withOpacity(0.2) : const Color(0xFFFAFAFA),
                                                    shape: RoundedRectangleBorder(
                                                      side: BorderSide(
                    width: 1,
                                                        color: _isAvailable ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
                  ),
                                                      borderRadius: BorderRadius.circular(999),
                ),
                                                  ),
                                                  child: Stack(
                  children: [
                                                      AnimatedPositioned(
                                                        duration: const Duration(milliseconds: 300),
                                                        curve: Curves.easeInOutCubic,
                                                        left: _isAvailable ? 23 : 3,
                                                        top: 3,
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 300),
                                                          curve: Curves.easeInOutCubic,
                                                          width: 18,
                                                          height: 18,
                                                          decoration: ShapeDecoration(
                                                            color: const Color(0xFFFF6B00),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(999),
                                                            ),
                                                          ),
                      ),
                    ),
                  ],
                                                  ),
                ),
              ),
            ],
          ),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF333333),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                                                        'Today',
                                                        style: TextStyle(
                                                          color: const Color(0xFF9CA3AF),
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                                                        ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                                                        '₹${profile?['today_earnings'] ?? profile?['total_earnings'] ?? '0'}',
                                                        style: TextStyle(
                                                          color: Colors.white,
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
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF333333),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                                                        'This Week',
                                                        style: TextStyle(
                                                          color: const Color(0xFF9CA3AF),
                                                          fontSize: 13,
                                                          fontFamily: 'Inter',
                                                          fontWeight: FontWeight.w400,
                      ),
                    ),
                                                      const SizedBox(height: 4),
                    Text(
                                                        '₹${profile?['week_earnings'] ?? profile?['total_earnings'] ?? '0'}',
                                                        style: TextStyle(
                                                          color: Colors.white,
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
              ),
            ],
          ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Available Balance Card
                                  Container(
                                    width: double.infinity,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                                                    'Available Balance',
                                                    style: TextStyle(
                                                      color: const Color(0xFF9CA3AF),
                                                      fontSize: 13,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                                                    '₹ ${_walletBalance.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: const Color(0xFF111111),
                                                      fontSize: 28,
                                                      fontFamily: 'Inter',
                                                      fontWeight: FontWeight.w600,
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
                                                  'Settles Daily',
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
                                        const SizedBox(height: 12),
                                        Container(
                                          width: double.infinity,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed('/wallet');
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(11),
                                                    decoration: ShapeDecoration(
                                                      color: const Color(0xFFFF6B00),
                                                      shape: RoundedRectangleBorder(
                                                        side: const BorderSide(
                                                          width: 1,
                                                          color: Color(0xFFE6E6E6),
                                                        ),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Add Balance',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed('/wallet');
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(11),
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
              child: Text(
                                                      'Withdraw',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                  color: Colors.white,
                                                        fontSize: 15,
                                                        fontFamily: 'Inter',
                                                        fontWeight: FontWeight.w500,
                                                      ),
                ),
              ),
            ),
          ),
        ],
      ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Go Online Button
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                                        GestureDetector(
                                          onTap: _isUpdatingAvailability ? null : _toggleAvailability,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 13,
                                              vertical: 17,
                                            ),
                                            decoration: ShapeDecoration(
                                              color: _isAvailable ? const Color(0xFF333333) : const Color(0xFFFF6B00),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 1,
                                                  color: _isAvailable ? const Color(0xFF333333) : const Color(0xFFFF6B00),
                                                ),
                                                borderRadius: BorderRadius.circular(12),
            ),
          ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                                                AnimatedContainer(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  width: 18,
                                                  height: 18,
                                                  child: const Icon(
                                                    Icons.power_settings_new,
                                                    size: 18,
                                                    color: Colors.white,
                ),
              ),
                                                const SizedBox(width: 8),
                                                SizedBox(
                                                  width: 69.94,
                                                  height: 19,
                                                  child: Text(
                                                    _isAvailable ? 'Go Offline' : 'Go Online',
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
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  'Tap to toggle your status between Online and Offline.',
                                                  textAlign: TextAlign.center,
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
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (label == 'Trips') {
          Navigator.of(context).pushNamed('/trips');
        } else if (label == 'Earnings') {
          Navigator.of(context).pushNamed('/wallet');
        } else if (label == 'Alerts') {
          Navigator.of(context).pushNamed('/alerts');
        } else if (label == 'Profile') {
          Navigator.of(context).pushNamed('/settings');
        }
      },
      child: Container(
        width: 68.59,
        padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected ? const Color(0xFF111111) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: label == 'Earnings' ? 49.44 : (label == 'Trips' ? 28.30 : (label == 'Alerts' ? 33.03 : (label == 'Profile' ? 36.44 : 33.63))),
                  height: 15,
                  child: Text(
                  label,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF111111) : const Color(0xFF9CA3AF),
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
    );
  }

} 