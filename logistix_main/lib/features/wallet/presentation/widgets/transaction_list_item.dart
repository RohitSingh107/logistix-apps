import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/models/wallet_model.dart';

class TransactionListItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = transaction.amount > 0;
    final transactionColor = isCredit 
        ? Colors.green 
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: transactionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _getTransactionIcon(),
              color: transactionColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (transaction.remarks != null && transaction.remarks!.isNotEmpty)
                  Text(
                    transaction.remarks!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : ''}₹${NumberFormat('#,##,###.##').format(transaction.amount.abs())}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: transactionColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: transactionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  transaction.typeTx,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: transactionColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getTransactionIcon() {
    switch (transaction.typeTx.toUpperCase()) {
      case 'CREDIT':
        return Icons.add_circle;
      case 'DEBIT':
        return Icons.remove_circle;
      case 'REFUND':
        return Icons.refresh;
      case 'PAYMENT':
        return Icons.payment;
      default:
        return Icons.swap_horiz;
    }
  }
  
  String _getTransactionTitle() {
    switch (transaction.typeTx.toUpperCase()) {
      case 'CREDIT':
        return 'Money Added';
      case 'DEBIT':
        return 'Payment Made';
      case 'REFUND':
        return 'Refund Received';
      case 'PAYMENT':
        return 'Payment';
      default:
        return 'Transaction';
    }
  }
} 