import 'package:flutter/material.dart';
import '../../../notifications/presentation/screens/alerts_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../trip/presentation/screens/my_trips_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../../core/models/trip_model.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0; // Start with Home tab
  bool _hasActiveTrip = false;
  Trip? _activeTrip;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AlertsScreen(),
    const WalletScreen(),
    const MyTripsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkForActiveTrip();
  }

  Future<void> _checkForActiveTrip() async {
    // TODO: Implement check for active trip
    // This would typically check if there's an ongoing trip
    // For now, we'll assume no active trip
    setState(() {
      _hasActiveTrip = false;
      _activeTrip = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/demo');
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        tooltip: 'Demo Navigation',
        child: const Icon(Icons.developer_mode),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            // Check if trying to navigate away from trip screen during active trip
            if (_hasActiveTrip && _currentIndex != 0 && index != 0) {
              _showActiveTripDialog();
              return;
            }
            
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined),
              activeIcon: Icon(Icons.notifications),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'Trips',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveTripDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Active Trip'),
        content: const Text(
          'You have an active trip in progress. Please complete or cancel the trip before navigating to other screens.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (_activeTrip != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  '/driver-trip',
                  arguments: _activeTrip,
                );
              },
              child: const Text('Go to Trip'),
            ),
        ],
      ),
    );
  }

} 