// lib/screens/products/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/stock_transaction.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/app_drawer.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;
  List<StockTransaction> _filteredTransactions = [];
  String _transactionSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final res = await ApiService.get('/api/products/${widget.productId}');
      setState(() {
        _product = Product.fromJson(res['data']);
        _filteredTransactions = _product!.stockTransactions ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadProducts}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterTransactions(String query) {
    setState(() {
      _transactionSearchQuery = query;
      if (query.isEmpty) {
        _filteredTransactions = _product!.stockTransactions ?? [];
      } else {
        _filteredTransactions =
            (_product!.stockTransactions ?? []).where((transaction) {
          return transaction.type.toLowerCase().contains(query.toLowerCase()) ||
              transaction.date.toLowerCase().contains(query.toLowerCase()) ||
              transaction.remarks
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ==
                  true ||
              transaction.user?.name
                      .toLowerCase()
                      .contains(query.toLowerCase()) ==
                  true;
        }).toList();
      }
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.products),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(activeScreen: 'products'),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
          : _product == null
              ? Center(
                  child: Text(AppLocalizations.of(context)!.noProductsFound),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Basic Info
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product!.name ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.inventory,
                                      color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${AppLocalizations.of(context)!.stockLabel}: ${_product!.stock} ${_product!.unit}',
                                    style: TextStyle(
                                      color: (_product!.stock ?? 0) <=
                                              (_product!.minimumQuantity ?? 0)
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontWeight: (_product!.stock ?? 0) <=
                                              (_product!.minimumQuantity ?? 0)
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  if ((_product!.stock ?? 0) <=
                                      (_product!.minimumQuantity ?? 0)) ...[
                                    const SizedBox(width: 4),
                                    Icon(Icons.warning,
                                        color: Colors.red, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppLocalizations.of(context)!.unit}: ${_product!.unit}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              if (_product!.category != null &&
                                  _product!.category!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _product!.category!,
                                    style: TextStyle(
                                        color: Colors.blue[700], fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Prices
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.prices,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!.costPrice),
                                  Text(NumberFormatter.formatCurrency(
                                      _product!.costPrice)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context)!
                                      .sellingPrice),
                                  Text(NumberFormatter.formatCurrency(
                                      _product!.sellingPrice)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Minimum Quantity
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!
                                  .minimumQuantity),
                              Text(
                                  '${_product!.minimumQuantity} ${_product!.unit}'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stock Transactions
                      if (_product!.stockTransactions != null &&
                          _product!.stockTransactions!.isNotEmpty) ...[
                        Text(
                          AppLocalizations.of(context)!.stockTransactions,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Search Bar for Transactions
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TextField(
                              onChanged: _filterTransactions,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context)!
                                    .searchTransactions,
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.green[600]),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredTransactions.length,
                          itemBuilder: (ctx, i) {
                            final transaction = _filteredTransactions[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  transaction.type == 'stock_in'
                                      ? Icons.add_circle
                                      : transaction.type == 'damage'
                                          ? Icons.warning
                                          : Icons.remove_circle,
                                  color: transaction.type == 'stock_in'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(
                                    '${transaction.type.replaceAll('_', ' ').toUpperCase()} - ${transaction.quantity}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${AppLocalizations.of(context)!.date}: ${transaction.date}'),
                                    if (transaction.remarks != null &&
                                        transaction.remarks!.isNotEmpty)
                                      Text(
                                          '${AppLocalizations.of(context)!.remarks}: ${transaction.remarks}'),
                                    if (transaction.user != null)
                                      Text(
                                          '${AppLocalizations.of(context)!.recordedBy}: ${transaction.user!.name}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // Timestamps
                      if (_product!.createdAt != null ||
                          _product!.updatedAt != null) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.timestamps,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_product!.createdAt != null)
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${AppLocalizations.of(context)!.created}: ${_formatDate(_product!.createdAt!)}',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                if (_product!.updatedAt != null)
                                  Row(
                                    children: [
                                      Icon(Icons.update,
                                          size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${AppLocalizations.of(context)!.updated}: ${_formatDate(_product!.updatedAt!)}',
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                              ],
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
