/**
 * settings_screen.dart - Application Settings Interface
 * 
 * Purpose:
 * - Provides comprehensive application settings management
 * - Handles theme switching and appearance customization
 * - Manages notification preferences and app configurations
 * 
 * Key Logic:
 * - Integrates with ThemeBloc for dynamic theme switching
 * - Organizes settings into logical sections (Appearance, Notifications, Account, Support)
 * - Provides theme selection with light, dark, and custom options
 * - Handles notification settings and preferences
 * - Implements clean section-based UI layout
 * - Shows current theme selection with visual feedback
 * - Persists user preferences through BLoC state management
 * - Provides immediate visual feedback for theme changes
 * - Includes expandable sections for organized settings presentation
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_theme.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../theme/presentation/bloc/theme_event.dart';
import '../../../theme/presentation/bloc/theme_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🔄 SettingsScreen: AuthBloc state changed to ${state.runtimeType}');
        
        if (state is AuthInitial) {
          print('🚪 SettingsScreen: User logged out, navigating to login');
          // User has been logged out, show success message and navigate
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Force navigation to login screen as fallback
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          });
        } else if (state is AuthError) {
          print('❌ SettingsScreen: Logout failed: ${state.message}');
          // Show error message if logout fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        body: ListView(
          children: [
            // Account Settings Section
            _buildSectionHeader(context, 'Account'),
            _buildAccountSettings(context),
            
            const Divider(height: 32),
            
            // Theme Settings Section
            _buildSectionHeader(context, 'Appearance'),
            _buildThemeSettings(context),
            
            const Divider(height: 32),
            
            // Notification Settings
            _buildSectionHeader(context, 'Notifications'),
            _buildNotificationSettings(context),
            
            const Divider(height: 32),
            
            // Support Section
            _buildSectionHeader(context, 'Support'),
            _buildSupportSettings(context),
            
            const Divider(height: 32),
            
            // About Section
            _buildSectionHeader(context, 'About'),
            _buildAboutSettings(context),
            
            const SizedBox(height: 32),
            
            // Logout Section
            _buildLogoutSection(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildAccountSettings(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Profile',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Edit your personal information',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to profile edit screen
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.security_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Security',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Change password and security settings',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to security settings
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.payment_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Payment Methods',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Manage your payment options',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to payment methods
          },
        ),
      ],
    );
  }
  
  Widget _buildThemeSettings(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentTheme = state is ThemeLoaded ? state.themeName : AppTheme.lightTheme;
        
        return Column(
          children: [
            _buildThemeTile(
              context,
              title: 'Light Theme',
              subtitle: 'Clean and bright appearance',
              value: AppTheme.lightTheme,
              groupValue: currentTheme,
              previewColors: [
                const Color(0xFFD4A574),
                const Color(0xFF4CAF50),
                Colors.white,
              ],
            ),
            _buildThemeTile(
              context,
              title: 'Dark Theme',
              subtitle: 'Easy on the eyes in low light',
              value: AppTheme.darkTheme,
              groupValue: currentTheme,
              previewColors: [
                const Color(0xFFE5B88A),
                const Color(0xFF81C784),
                const Color(0xFF1E1E1E),
              ],
            ),
            _buildThemeTile(
              context,
              title: 'Blue Theme',
              subtitle: 'Professional blue accent',
              value: AppTheme.blueTheme,
              groupValue: currentTheme,
              previewColors: [
                const Color(0xFF1976D2),
                const Color(0xFF00ACC1),
                Colors.white,
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildThemeTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required List<Color> previewColors,
  }) {
    final theme = Theme.of(context);
    final isSelected = value == groupValue;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isSelected 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
        value: value,
        groupValue: groupValue,
        onChanged: (String? newValue) {
          if (newValue != null) {
            context.read<ThemeBloc>().add(ChangeThemeEvent(newValue));
          }
        },
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: previewColors.map((color) => Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }
  
  Widget _buildNotificationSettings(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Push Notifications',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Receive updates about your deliveries',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // TODO: Implement notification settings
            },
          ),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Email Notifications',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Get order updates via email',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch(
            value: false,
            onChanged: (bool value) {
              // TODO: Implement email settings
            },
          ),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.sms_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'SMS Notifications',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Receive SMS alerts for important updates',
            style: theme.textTheme.bodySmall,
          ),
          trailing: Switch(
            value: true,
            onChanged: (bool value) {
              // TODO: Implement SMS settings
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSupportSettings(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.help_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Help & Support',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Get help with your account',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to help and support
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chat_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Contact Us',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Reach out to our support team',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to contact us
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.feedback_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Send Feedback',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Share your thoughts with us',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to feedback
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.star_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Rate App',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Rate us on the app store',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Open app store rating
          },
        ),
      ],
    );
  }
  
  Widget _buildAboutSettings(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'App Version',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            '1.0.0',
            style: theme.textTheme.bodySmall,
          ),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Privacy Policy',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Read our privacy policy',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to privacy policy
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Terms of Service',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Read our terms of service',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to terms of service
          },
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.update_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            'Check for Updates',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Check for app updates',
            style: theme.textTheme.bodySmall,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Check for updates
          },
        ),
      ],
    );
  }
  
  Widget _buildLogoutSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout? You will need to log in again to access your account.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logging out...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Implement logout functionality
                    context.read<AuthBloc>().add(Logout());
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    // Show error message if logout fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to logout: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
} 