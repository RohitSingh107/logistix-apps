import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_theme.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../theme/presentation/bloc/theme_event.dart';
import '../../../theme/presentation/bloc/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Settings Section
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeSettings(context),
          
          const Divider(height: 32),
          
          // Other Settings
          _buildSectionHeader(context, 'Notifications'),
          _buildNotificationSettings(context),
          
          const Divider(height: 32),
          
          _buildSectionHeader(context, 'About'),
          _buildAboutSettings(context),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isSelected 
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withOpacity(0.2),
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
        SwitchListTile(
          title: Text(
            'Push Notifications',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Receive updates about your deliveries',
            style: theme.textTheme.bodySmall,
          ),
          value: true,
          onChanged: (bool value) {
            // TODO: Implement notification settings
          },
        ),
        SwitchListTile(
          title: Text(
            'Email Notifications',
            style: theme.textTheme.titleMedium,
          ),
          subtitle: Text(
            'Get order updates via email',
            style: theme.textTheme.bodySmall,
          ),
          value: false,
          onChanged: (bool value) {
            // TODO: Implement email settings
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
          leading: Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
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
          leading: Icon(
            Icons.privacy_tip_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'Privacy Policy',
            style: theme.textTheme.titleMedium,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to privacy policy
          },
        ),
        ListTile(
          leading: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.primary,
          ),
          title: Text(
            'Terms of Service',
            style: theme.textTheme.titleMedium,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Navigate to terms of service
          },
        ),
      ],
    );
  }
} 