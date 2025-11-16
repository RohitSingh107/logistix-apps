import 'package:flutter/material.dart';

/// Wrapper widget that adds the main navigation bottom menu to any screen
/// Excludes login/signup and onboarding screens
class MainNavigationWrapper extends StatelessWidget {
  final Widget child;
  final int? currentIndex; // Optional: specify which tab should be highlighted

  const MainNavigationWrapper({
    super.key,
    required this.child,
    this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultIndex = currentIndex ?? _getDefaultIndex(context);
    
    return Scaffold(
      body: child,
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
          currentIndex: defaultIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacementNamed('/home');
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed('/alerts');
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed('/wallet');
                break;
              case 3:
                Navigator.of(context).pushReplacementNamed('/trips');
                break;
              case 4:
                Navigator.of(context).pushReplacementNamed('/settings');
                break;
            }
          },
          selectedItemColor: const Color(0xFFFF6B00),
          unselectedItemColor: Colors.grey,
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

  int _getDefaultIndex(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    
    // Determine which tab should be highlighted based on current route
    if (route == '/home') return 0;
    if (route == '/alerts') return 1;
    if (route == '/wallet') return 2;
    if (route == '/trips' || route == '/driver-trip' || route == '/trip-details') return 3;
    if (route == '/settings') return 4;
    
    return 0; // Default to Home
  }
}

