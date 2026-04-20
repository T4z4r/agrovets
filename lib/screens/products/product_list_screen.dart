// lib/screens/products/product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/number_formatter.dart';
import '../../providers/product_provider.dart';
import 'product_form_screen.dart';
import 'owner_product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  bool _showLowStockOnly = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String query) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    setState(() {
      _searchQuery = query;
      List<Product> filtered = productProvider.products;

      // Apply search filter
      if (query.isNotEmpty) {
        filtered = filtered.where((product) {
          return product.name!.toLowerCase().contains(query.toLowerCase()) ||
              product.unit!.toLowerCase().contains(query.toLowerCase()) ||
              product.category!.toLowerCase().contains(query.toLowerCase()) ||
              (product.barcode?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }

      // Apply low stock filter
      if (_showLowStockOnly) {
        filtered = filtered.where((product) {
          return (product.stock ?? 0) <= (product.minimumQuantity ?? 0);
        }).toList();
      }

      _filteredProducts = filtered;
    });
  }

  Future<void> _scanBarcode() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.cameraPermissionRequired),
            action: const SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.cameraPermissionPermanentlyDenied),
          action: const SnackBarAction(
            label: 'Settings',
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    final scannedBarcode = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              AppBar(
                title: Text(AppLocalizations.of(context)!.scanBarcode),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final barcode = barcodes.first.rawValue;
                      if (barcode != null) {
                        Navigator.pop(context, barcode);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (scannedBarcode != null) {
      _searchController.text = scannedBarcode;
      _filterProducts(scannedBarcode);
    }
  }

  Future<void> _deleteProduct(int id, String productName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProduct),
        content: Text(
            '${AppLocalizations.of(context)!.deleteProductConfirm} "$productName"?'),
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
        await ApiService.delete('/api/products/$id');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.productDeletedSuccess),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
        Provider.of<ProductProvider>(context, listen: false).fetchProducts();
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
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        // Compute filtered products
        List<Product> filtered = productProvider.products;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filtered = filtered.where((product) {
            return product.name!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.unit!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.category!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (product.barcode?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                    false);
          }).toList();
        }

        // Apply low stock filter
        if (_showLowStockOnly) {
          filtered = filtered.where((product) {
            return (product.stock ?? 0) <= (product.minimumQuantity ?? 0);
          }).toList();
        }

        _filteredProducts = filtered;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.products),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _showLowStockOnly = !_showLowStockOnly;
                    _filterProducts(_searchQuery);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _showLowStockOnly ? Colors.red : Colors.white,
                  ),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text(
                  _showLowStockOnly
                      ? AppLocalizations.of(context)!.products
                      : AppLocalizations.of(context)!.outOfStock,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => productProvider.fetchProducts(),
              ),
            ],
          ),
          drawer: const AppDrawer(activeScreen: 'products'),
          body: Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterProducts,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.searchProducts,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanBarcode,
                      tooltip: AppLocalizations.of(context)!.scanBarcode,
                    ),
                  ],
                ),
              ),

              // Products List
              Expanded(
                child: productProvider.loading
                    ? Center(
                        child: SpinKitWaveSpinner(
                            color: Theme.of(context).primaryColor, size: 50.0))
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? AppLocalizations.of(context)!
                                          .noProductsFound
                                      : AppLocalizations.of(context)!
                                          .noProductsMatch,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => productProvider.fetchProducts(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(4),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (ctx, i) {
                                final p = _filteredProducts[i];
                                 return Card(
                                   margin: const EdgeInsets.only(bottom: 8),
                                   elevation: 2,
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(4),
                                   ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColorLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.inventory,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      p.name!,
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
                                              Icons.inventory,
                                              size: 14,
                                              color: (p.stock ?? 0) <=
                                                      (p.minimumQuantity ?? 0)
                                                  ? Colors.red
                                                  : Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (p.stock ?? 0) == 0
                                                  ? '${AppLocalizations.of(context)!.stockLabel}: ${AppLocalizations.of(context)!.outOfStock}'
                                                  : '${AppLocalizations.of(context)!.stockLabel}: ${p.stock} ${p.unit}',
                                              style: TextStyle(
                                                color: (p.stock ?? 0) == 0
                                                    ? Colors.red
                                                    : (p.stock ?? 0) <=
                                                            (p.minimumQuantity ?? 0)
                                                        ? Colors.red
                                                        : Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: (p.stock ?? 0) == 0 ||
                                                        (p.stock ?? 0) <=
                                                            (p.minimumQuantity ?? 0)
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                            if ((p.stock ?? 0) <=
                                                (p.minimumQuantity ?? 0)) ...[
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.warning,
                                                size: 14,
                                                color: Colors.red,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${AppLocalizations.of(context)!.priceLabel}: ${NumberFormatter.formatCurrency(p.sellingPrice)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (p.category != null &&
                                            p.category!.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              p.category!,
                                              style: TextStyle(
                                                color: Colors.blue[700],
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OwnerProductDetailScreen(
                                              productId: p.id),
                                        ),
                                      );
                                    },
                                    trailing: PopupMenuButton(
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'view',
                                          child: ListTile(
                                            leading: const Icon(Icons.visibility),
                                            title: Text(
                                                AppLocalizations.of(context)!
                                                    .viewDetails),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: const Icon(Icons.edit),
                                            title: Text(
                                                AppLocalizations.of(context)!.edit),
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
                                        if (value == 'view') {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  OwnerProductDetailScreen(
                                                      productId: p.id),
                                            ),
                                          );
                                         } else if (value == 'edit') {
                                           await Navigator.push(
                                             context,
                                             MaterialPageRoute(
                                               builder: (_) => ProductFormScreen(
                                                 product: p,
                                                 onSave: () => productProvider.fetchProducts(),
                                               ),
                                             ),
                                           );
                                        } else if (value == 'delete') {
                                          _deleteProduct(p.id, p.name!);
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

          // Floating Action Button
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(onSave: () => productProvider.fetchProducts()),
                ),
              );
            },
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}
