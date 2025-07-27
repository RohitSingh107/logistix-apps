/**
 * profile_screen.dart - User Profile Management Interface
 * 
 * Purpose:
 * - Provides comprehensive user profile management interface
 * - Displays user information, preferences, and account settings
 * - Manages profile updates and account-related operations
 * 
 * Key Logic:
 * - Uses UserBloc instance provided at app level
 * - Displays user profile information
 * - Provides profile editing capabilities
 * - Manages account settings and preferences
 * - Handles profile picture upload and management
 * - Implements logout functionality
 * - Provides navigation to related screens
 * - Manages loading states and error handling
 * - Uses responsive design with proper theme integration
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/repositories/user_repository.dart';
import '../../../../core/models/user_model.dart';
import '../bloc/user_bloc.dart';
import 'create_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load user profile when screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserBloc>().add(LoadUserProfile());
    });
    
    return const _ProfileScreenContent();
  }
}

class _ProfileScreenContent extends StatelessWidget {
  const _ProfileScreenContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        actions: [
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // TODO: Navigate to edit profile screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit profile coming soon'),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load profile',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<UserBloc>().add(LoadUserProfile()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is UserLoaded) {
              final user = state.user;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            child: user.profilePicture != null
                                ? ClipOval(
                                    child: Image.network(
                                      user.profilePicture!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person,
                                          size: 50,
                                          color: theme.colorScheme.primary,
                                        );
                                      },
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 50,
                                    color: theme.colorScheme.primary,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Account Settings Section
                    Text(
                      'Account Settings',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSettingsCard(
                      theme,
                      'My Wallet',
                      Icons.account_balance_wallet_outlined,
                      () {
                        Navigator.of(context).pushNamed('/wallet');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingsCard(
                      theme,
                      'My Trips',
                      Icons.local_shipping_outlined,
                      () {
                        Navigator.of(context).pushNamed('/trips');
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingsCard(
                      theme,
                      'Notifications',
                      Icons.notifications_outlined,
                      () {
                        Navigator.of(context).pushNamed('/alerts');
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Support Section
                    Text(
                      'Support',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildSettingsCard(
                      theme,
                      'Help & Support',
                      Icons.help_outline,
                      () {
                        // TODO: Implement help and support
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help & Support coming soon'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    _buildSettingsCard(
                      theme,
                      'About',
                      Icons.info_outline,
                      () {
                        // TODO: Implement about screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('About screen coming soon'),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout Section
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement logout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Logout functionality coming soon'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.all(16),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 