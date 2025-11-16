/// transaction_history_screen.dart - Transaction History Screen with Filters
/// 
/// Purpose:
/// - Displays comprehensive transaction history with filtering capabilities
/// - Provides filter options for transaction type and date range
/// - Supports pagination and pull-to-refresh
/// - Shows transaction details in a clean, organized list
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_filter_sheet.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedTransactionType;
  DateTime? _startDate;
  DateTime? _endDate;
  int _activeFilterCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load initial transactions
    context.read<WalletBloc>().add(LoadWalletData());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<WalletBloc>().state;
      if (state is WalletLoaded && state.hasMoreTransactions) {
        context.read<WalletBloc>().add(LoadMoreTransactions(state.currentPage + 1));
      }
    }
  }

  void _updateFilterCount() {
    int count = 0;
    if (_selectedTransactionType != null) count++;
    if (_startDate != null) count++;
    if (_endDate != null) count++;
    setState(() {
      _activeFilterCount = count;
    });
  }

  void _applyFilters(String? transactionType, DateTime? startDate, DateTime? endDate) {
    setState(() {
      _selectedTransactionType = transactionType;
      _startDate = startDate;
      _endDate = endDate;
    });
    _updateFilterCount();
    
    context.read<WalletBloc>().add(FilterTransactions(
      transactionType: transactionType,
      startTime: startDate,
      endTime: endDate,
    ));
  }

  void _clearFilters() {
    setState(() {
      _selectedTransactionType = null;
      _startDate = null;
      _endDate = null;
      _activeFilterCount = 0;
    });
    
    context.read<WalletBloc>().add(LoadWalletData());
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterSheet(
        selectedTransactionType: _selectedTransactionType,
        selectedStartDate: _startDate,
        selectedEndDate: _endDate,
        onApplyFilter: _applyFilters,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            // Content
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B00),
                      ),
                    );
                  }

                  if (state is WalletError) {
                    return _buildErrorState(state.message);
                  }

                  if (state is WalletLoaded) {
                    if (state.transactions.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        if (_activeFilterCount > 0) {
                          context.read<WalletBloc>().add(FilterTransactions(
                            transactionType: _selectedTransactionType,
                            startTime: _startDate,
                            endTime: _endDate,
                          ));
                        } else {
                          context.read<WalletBloc>().add(RefreshWalletData());
                        }
                      },
                      color: const Color(0xFFFF6B00),
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Filter Bar
                          if (_activeFilterCount > 0)
                            SliverToBoxAdapter(
                              child: _buildFilterBar(),
                            ),
                          
                          // Transactions Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 12,
                                left: 16,
                                right: 16,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Transactions',
                                    style: TextStyle(
                                      color: Color(0xFF0B1220),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${state.totalCount} transactions',
                                    style: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Transactions List
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final transaction = state.transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4,
                                  ),
                                  child: TransactionListItem(transaction: transaction),
                                );
                              },
                              childCount: state.transactions.length,
                            ),
                          ),
                          
                          // Loading indicator for pagination
                          if (state is WalletLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Bottom padding
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 32),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 12,
        left: 16,
        right: 16,
        bottom: 9,
      ),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                color: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Color(0xFF0B1220),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
            child: Image.asset(
              'assets/images/logo without text/logo color.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Transaction History',
              style: TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Filter button
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 28,
              height: 28,
              decoration: ShapeDecoration(
                color: _activeFilterCount > 0 
                    ? const Color(0xFFFF6B00).withOpacity(0.1)
                    : const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: _activeFilterCount > 0 
                        ? const Color(0xFFFF6B00)
                        : const Color(0xFFE5E7EB),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.filter_list,
                      size: 18,
                      color: Color(0xFF0B1220),
                    ),
                  ),
                  if (_activeFilterCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const ShapeDecoration(
                          color: Color(0xFFFF6B00),
                          shape: CircleBorder(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getFilterSummary(),
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: const Icon(
              Icons.close,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterSummary() {
    final parts = <String>[];
    if (_selectedTransactionType != null) {
      parts.add(_selectedTransactionType!.toUpperCase());
    }
    if (_startDate != null || _endDate != null) {
      if (_startDate != null && _endDate != null) {
        parts.add('${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}');
      } else if (_startDate != null) {
        parts.add('From ${_formatDate(_startDate!)}');
      } else if (_endDate != null) {
        parts.add('Until ${_formatDate(_endDate!)}');
      }
    }
    return parts.join(' • ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: const Color(0xFF9CA3AF).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load transactions',
              style: TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                if (_activeFilterCount > 0) {
                  context.read<WalletBloc>().add(FilterTransactions(
                    transactionType: _selectedTransactionType,
                    startTime: _startDate,
                    endTime: _endDate,
                  ));
                } else {
                  context.read<WalletBloc>().add(RefreshWalletData());
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: ShapeDecoration(
                  color: const Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: const Color(0xFF9CA3AF).withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _activeFilterCount > 0
                  ? 'Try adjusting your filters to see more results'
                  : 'Your transaction history will appear here',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (_activeFilterCount > 0) ...[
              const SizedBox(height: 24),
              InkWell(
                onTap: _clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear Filters',
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
          ],
        ),
      ),
    );
  }
}

