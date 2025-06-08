import 'package:flutter/material.dart';
import 'package:logistix_driver/services/auth_service.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  
  // State variables
  double? _walletBalance;
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingBalance = true;
  bool _isLoadingTransactions = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreTransactions = true;
  int _totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    _initializeWalletData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeWalletData() async {
    await Future.wait([
      _fetchWalletBalance(),
      _fetchTransactions(isRefresh: true),
    ]);
  }

  Future<void> _fetchWalletBalance() async {
    try {
      setState(() {
        _isLoadingBalance = true;
        _errorMessage = null;
      });

      final result = await _authService.getWalletBalance();
      
      if (result != null && mounted) {
        setState(() {
          _walletBalance = (result['balance'] as num?)?.toDouble();
          _isLoadingBalance = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load wallet balance';
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading wallet balance: $e';
          _isLoadingBalance = false;
        });
      }
    }
  }

  Future<void> _fetchTransactions({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isLoadMore && (_isLoadingMore || !_hasMoreTransactions)) return;

    try {
      setState(() {
        if (isRefresh) {
          _isLoadingTransactions = true;
          _currentPage = 1;
          _transactions = [];
          _hasMoreTransactions = true;
        } else if (isLoadMore) {
          _isLoadingMore = true;
        } else {
          _isLoadingTransactions = true;
        }
        _errorMessage = null;
      });

      // Get date range for last 30 days
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(days: 30));
      
      final result = await _authService.getWalletTransactions(
        page: _currentPage,
        pageSize: 10,
        startTime: startTime.toIso8601String(),
        endTime: endTime.toIso8601String(),
      );
      
      if (result != null && mounted) {
        final newTransactions = List<Map<String, dynamic>>.from(result['results'] ?? []);
        
        setState(() {
          if (isRefresh || _currentPage == 1) {
            _transactions = newTransactions;
          } else {
            _transactions.addAll(newTransactions);
          }
          
          _totalTransactions = result['count'] ?? 0;
          _hasMoreTransactions = result['next'] != null;
          _currentPage++;
          
          _isLoadingTransactions = false;
          _isLoadingMore = false;
        });
      } else if (mounted) {
        setState(() {
          if (isRefresh || _currentPage == 1) {
            _errorMessage = 'Failed to load transactions';
          }
          _isLoadingTransactions = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isRefresh || _currentPage == 1) {
            _errorMessage = 'Error loading transactions: $e';
          }
          _isLoadingTransactions = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchTransactions(isLoadMore: true);
    }
  }

  Future<void> _onRefresh() async {
    await _initializeWalletData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet Balance Card
            _buildBalanceCard(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
            
            const SizedBox(height: 24),
            
            // Recent Transactions
            _buildTransactionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wallet Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _isLoadingBalance
                ? const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Text(
                    '₹${_walletBalance?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      color: _walletBalance != null && _walletBalance! < 0 
                          ? Colors.red.shade200 
                          : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 16),
            if (_errorMessage != null && _walletBalance == null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade200, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade200,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Transactions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _totalTransactions.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last 30 Days',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_transactions.length} transactions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                // TODO: Implement withdraw functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Withdraw functionality coming soon!')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Withdraw',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: InkWell(
              onTap: () {
                // TODO: Implement detailed transaction history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Detailed history coming soon!')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 32,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_isLoadingTransactions && _transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_errorMessage != null && _transactions.isEmpty)
          _buildErrorWidget()
        else if (_transactions.isEmpty)
          _buildEmptyWidget()
        else
          ..._buildTransactionsList(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionsList() {
    final widgets = <Widget>[];
    
    for (final transaction in _transactions) {
      widgets.add(_buildTransactionItem(transaction));
    }
    
    // Add loading indicator for pagination
    if (_isLoadingMore) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    // Add "Load More" button if there are more transactions
    else if (_hasMoreTransactions && _transactions.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: OutlinedButton(
              onPressed: () => _fetchTransactions(isLoadMore: true),
              child: const Text('Load More'),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final typeInfo = _getTransactionTypeInfo(transaction['type_tx'] ?? '');
    final createdAt = DateTime.tryParse(transaction['created_at'] ?? '');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeInfo['color'].withOpacity(0.1),
          child: Icon(typeInfo['icon'], color: typeInfo['color']),
        ),
        title: Text(
          typeInfo['title'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction['remarks'] ?? 'No description',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${amount >= 0 ? '+' : ''}₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: amount >= 0 ? Colors.green : Colors.red,
              ),
            ),
            if (createdAt != null)
              Text(
                _formatDate(createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getTransactionTypeInfo(String type) {
    switch (type) {
      case 'TRIP_COMMISSION':
        return {
          'title': 'Trip Commission',
          'icon': Icons.directions_car,
          'color': Colors.green,
        };
      case 'WITHDRAWAL':
        return {
          'title': 'Withdrawal',
          'icon': Icons.account_balance,
          'color': Colors.orange,
        };
      case 'REFUND':
        return {
          'title': 'Refund',
          'icon': Icons.refresh,
          'color': Colors.blue,
        };
      case 'PENALTY':
        return {
          'title': 'Penalty',
          'icon': Icons.warning,
          'color': Colors.red,
        };
      default:
        return {
          'title': type.replaceAll('_', ' ').toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
          'icon': Icons.receipt,
          'color': Colors.grey,
        };
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
} 