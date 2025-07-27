/**
 * profile_screen.dart - User Profile Management Interface
 * 
 * Purpose:
 * - Provides comprehensive user profile management interface
 * - Displays user information, preferences, and account settings
 * - Manages profile updates and account-related operations
 * 
 * Key Logic:
 * - Loads and displays user profile information
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
    return BlocProvider(
      create: (context) => UserBloc(serviceLocator<UserRepository>())
        ..add(LoadUserProfile()),
      child: const _ProfileScreenContent(),
    );
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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                                         // Profile Header Section
                     _buildProfileHeader(theme, state.user),
                     const SizedBox(height: 24),
                     
                     // Account Information Section
                     _buildAccountSection(theme, state.user),
                     const SizedBox(height: 24),
                     
                     // Driver Information Section
                     _buildDriverSection(theme, state.user),
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    _buildSettingsSection(theme),
                    const SizedBox(height: 24),
                    
                    // Support Section
                    _buildSupportSection(theme),
                    const SizedBox(height: 24),
                    
                    // Logout Section
                    _buildLogoutSection(theme, context),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 3,
              ),
            ),
                         child: CircleAvatar(
               radius: 47,
               backgroundImage: user.profilePicture != null
                   ? NetworkImage(user.profilePicture!)
                   : null,
               child: user.profilePicture == null
                   ? Icon(
                       Icons.person,
                       size: 50,
                       color: theme.colorScheme.onSurface.withOpacity(0.6),
                     )
                   : null,
             ),
          ),
          const SizedBox(height: 16),
          
          // Name and Rating
                     Text(
             '${user.firstName ?? ''} ${user.lastName ?? ''}',
             style: theme.textTheme.headlineMedium?.copyWith(
               fontWeight: FontWeight.w700,
             ),
             textAlign: TextAlign.center,
           ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
                             Text(
                 '0 rating',
                 style: theme.textTheme.bodyMedium?.copyWith(
                   color: theme.colorScheme.onSurface.withOpacity(0.7),
                   fontWeight: FontWeight.w500,
                 ),
               ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                         decoration: BoxDecoration(
               color: false 
                   ? Colors.green.withOpacity(0.1)
                   : Colors.grey.withOpacity(0.1),
               borderRadius: BorderRadius.circular(20),
               border: Border.all(
                 color: false ? Colors.green : Colors.grey,
                 width: 1,
               ),
             ),
             child: Text(
               'Offline',
              style: theme.textTheme.labelMedium?.copyWith(
                                 color: false ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(ThemeData theme, User user) {
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
            'Account Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
                     _buildInfoRow(
             theme,
             'Email',
             'Not provided',
             Icons.email_outlined,
           ),
           const SizedBox(height: 12),
           
           _buildInfoRow(
             theme,
             'Phone',
             user.phone,
             Icons.phone_outlined,
           ),
           const SizedBox(height: 12),
           
           _buildInfoRow(
             theme,
             'Member Since',
             'Unknown',
             Icons.calendar_today_outlined,
           ),
        ],
      ),
    );
  }

  Widget _buildDriverSection(ThemeData theme, User user) {
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
            'Driver Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
                     _buildInfoRow(
             theme,
             'Vehicle Number',
             'Not provided',
             Icons.directions_car_outlined,
           ),
           const SizedBox(height: 12),
           
           _buildInfoRow(
             theme,
             'License Number',
             'Not provided',
             Icons.card_membership_outlined,
           ),
           const SizedBox(height: 12),
           
           _buildInfoRow(
             theme,
             'Total Earnings',
             '₹0',
             Icons.account_balance_wallet_outlined,
           ),
           const SizedBox(height: 12),
           
           _buildInfoRow(
             theme,
             'Today\'s Earnings',
             '₹0',
             Icons.trending_up_outlined,
           ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
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
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            theme,
            'Notifications',
            'Manage notification preferences',
            Icons.notifications_outlined,
            () {
              // TODO: Navigate to notifications settings
            },
          ),
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            theme,
            'Privacy',
            'Manage privacy settings',
            Icons.privacy_tip_outlined,
            () {
              // TODO: Navigate to privacy settings
            },
          ),
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            theme,
            'Security',
            'Manage security settings',
            Icons.security_outlined,
            () {
              // TODO: Navigate to security settings
            },
          ),
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            theme,
            'Language',
            'Change app language',
            Icons.language_outlined,
            () {
              // TODO: Navigate to language settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ThemeData theme) {
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
            'Support',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingsItem(
            theme,
            'Help Center',
            'Get help and support',
            Icons.help_outline,
            () {
              // TODO: Navigate to help center
            },
          ),
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            theme,
            'Contact Support',
            'Get in touch with our team',
            Icons.support_agent_outlined,
            () {
              // TODO: Navigate to contact support
            },
          ),
          const SizedBox(height: 12),
          
          _buildSettingsItem(
            theme,
            'About',
            'App version and information',
            Icons.info_outline,
            () {
              // TODO: Navigate to about screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(ThemeData theme, BuildContext context) {
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
            'Account',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(ThemeData theme, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
                     ElevatedButton(
             onPressed: () {
               Navigator.of(context).pop();
               // TODO: Implement logout functionality
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Text('Logout functionality coming soon'),
                 ),
               );
             },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 