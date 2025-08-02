import 'package:flutter/material.dart';
import '../../data/models/vehicle_estimate_response.dart';
import '../../../../core/config/app_theme.dart';

class VehicleEstimateCard extends StatefulWidget {
  final VehicleEstimateResponse estimate;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleEstimateCard({
    Key? key,
    required this.estimate,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VehicleEstimateCard> createState() => _VehicleEstimateCardState();
}

class _VehicleEstimateCardState extends State<VehicleEstimateCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.2),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Vehicle Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        widget.estimate.vehicleIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.md),
                  
                  // Vehicle Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.estimate.vehicleTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '₹${widget.estimate.estimatedFare.toStringAsFixed(0)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: AppSpacing.xs),
                        
                        Text(
                          widget.estimate.vehicleTypeDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        
                        const SizedBox(height: AppSpacing.xs),
                        
                        // Quick info row
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${widget.estimate.pickupReachTime} min',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              Icons.straighten,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${widget.estimate.estimatedDistance?.toStringAsFixed(1) ?? "0.0"} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${widget.estimate.vehicleDimensionWeight.toStringAsFixed(0)} kg',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Expand/Selection indicators
                  Column(
                    children: [
                      if (widget.isSelected)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xs),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Expandable section
            if (_isExpanded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 
                  0, 
                  AppSpacing.md, 
                  AppSpacing.md
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.02),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.md),
                    bottomRight: Radius.circular(AppRadius.md),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                    
                    // Dimensions Section
                    Text(
                      'Vehicle Specifications',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Dimensions Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.height,
                            label: 'Height',
                            value: '${widget.estimate.vehicleDimensionHeight.toStringAsFixed(1)} m',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.straighten,
                            label: 'Depth',
                            value: '${widget.estimate.vehicleDimensionDepth.toStringAsFixed(1)} m',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.fitness_center,
                            label: 'Capacity',
                            value: '${widget.estimate.vehicleDimensionWeight.toStringAsFixed(0)} kg',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.route,
                            label: 'Trip Distance',
                            value: '${widget.estimate.estimatedDistance?.toStringAsFixed(1) ?? "0.0"} km',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.route,
                            label: 'Base Distance',
                            value: '${widget.estimate.vehicleBaseDistance.toStringAsFixed(1)} km',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _buildSpecItem(
                            context,
                            icon: Icons.access_time,
                            label: 'Trip Duration',
                            value: '${widget.estimate.estimatedDuration ?? widget.estimate.pickupReachTime} min',
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Pricing info
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.payments,
                            size: 16,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Base Fare: ₹${widget.estimate.vehicleBaseFare.toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
} 