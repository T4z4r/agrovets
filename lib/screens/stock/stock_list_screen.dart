// lib/screens/stock/stock_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/stock_transaction.dart';
import '../../widgets/app_drawer.dart';
import 'stock_form_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<StockTransaction> _transactions = [];
  List<StockTransaction> _filteredTransactions = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final res = await ApiService.get('/api/stock');
      setState(() {
        _transactions = (res['data'] as List)
            .map((t) => StockTransaction.fromJson(t))
            .toList();
        _filteredTransactions = _transactions;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadStock}: $e'),  backgroundColor: Colors.red,));
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await ApiService.delete('/api/stock/$id');
      _loadTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.failedDeleteProduct}: $e'),  backgroundColor: Colors.red,));
    }
  }

  void _showTransactionDetails(BuildContext context, StockTransaction t) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${t.type.replaceAll('_', ' ').toUpperCase()} ${AppLocalizations.of(context)!.details}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (t.product != null) ...[
                Text(
                    '${AppLocalizations.of(context)!.product}: ${t.product!.name}'),
                const SizedBox(height: 8),
              ],
              Text(
                  '${AppLocalizations.of(context)!.type}: ${t.type.replaceAll('_', ' ')}'),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context)!.quantity}: ${t.quantity}'),
              const SizedBox(height: 8),
              Text('${AppLocalizations.of(context)!.dateLabel}: ${t.date}'),
              const SizedBox(height: 8),
              if (t.supplier != null) ...[
                Text(
                    '${AppLocalizations.of(context)!.supplier}: ${t.supplier!.name}'),
                const SizedBox(height: 8),
              ],
              if (t.user != null) ...[
                Text(
                    '${AppLocalizations.of(context)!.recordedBy}: ${t.user!.name} (${t.user!.role})'),
                const SizedBox(height: 8),
              ],
              if (t.remarks != null && t.remarks!.isNotEmpty) ...[
                Text('${AppLocalizations.of(context)!.remarks}: ${t.remarks}'),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _filterTransactions(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTransactions = _transactions;
      } else {
        _filteredTransactions = _transactions.where((transaction) {
          return transaction.type.toLowerCase().contains(query.toLowerCase()) ||
              transaction.date.toLowerCase().contains(query.toLowerCase()) ||
              (transaction.remarks
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.stockTransactions),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      drawer: const AppDrawer(activeScreen: 'stock'),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _filterTransactions,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchTransactions,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Transactions List
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitWaveSpinner(
                        color: Theme.of(context).primaryColor, size: 50.0))
                : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? AppLocalizations.of(context)!
                                      .noTransactionsFound
                                  : AppLocalizations.of(context)!
                                      .noTransactionsMatch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (ctx, i) {
                            final t = _filteredTransactions[i];
                            // Determine icon and color based on transaction type
                            IconData iconData;
                            Color iconColor;
                            Color cardColor;

                            switch (t.type) {
                              case 'stock_in':
                                iconData = Icons.trending_up;
                                iconColor = Theme.of(context).primaryColor;
                                cardColor = Colors.green[50]!;
                                break;
                              case 'stock_out':
                                iconData = Icons.trending_down;
                                iconColor = Colors.red[600]!;
                                cardColor = Colors.red[50]!;
                                break;
                              case 'damage':
                                iconData = Icons.error;
                                iconColor = Colors.orange[600]!;
                                cardColor = Colors.orange[50]!;
                                break;
                              case 'return':
                                iconData = Icons.keyboard_return;
                                iconColor = Colors.blue[600]!;
                                cardColor = Colors.blue[50]!;
                                break;
                              default:
                                iconData = Icons.inventory;
                                iconColor = Colors.grey[600]!;
                                cardColor = Colors.grey[50]!;
                            }

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    iconData,
                                    color: iconColor,
                                  ),
                                ),
                                title: Text(
                                  t.type.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    if (t.product != null) ...[
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${AppLocalizations.of(context)!.product}: ${t.product!.name}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.format_list_numbered,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.quantity}: ${t.quantity}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.dateLabel}: ${t.date}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (t.remarks != null &&
                                        t.remarks!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.note,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${AppLocalizations.of(context)!.remarks}: ${t.remarks!}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'view_details',
                                      child: ListTile(
                                        leading: const Icon(Icons.visibility,
                                            color: Colors.blue),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .viewDetails,
                                            style:
                                                const TextStyle(color: Colors.blue)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: const Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .delete,
                                            style:
                                                const TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'view_details') {
                                      _showTransactionDetails(context, t);
                                    } else if (value == 'delete') {
                                      // Show confirmation dialog
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteTransaction),
                                          content: Text(
                                              '${AppLocalizations.of(context)!.deleteProductConfirm} ${t.type.replaceAll('_', ' ')} transaction?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .delete),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await _deleteTransaction(t.id);
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockFormScreen(onSave: _loadTransactions),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
