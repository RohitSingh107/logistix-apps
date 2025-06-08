import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/app_theme.dart';
import '../bloc/wallet_bloc.dart';

class AddBalanceModal extends StatefulWidget {
  const AddBalanceModal({super.key});

  @override
  State<AddBalanceModal> createState() => _AddBalanceModalState();
}

class _AddBalanceModalState extends State<AddBalanceModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  final List<int> _quickAmounts = [100, 200, 500, 1000, 2000, 5000];
  int? _selectedQuickAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is AddBalanceSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.lg + keyboardHeight,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Add Balance',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Amount Input
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Amount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      hintText: '0',
                      prefixText: '₹ ',
                      prefixStyle: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount < 10) {
                        return 'Minimum amount is ₹10';
                      }
                      if (amount > 100000) {
                        return 'Maximum amount is ₹1,00,000';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedQuickAmount = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Quick Amount Selection
            Text(
              'Quick Select',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _quickAmounts.map((amount) {
                final isSelected = _selectedQuickAmount == amount;
                return GestureDetector(
                  onTap: () => _selectQuickAmount(amount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      '₹$amount',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Payment Method Info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'You will be redirected to payment gateway to complete the transaction',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Action Buttons
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                final isLoading = state is AddBalanceLoading;
                
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleAddBalance,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Add Balance',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _selectQuickAmount(int amount) {
    setState(() {
      _selectedQuickAmount = amount;
      _amountController.text = amount.toString();
    });
  }
  
  void _handleAddBalance() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.tryParse(_amountController.text);
      if (amount != null) {
        context.read<WalletBloc>().add(AddBalance(amount));
      }
    }
  }
} 