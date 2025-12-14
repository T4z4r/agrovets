// lib/screens/seller/seller_stock_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/stock_transaction.dart';
import 'seller_stock_form_screen.dart';

class SellerStockListScreen extends StatefulWidget {
  const SellerStockListScreen({super.key});

  @override
  State<SellerStockListScreen> createState() => _SellerStockListScreenState();
}

class _SellerStockListScreenState extends State<SellerStockListScreen> {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
                ? Center(child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
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
                                  ? AppLocalizations.of(context)!.noTransactionsFound
                                  : AppLocalizations.of(context)!.noTransactionsMatch,
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
                          iconColor = Colors.green[600]!;
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.format_list_numbered,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${AppLocalizations.of(context)!.quantityLabel}: ${t.quantity}',
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
                                        t.remarks!,
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
              builder: (_) => SellerStockFormScreen(onSave: _loadTransactions),
            ),
          );
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}