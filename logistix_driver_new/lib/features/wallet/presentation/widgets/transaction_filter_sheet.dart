/// transaction_filter_sheet.dart - Transaction Filter Bottom Sheet
/// 
/// Purpose:
/// - Provides filtering options for transaction history
/// - Allows filtering by transaction type and date range
/// - Shows filter controls in a bottom sheet matching app design
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionFilterSheet extends StatefulWidget {
  final String? selectedTransactionType;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;
  final Function(String?, DateTime?, DateTime?) onApplyFilter;

  const TransactionFilterSheet({
    super.key,
    this.selectedTransactionType,
    this.selectedStartDate,
    this.selectedEndDate,
    required this.onApplyFilter,
  });

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  String? _selectedTransactionType;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<String> _transactionTypes = ['CREDIT', 'DEBIT', 'REFUND', 'PAYMENT'];

  @override
  void initState() {
    super.initState();
    _selectedTransactionType = widget.selectedTransactionType;
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B00),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B1220),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        // If end date is before start date, clear it
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()),
      firstDate: _selectedStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B00),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0B1220),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedTransactionType = null;
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
  }

  void _applyFilter() {
    widget.onApplyFilter(_selectedTransactionType, _selectedStartDate, _selectedEndDate);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 13,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF3F4F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Header
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(0.00, 0.00),
                          end: Alignment(1.00, 1.00),
                          colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Filter Transactions',
                        style: TextStyle(
                          color: Color(0xFF0B1220),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Transaction Type Filter
                const Text(
                  'Transaction Type',
                  style: TextStyle(
                    color: Color(0xFF0B1220),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTypeChip(null, 'All'),
                    ..._transactionTypes.map((type) => _buildTypeChip(type, type)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Date Range Filter
                const Text(
                  'Date Range',
                  style: TextStyle(
                    color: Color(0xFF0B1220),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Start Date
                InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFFE6E6E6),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedStartDate != null
                                ? DateFormat('dd MMM, yyyy').format(_selectedStartDate!)
                                : 'Start Date',
                            style: TextStyle(
                              color: _selectedStartDate != null
                                  ? const Color(0xFF0B1220)
                                  : const Color(0xFF9CA3AF),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        if (_selectedStartDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStartDate = null;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // End Date
                InkWell(
                  onTap: _selectedStartDate != null ? _selectEndDate : null,
                  child: Opacity(
                    opacity: _selectedStartDate != null ? 1.0 : 0.5,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE6E6E6),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedEndDate != null
                                  ? DateFormat('dd MMM, yyyy').format(_selectedEndDate!)
                                  : 'End Date',
                              style: TextStyle(
                                color: _selectedEndDate != null
                                    ? const Color(0xFF0B1220)
                                    : const Color(0xFF9CA3AF),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          if (_selectedEndDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEndDate = null;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF111827),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String? type, String label) {
    final isSelected = _selectedTransactionType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTransactionType = isSelected ? null : type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFFE6E6E6),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Icon(
                Icons.check,
                size: 16,
                color: Color(0xFFFF6B00),
              ),
            if (isSelected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF0B1220),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

