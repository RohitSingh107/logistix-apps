import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Brand Colors Demo Widget
/// 
/// This widget demonstrates all the brand colors from the color palette
/// and can be used as a reference for developers
class BrandColorsDemo extends StatelessWidget {
  const BrandColorsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Brand Colors'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Colours',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Orange Section
            _buildColorSection(
              context,
              'Orange',
              [
                AppColors.secondaryOrange,
                AppColors.lightOrange,
              ],
            ),
            
            const Divider(color: AppColors.border, height: 32),
            
            // Black - Grey - White Section
            _buildColorSection(
              context,
              'Black - Grey - White',
              [
                AppColors.pureBlack,
                AppColors.neutralGrey,
                AppColors.pureWhite,
              ],
            ),
            
            const Divider(color: AppColors.border, height: 32),
            
            // Green Section
            _buildColorSection(
              context,
              'Colour',
              [
                AppColors.darkGreen,
                AppColors.lightGreen,
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Additional Brand Colors
            Text(
              'Additional Brand Colors',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Primary Orange
            _buildColorRow(context, 'Primary Orange', AppColors.primaryOrange),
            const SizedBox(height: 8),
            
            // Success
            _buildColorRow(context, 'Success', AppColors.success),
            const SizedBox(height: 8),
            
            // Error
            _buildColorRow(context, 'Error', AppColors.error),
            const SizedBox(height: 8),
            
            // Warning
            _buildColorRow(context, 'Warning', AppColors.warning),
            const SizedBox(height: 8),
            
            // Info
            _buildColorRow(context, 'Info', AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(
    BuildContext context,
    String title,
    List<Color> colors,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Row(
            children: colors.map((color) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: color == AppColors.pureWhite
                        ? Border.all(color: AppColors.border, width: 1)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
} 