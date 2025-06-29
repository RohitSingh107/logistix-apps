/**
 * bottom_navbar.dart - Bottom Navigation Bar Widget
 * 
 * Purpose:
 * - Provides consistent bottom navigation across the application
 * - Handles tab switching and navigation state management
 * - Implements branded design with proper theming
 * 
 * Key Logic:
 * - Stateless widget that receives current index and callback function
 * - Uses BottomNavigationBar with fixed type for consistent appearance
 * - Applies custom styling with shadow effects and theme colors
 * - Three main navigation items: Home, Orders, Account
 * - Integrates with app theme for consistent color scheme
 * - Responsive to theme changes (light/dark mode support)
 * - Handles tap events through callback function
 * - Uses Material Design icons for intuitive navigation
 */

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onItemTapped,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.5),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
} 