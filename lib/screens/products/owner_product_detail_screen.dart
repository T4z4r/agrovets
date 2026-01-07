// lib/screens/products/owner_product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/stock_transaction.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/number_formatter.dart';
import 'product_form_screen.dart';

class OwnerProductDetailScreen extends StatefulWidget {
  final int productId;

  const OwnerProductDetailScreen({super.key, required this.productId});

  @override
  State<OwnerProductDetailScreen> createState() =>
      _OwnerProductDetailScreenState();
}

class _OwnerProductDetailScreenState extends State<OwnerProductDetailScreen> {
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
          content: Text('Failed to load product: $e'),
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

  Future<void> _deleteProduct() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text(
            '${AppLocalizations.of(context)!.deleteProductConfirm} "${_product!.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.delete('/api/products/${widget.productId}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.productDeletedSuccess),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failedDeleteProduct}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.details),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _product != null
                ? () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductFormScreen(
                          product: _product,
                          onSave: _loadProduct,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadProduct();
                    }
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _product != null ? _deleteProduct : null,
          ),
        ],
      ),
      drawer: const AppDrawer(activeScreen: 'products'),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Theme.of(context).primaryColor, size: 50.0))
          : _product == null
              ? Center(child: Text('Product not found'))
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
                                    (_product!.stock ?? 0) == 0
                                        ? '${AppLocalizations.of(context)!.stockLabel}: Out of Stock'
                                        : '${AppLocalizations.of(context)!.stockLabel}: ${_product!.stock} ${_product!.unit}',
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
                              if (_product!.barcode != null &&
                                  _product!.barcode!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.qr_code,
                                        color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Barcode: ${_product!.barcode}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Stock Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Current Stock',
                                      '${_product!.stock} ${_product!.unit}',
                                      Icons.inventory,
                                      (_product!.stock ?? 0) <=
                                              (_product!.minimumQuantity ?? 0)
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Minimum Quantity',
                                      '${_product!.minimumQuantity ?? 0} ${_product!.unit}',
                                      Icons.warning,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pricing Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pricing Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Cost Price',
                                      NumberFormatter.formatCurrency(
                                          _product!.costPrice),
                                      Icons.money_off,
                                      Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildInfoItem(
                                      'Selling Price',
                                      NumberFormatter.formatCurrency(
                                          _product!.sellingPrice),
                                      Icons.attach_money,
                                      Colors.green,
                                    ),
                                  ),
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
                                    color: Theme.of(context).primaryColor),
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

                      const SizedBox(height: 16),

                      // Additional Information
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Information',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildInfoItem(
                                'Unit',
                                _product!.unit!,
                                Icons.scale,
                                Colors.blue,
                              ),
                              if (_product!.barcode != null &&
                                  _product!.barcode!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildInfoItem(
                                  'Barcode',
                                  _product!.barcode!,
                                  Icons.qr_code,
                                  Colors.purple,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

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

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
