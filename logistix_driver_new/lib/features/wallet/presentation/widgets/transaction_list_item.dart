import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/wallet_model.dart';

class TransactionListItem extends StatelessWidget {
  final WalletTransaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount > 0;
    final transactionColor = isCredit 
        ? const Color(0xFF16A34A) // Green for credit
        : const Color(0xFFDC2626); // Red for debit

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          // Transaction Icon
          Container(
            width: 40,
            height: 40,
            decoration: ShapeDecoration(
              color: transactionColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Icon(
              _getTransactionIcon(),
              color: transactionColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTransactionTitle(),
                  style: const TextStyle(
                    color: Color(0xFF0B1220),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (transaction.remarks != null && transaction.remarks!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    transaction.remarks!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.createdAt),
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
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
                style: TextStyle(
                  color: transactionColor,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 3,
                ),
                decoration: ShapeDecoration(
                  color: transactionColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  transaction.typeTx,
                  style: TextStyle(
                    color: transactionColor,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
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
