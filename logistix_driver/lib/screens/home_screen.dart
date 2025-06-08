import 'package:flutter/material.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:logistix_driver/screens/alerts_screen.dart';
import 'package:logistix_driver/screens/wallet_screen.dart';
import 'package:logistix_driver/screens/my_trips_screen.dart';
import 'package:logistix_driver/screens/settings_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;
  Map<String, dynamic>? _driverProfile;
  bool _isAvailable = false;
  bool _isUpdatingAvailability = false;
  bool _isInitialized = false;

  final List<Widget> _screens = [
    const AlertsScreen(),
    const WalletScreen(),
    const MyTripsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

    Future<void> _fetchDriverProfile() async {
    try {
      final profile = await _authService.getDriverProfile();
      if (profile != null && mounted) {
      setState(() {
          _driverProfile = profile;
          _isAvailable = profile['is_available'] ?? false;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching driver profile: $e');
      if (mounted) {
    setState(() {
      _isInitialized = true;
    });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _toggleAvailability() async {
    if (_isUpdatingAvailability) return;

    setState(() {
      _isUpdatingAvailability = true;
    });

    try {
      final newAvailability = !_isAvailable;
      final result = await _authService.updateDriverAvailability(newAvailability);
      
      if (result != null && mounted) {
        setState(() {
          _driverProfile = result;
          _isAvailable = result['is_available'] ?? false;
        });
        
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logistix Driver'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _screens[_currentIndex],
          ),
          // Availability Toggle Section (shown on all tabs)
          if (_currentIndex == 0) _buildAvailabilityToggle(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }



  Widget _buildAvailabilityToggle() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isAvailable ? Colors.green.shade300 : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Driver Info Section
          if (_driverProfile != null) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: _driverProfile!['user']['profile_picture'] != null
                      ? NetworkImage(_driverProfile!['user']['profile_picture'])
                      : null,
                  child: _driverProfile!['user']['profile_picture'] == null
                      ? const Icon(Icons.person, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        '${_driverProfile!['user']['first_name']} ${_driverProfile!['user']['last_name']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Earnings: ₹${_driverProfile!['total_earnings']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${_driverProfile!['average_rating']} rating',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
          
          // Availability Toggle Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
              ),
            ),
                    const SizedBox(height: 4),
                    Text(
                      _isAvailable ? 'Online - Ready for bookings' : 'Offline - Not accepting bookings',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isAvailable ? Colors.green.shade700 : Colors.grey.shade600,
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
                  onChanged: _isUpdatingAvailability ? null : (value) => _toggleAvailability(),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade400,
                      ),
                    ),
            ],
              ),
          
          // Loading indicator when updating
          if (_isUpdatingAvailability) ...[
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Updating...'),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 