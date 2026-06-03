// lib/screens/seller/seller_product_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/product_image.dart';
import '../../screens/products/seller_product_detail_screen.dart';
import 'seller_product_form_screen.dart';

class SellerProductListScreen extends StatefulWidget {
  const SellerProductListScreen({super.key});

  @override
  State<SellerProductListScreen> createState() =>
      _SellerProductListScreenState();
}

class _SellerProductListScreenState extends State<SellerProductListScreen> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _loading = true;
  String _searchQuery = '';
  bool _showLowStockOnly = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final res = await ApiService.get('/api/products');
      if (mounted) {
        setState(() {
          _products =
              (res['data'] as List).map((p) => Product.fromJson(p)).toList();
          _filteredProducts = _products;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.failedLoadProducts),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      List<Product> filtered = _products;

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

  @override
  Widget build(BuildContext context) {
    // Compute filtered products
    List<Product> filtered = _products;

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
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
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
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showLowStockOnly = !_showLowStockOnly;
                        _filterProducts(_searchQuery);
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _showLowStockOnly ? Colors.red : Colors.grey,
                      ),
                      foregroundColor: _showLowStockOnly ? Colors.red : Colors.black,
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: Text(
                      _showLowStockOnly
                          ? AppLocalizations.of(context)!.products
                          : AppLocalizations.of(context)!.outOfStock,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products List
          Expanded(
            child: _loading
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
                                  ? AppLocalizations.of(context)!.noProductsFound
                                  : AppLocalizations.of(context)!.noProductsMatch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(4),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (ctx, i) {
                            final p = _filteredProducts[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: ProductImage(
                                  imageUrl: p.imageUrl,
                                  width: 50,
                                  height: 50,
                                  borderRadius: 8,
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
                                              ? '${AppLocalizations.of(context)!.stockLabel}: Out of Stock'
                                              : '${AppLocalizations.of(context)!.stockLabel}: ${p.stock} ${p.unit}',
                                          style: TextStyle(
                                            color: (p.stock ?? 0) <=
                                                    (p.minimumQuantity ?? 0)
                                                ? Colors.red
                                                : Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: (p.stock ?? 0) <=
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
                                   ],
                                   onSelected: (value) async {
                                     if (value == 'view') {
                                       Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                           builder: (_) =>
                                               SellerProductDetailScreen(
                                                   productId: p.id),
                                         ),
                                       );
                                     } else if (value == 'edit') {
                                       await Navigator.push(
                                         context,
                                         MaterialPageRoute(
                                           builder: (_) => SellerProductFormScreen(
                                             product: p,
                                             onSave: _loadProducts,
                                           ),
                                         ),
                                       );
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
    );
  }
}
