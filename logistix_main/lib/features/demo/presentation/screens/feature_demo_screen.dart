/// feature_demo_screen.dart - Feature Demo and Navigation Hub
/// 
/// Purpose:
/// - Showcases all new features and screens created for the app
/// - Provides easy navigation to test all functionality
/// - Serves as a development and testing hub
/// 
/// Key Logic:
/// - Grid layout of feature cards with descriptions
/// - Navigation to all new screens and features
/// - Categorized sections for different feature types
/// - Visual indicators for feature status and complexity

import 'package:flutter/material.dart';
import '../../../../core/config/app_theme.dart';

class FeatureDemoScreen extends StatelessWidget {
  const FeatureDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Feature Demo'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚀 New Features',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Explore all the new screens and features we\'ve created',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Booking Features
            _buildSection(
              context,
              '📦 Booking Features',
              [
                _buildFeatureCard(
                  context,
                  icon: Icons.schedule,
                  title: 'Scheduled Booking',
                  description: 'Plan deliveries in advance',
                  route: '/scheduled-booking',
                  color: Colors.blue,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.repeat,
                  title: 'Recurring Booking',
                  description: 'Set up regular deliveries',
                  route: '/recurring-booking',
                  color: Colors.purple,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.inventory,
                  title: 'Package Details',
                  description: 'Manage package information',
                  route: '/package-details',
                  color: Colors.orange,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Payment Features
            _buildSection(
              context,
              '💳 Payment Features',
              [
                _buildFeatureCard(
                  context,
                  icon: Icons.payment,
                  title: 'Payment Methods',
                  description: 'Manage payment options',
                  route: '/payment-methods',
                  color: Colors.green,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.history,
                  title: 'Payment History',
                  description: 'View transaction history',
                  route: '/payment-history',
                  color: Colors.teal,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.receipt,
                  title: 'Invoice Generation',
                  description: 'Generate invoices',
                  route: '/invoice-generation',
                  color: Colors.indigo,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.refresh,
                  title: 'Refund Request',
                  description: 'Request refunds',
                  route: '/refund-request',
                  color: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Support Features
            _buildSection(
              context,
              '🆘 Support Features',
              [
                _buildFeatureCard(
                  context,
                  icon: Icons.support_agent,
                  title: 'Support Center',
                  description: 'Get help and support',
                  route: '/support-center',
                  color: Colors.cyan,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Tracking Features
            _buildSection(
              context,
              '📍 Tracking Features',
              [
                _buildFeatureCard(
                  context,
                  icon: Icons.location_on,
                  title: 'Live Tracking',
                  description: 'Real-time trip tracking',
                  route: '/live-tracking',
                  color: Colors.deepOrange,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Onboarding Features
            _buildSection(
              context,
              '🎯 Onboarding Features',
              [
                _buildFeatureCard(
                  context,
                  icon: Icons.waving_hand,
                  title: 'Welcome Screen',
                  description: 'App welcome experience',
                  route: '/welcome',
                  color: Colors.pink,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.tour,
                  title: 'App Tour',
                  description: 'Interactive app tour',
                  route: '/app-tour',
                  color: Colors.amber,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.featured_play_list,
                  title: 'Feature Intro',
                  description: 'Feature introduction',
                  route: '/feature-intro',
                  color: Colors.lime,
                ),
                _buildFeatureCard(
                  context,
                  icon: Icons.security,
                  title: 'Permissions',
                  description: 'Permission requests',
                  route: '/permissions',
                  color: Colors.brown,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: children,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 