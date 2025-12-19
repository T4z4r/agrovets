// lib/screens/sales/sale_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/sale.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/auth_provider.dart';
import 'sale_form_screen.dart';
import 'receipt_view_screen.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      final res = await ApiService.get('/api/sales');
      setState(() {
        _sales = (res['data'] as List).map((s) => Sale.fromJson(s)).toList();
        _filteredSales = _sales;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _filterSales(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSales = _sales;
      } else {
        _filteredSales = _sales.where((sale) {
          return sale.id.toString().contains(query) ||
              sale.saleDate.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.isOwner;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sales),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSales,
          ),
        ],
      ),
      drawer: const AppDrawer(activeScreen: 'sales'),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _filterSales,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchSales,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Sales List
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
                : _filteredSales.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.point_of_sale,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? AppLocalizations.of(context)!.noSalesFound
                                  : AppLocalizations.of(context)!.noSalesMatch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSales,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredSales.length,
                          itemBuilder: (ctx, i) {
                            final s = _filteredSales[i];
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
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.point_of_sale,
                                    color: Colors.green[600],
                                  ),
                                ),
                                title: Text(
                                  '${AppLocalizations.of(context)!.sale} #${s.id}',
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
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.date}: ${_formatDate(s.saleDate)}',
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
                                          Icons.shopping_cart,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.items}: ${s.items.length}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'receipt',
                                      child: ListTile(
                                        leading: Icon(Icons.receipt),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .viewReceipt),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    if (isOwner)
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(Icons.delete,
                                              color: Colors.red),
                                          title: Text(
                                            AppLocalizations.of(context)!
                                                .deleteSale,
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'receipt') {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              ReceiptViewScreen(saleId: s.id),
                                        ),
                                      );
                                    } else if (value == 'delete') {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteSale),
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteSaleConfirm),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: TextButton.styleFrom(
                                                  foregroundColor: Colors.red),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .delete),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        try {
                                          await ApiService.delete(
                                              '/api/sales/${s.id}');
                                          _loadSales();
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                    size: 64,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .success,
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .saleDeletedSuccessfully,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                      AppLocalizations.of(
                                                              context)!
                                                          .ok),
                                                ),
                                              ],
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '${AppLocalizations.of(context)!.failedDeleteSale}: $e')),
                                          );
                                        }
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
              builder: (_) => SaleFormScreen(onSave: _loadSales),
            ),
          );
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
