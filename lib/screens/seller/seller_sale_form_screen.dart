// lib/screens/seller/seller_sale_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../utils/number_formatter.dart';

class SellerSaleFormScreen extends StatefulWidget {
  final VoidCallback onSave;

  const SellerSaleFormScreen({super.key, required this.onSave});

  @override
  State<SellerSaleFormScreen> createState() => _SellerSaleFormScreenState();
}

class _SellerSaleFormScreenState extends State<SellerSaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _sellerId;
  DateTime _date = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  List<Product> _products = [];
  bool _loading = true;
  String _productSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pRes = await ApiService.get('/api/products');
      setState(() {
        _products =
            (pRes['data'] as List).map((p) => Product.fromJson(p)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _addItem() async {
     final selectedProducts = await showDialog<List<Product>>(
       context: context,
       builder: (context) => _ProductSelectionDialog(products: _products),
     );
     if (selectedProducts != null && selectedProducts.isNotEmpty) {
       setState(() {
         for (final product in selectedProducts) {
           _items.add({
             'product_id': product.id,
             'quantity': 1,
             'price': product.sellingPrice,
           });
         }
       });
     }
   }

  Future<void> _scanBarcode() async {
    // Check camera permission
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to scan barcodes'),
            action: SnackBarAction(
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
        const SnackBar(
          content: Text('Camera permission is permanently denied. Please enable it in settings.'),
          action: SnackBarAction(
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
                title: Text('Scan Barcode'),
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
      try {
        // Get product by barcode from API
        final response = await ApiService.get('/api/products/barcode/$scannedBarcode');

        if (response['success'] == true) {
          final product = Product.fromJson(response['data']);

          setState(() {
            // Check if product is already in the items list
            final existingItemIndex = _items.indexWhere(
              (item) => item['product_id'] == product.id,
            );

            if (existingItemIndex != -1) {
              // Increment quantity if product already exists
              _items[existingItemIndex]['quantity'] = (_items[existingItemIndex]['quantity'] as int) + 1;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Increased quantity of ${product.name}')),
              );
            } else {
              // Add new item if product doesn't exist
              _items.add({
                'product_id': product.id,
                'quantity': 1,
                'price': product.sellingPrice,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${product.name} to sale')),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product not found for scanned barcode')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finding product: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'seller_id': _sellerId,
      'sale_date': DateFormat('yyyy-MM-dd').format(_date),
      'items': _items,
    };
    try {
      await ApiService.post('/api/sales', data);
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  List<Product> get _filteredProducts => _products
      .where((p) =>
          p.name!.toLowerCase().contains(_productSearchQuery.toLowerCase()))
      .toList();

  double get _totalAmount => _items.fold(0.0, (sum, item) =>
      sum + ((item['quantity'] as int) * (item['price'] as num)));

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createSale),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text('Scan', style: TextStyle(color: Colors.white)),
            onPressed: _scanBarcode,
          ),
        ],
      ),
      body: _loading
          ? Center(child: SpinKitWaveSpinner(color: Colors.green, size: 50.0))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.saleDetails,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.saleDate,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              onTap: _selectDate,
                              initialValue:
                                  DateFormat('yyyy-MM-dd').format(_date),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.saleItems,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addItem,
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                      AppLocalizations.of(context)!.addItem),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_items.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .noItemsAddedYet,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ..._items.asMap().entries.map((entry) {
                                int idx = entry.key;
                                return Container(
                                  key: ValueKey('item_${idx}_${_items[idx]['quantity']}'),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<int>(
                                        value: _items[idx]['product_id'],
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .product,
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                        items: _filteredProducts
                                            .map((p) => DropdownMenuItem(
                                                value: p.id,
                                                child: Text(p.name!)))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            final product = _products
                                                .firstWhere((p) => p.id == v);
                                            setState(() {
                                              _items[idx]['product_id'] = v;
                                              _items[idx]['price'] =
                                                  product.sellingPrice;
                                            });
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: _items[idx]
                                                      ['quantity']
                                                  .toString(),
                                              onChanged: (v) => _items[idx]
                                                      ['quantity'] =
                                                  int.tryParse(v) ?? 1,
                                              decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                        context)!
                                                    .qty,
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextFormField(
                                              initialValue: _items[idx]['price']
                                                  .toString(),
                                              onChanged: (v) => _items[idx]
                                                      ['price'] =
                                                  int.tryParse(v) ?? 0,
                                              decoration: InputDecoration(
                                                labelText: AppLocalizations.of(
                                                        context)!
                                                    .price,
                                                border: OutlineInputBorder(),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red),
                                            onPressed: () => setState(
                                                () => _items.removeAt(idx)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_items.isNotEmpty)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                NumberFormatter.formatCurrency(_totalAmount),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: SpinKitWaveSpinner(
                                  color: Colors.white, size: 20.0),
                            )
                          : Text(
                              AppLocalizations.of(context)!.createSale,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ProductSelectionDialog extends StatefulWidget {
  final List<Product> products;

  const _ProductSelectionDialog({required this.products});

  @override
  State<_ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<_ProductSelectionDialog> {
  String _searchQuery = '';
  final Set<int> _selectedProductIds = {};

  List<Product> get _filteredProducts => widget.products
      .where((p) => p.name!.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[600],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context)!.selectProducts,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchProducts,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _filteredProducts.map((product) {
                  final isSelected = _selectedProductIds.contains(product.id);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CheckboxListTile(
                      title: Text(
                        product.name!,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${AppLocalizations.of(context)!.price}: ${NumberFormatter.formatCurrency(product.sellingPrice)}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      value: isSelected,
                      activeColor: Colors.green[600],
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedProductIds.add(product.id!);
                          } else {
                            _selectedProductIds.remove(product.id);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedProducts = widget.products
                .where((p) => _selectedProductIds.contains(p.id))
                .toList();
            Navigator.pop(context, selectedProducts);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(AppLocalizations.of(context)!.addSelected),
        ),
      ],
    );
  }
}
