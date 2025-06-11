import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/models/wallet_model.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../bloc/wallet_bloc.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/add_balance_modal.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(serviceLocator<WalletRepository>())
        ..add(LoadWalletData()),
      child: const _WalletScreenContent(),
    );
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
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Wallet'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: state is WalletLoading 
                  ? null 
                  : () => context.read<WalletBloc>().add(RefreshWalletData()),
              );
            },
          ),
        ],
      ),
      body: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is AddBalanceSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.primary,
              ),
            );
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            if (state is WalletLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            if (state is WalletError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Failed to load wallet data',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: () => context.read<WalletBloc>().add(LoadWalletData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is WalletLoaded || state is WalletLoadingMore) {
              final walletData = state is WalletLoaded ? state : (state as WalletLoadingMore);
              final balance = state is WalletLoaded ? state.balance : (state as WalletLoadingMore).balance;
              final transactions = state is WalletLoaded ? state.transactions : (state as WalletLoadingMore).transactions;
              final isLoadingMore = state is WalletLoadingMore;
              final hasMoreTransactions = state is WalletLoaded ? state.hasMoreTransactions : false;
              final totalCount = state is WalletLoaded ? state.totalCount : 0;

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletBloc>().add(RefreshWalletData());
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceCard(context, theme, balance),
                      const SizedBox(height: AppSpacing.xl),
                      _buildTransactionHistory(context, theme, transactions, totalCount, hasMoreTransactions, isLoadingMore),
                    ],
                  ),
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is AddBalanceLoading) {
            return FloatingActionButton(
              onPressed: null,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          
          return FloatingActionButton.extended(
            onPressed: () => _showAddBalanceModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Balance'),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, ThemeData theme, double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: theme.colorScheme.onPrimary,
                size: 28,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Wallet Balance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '₹${NumberFormat('#,##,###.##').format(balance)}',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Available for transactions',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(BuildContext context, ThemeData theme, List<WalletTransaction> transactions, int totalCount, bool hasMoreTransactions, bool isLoadingMore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Transaction History',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$totalCount total',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        
        if (transactions.isEmpty)
          _buildEmptyTransactions(theme)
        else
          Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  return TransactionListItem(transaction: transactions[index]);
                },
              ),
              if (hasMoreTransactions || isLoadingMore) ...[
                const SizedBox(height: AppSpacing.lg),
                if (isLoadingMore)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        final state = context.read<WalletBloc>().state;
                        if (state is WalletLoaded) {
                          context.read<WalletBloc>().add(LoadMoreTransactions(state.currentPage + 1));
                        }
                      },
                      icon: const Icon(Icons.expand_more),
                      label: const Text('Load More'),
                    ),
                  ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyTransactions(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your transaction history will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddBalanceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (BuildContext modalContext) {
        return BlocProvider.value(
          value: context.read<WalletBloc>(),
          child: const AddBalanceModal(),
        );
      },
    );
  }
} 