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
  late final LocationService _locationService;
  late final AuthService _authService;
  Map<String, dynamic>? _driverProfile;
  bool _isAvailable = false;
  bool _isUpdatingAvailability = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _driverRepository = serviceLocator<DriverRepository>();
    _locationService = serviceLocator<LocationService>();
    _authService = serviceLocator<AuthService>();
    _initializeHomeScreen();
  }

  Future<void> _initializeHomeScreen() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        await _fetchDriverProfile();
      } else {
        // Navigate back to login
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      // If we can't check authentication, try to fetch profile anyway
      await _fetchDriverProfile();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final profile = _driverProfile;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to alerts
              Navigator.of(context).pushNamed('/alerts');
            },
            tooltip: 'Alerts',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // TODO: Implement support/help action
            },
            tooltip: 'Support',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchDriverProfile();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile and Status Section
                if (profile != null) _buildProfileSection(theme, profile),
                const SizedBox(height: 24),
                
                // Earnings Section
                if (profile != null) _buildEarningsSection(theme, profile),
                const SizedBox(height: 24),
                
                // Performance Section
                _buildPerformanceSection(theme, profile),
                const SizedBox(height: 24),
                
                // Availability Toggle Section
                _buildAvailabilitySection(theme),
                const SizedBox(height: 24),
                
                // Quick Actions Section
                _buildQuickActionsSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: (profile['user'] as User).profilePicture != null
                  ? NetworkImage((profile['user'] as User).profilePicture!)
                  : null,
              child: (profile['user'] as User).profilePicture == null
                  ? Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(profile['user'] as User).firstName ?? ''} ${(profile['user'] as User).lastName ?? ''}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile['vehicle_number'] != null
                      ? 'Vehicle: ${profile['vehicle_number']}'
                      : 'No vehicle info',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile['average_rating'] ?? '-'} rating',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isAvailable ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isAvailable ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              _isAvailable ? 'Online' : 'Offline',
              style: theme.textTheme.labelSmall?.copyWith(
                color: _isAvailable ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(ThemeData theme, Map<String, dynamic> profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Earnings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${profile['today_earnings'] ?? profile['total_earnings'] ?? '0'}',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total earned today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: (profile['ledger_balance'] ?? 0) < 0 
                              ? theme.colorScheme.error 
                              : theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${profile['ledger_balance'] ?? '0'}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: (profile['ledger_balance'] ?? 0) < 0 
                                ? theme.colorScheme.error 
                                : theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wallet balance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if ((profile['ledger_balance'] ?? 0) < 0) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // Navigate to wallet
                          Navigator.of(context).pushNamed('/wallet');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          'Clear Dues',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(ThemeData theme, Map<String, dynamic>? profile) {
    final completion = profile?['completion_score'] ?? 16;
    final loginHours = profile?['login_hours'] ?? 5;
    final cancelRate = profile?['cancellation_rate'] ?? 3;
    final isPrime = profile?['is_prime'] ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Performance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrime 
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPrime ? Colors.green : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPrime ? Icons.thumb_up : Icons.thumb_down,
                      color: isPrime ? Colors.green : Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPrime ? 'Prime' : 'Not Prime',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPrime ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: completion / 100,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surface,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completion%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login Hours',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$loginHours hrs',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancel Rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$cancelRate%',
                      style: theme.textTheme.titleMedium?.copyWith(
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
    );
  }

  Widget _buildAvailabilitySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isAvailable 
                          ? 'Online - Ready for bookings' 
                          : 'Offline - Not accepting bookings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isAvailable 
                            ? Colors.green 
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Toggle Switch
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isAvailable,
                  onChanged: _isUpdatingAvailability 
                      ? null 
                      : (value) => _toggleAvailability(),
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ),
            ],
          ),
          
          // Loading indicator when updating
          if (_isUpdatingAvailability) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Updating...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Go Online/Offline Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(_isAvailable ? 'Done for the day?' : 'Ready to go online?'),
                    content: Text(_isAvailable
                        ? 'Are you sure you want to go offline?'
                        : 'Are you sure you want to go online and start accepting bookings?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(_isAvailable ? 'Go Offline' : 'Go Online'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _toggleAvailability();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAvailable 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _isAvailable ? 'GO OFFLINE' : 'GO ONLINE',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  'Wallet',
                  Icons.account_balance_wallet,
                  () {
                    Navigator.of(context).pushNamed('/wallet');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  'Trips',
                  Icons.local_shipping,
                  () {
                    Navigator.of(context).pushNamed('/trips');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  theme,
                  'Alerts',
                  Icons.notifications,
                  () {
                    Navigator.of(context).pushNamed('/alerts');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(ThemeData theme, String label, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 