/// wallet_screen.dart - Wallet Management Interface
/// 
/// Purpose:
/// - Provides comprehensive wallet management interface
/// - Displays wallet balance, transaction history, and balance addition functionality
/// - Manages wallet BLoC integration and real-time data updates
/// 
/// Key Logic:
/// - Uses WalletBloc instance provided at app level
/// - Displays wallet balance in attractive gradient card design
/// - Implements infinite scrolling for transaction history
/// - Provides pull-to-refresh functionality for data updates
/// - Shows add balance floating action button with modal dialog
/// - Handles loading states, error states, and success feedback
/// - Implements scroll-based pagination for transaction loading
/// - Provides comprehensive error handling with retry functionality
/// - Uses responsive design with proper theme integration
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_balance_modal.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WalletScreenContent();
  }
}

class _WalletScreenContent extends StatefulWidget {
  const _WalletScreenContent();

  @override
  State<_WalletScreenContent> createState() => _WalletScreenContentState();
}

class _WalletScreenContentState extends State<_WalletScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WalletBloc>().add(RefreshWalletData());
                    },
                    color: const Color(0xFFFF6B00),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Wallet Balance Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: 16,
                              right: 16,
                              bottom: 16,
                            ),
                            child: _buildWalletBalanceCard(state),
                          ),
                        ),
                        
                        // Quick Actions Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                            child: _buildQuickActionsSection(),
                          ),
                        ),
                        
                          // Transactions Header
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 8,
                                left: 16,
                                right: 16,
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Transaction History',
                                    style: TextStyle(
                                      color: Color(0xFF0B1220),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (state is WalletLoaded)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed('/transaction-history');
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${state.transactions.length} transactions',
                                            style: const TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 13,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 12,
                                            color: Color(0xFF9CA3AF),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Transactions List
                        if (state is WalletLoaded && state.transactions.isNotEmpty)
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final transaction = state.transactions[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                                  child: TransactionListItem(transaction: transaction),
                                );
                              },
                              childCount: state.transactions.length,
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: const Color(0xFF9CA3AF).withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No transactions yet',
                                    style: TextStyle(
                                      color: Color(0xFF0B1220),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Your transaction history will appear here',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 13,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddBalanceModal(),
          );
        },
        backgroundColor: const Color(0xFFFF6B00),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Money',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
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
              'My Wallet',
              style: TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: state is WalletLoading 
                      ? null 
                      : () => context.read<WalletBloc>().add(RefreshWalletData()),
                    child: Container(
                      width: 22,
                      height: 22,
                      child: Icon(
                        Icons.refresh_outlined,
                        size: 22,
                        color: state is WalletLoading 
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF0B1220),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
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
              'Failed to load wallet data',
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
              onTap: () => context.read<WalletBloc>().add(RefreshWalletData()),
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

  Widget _buildWalletBalanceCard(WalletState state) {
    final balance = state is WalletLoaded ? state.balance : 0.0;
    final isPositive = balance >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B00), Color(0xFFFF7A1A)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wallet Balance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${NumberFormat('#,##0.00').format(balance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: isPositive 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isPositive ? Colors.white : Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  isPositive ? 'Active' : 'Low',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBalanceStat(
                  'Total Added',
                  '₹${NumberFormat('#,##0.00').format(state is WalletLoaded ? state.balance : 0)}',
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceStat(
                  'Total Spent',
                  '₹${NumberFormat('#,##0.00').format(0)}',
                  Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: Color(0xFF0B1220),
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'Add Money',
                  Icons.add,
                  () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddBalanceModal(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  'Withdraw',
                  Icons.download,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Withdraw functionality coming soon'),
                        backgroundColor: Color(0xFF0B1220),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  'History',
                  Icons.history,
                  () {
                    Navigator.of(context).pushNamed('/transaction-history');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: const Color(0xFFF3F4F6),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0xFFE5E7EB),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFFFF6B00).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFFF6B00),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0B1220),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
