// lib/screens/seller/seller_sale_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
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
        title: const Text('Create Sale'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
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
                              'Sale Details',
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
                                labelText: 'Sale Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              onTap: _selectDate,
                              controller: TextEditingController(
                                  text: DateFormat('yyyy-MM-dd').format(_date)),
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
                                  'Sale Items',
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
                                  label: const Text('Add Item'),
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
                                      'No items added yet',
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
                                        decoration: const InputDecoration(
                                          labelText: 'Product',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                        ),
                                        items: _filteredProducts
                                            .map((p) => DropdownMenuItem(
                                                value: p.id,
                                                child: Text(p.name!)))
                                            .toList(),
                                        onChanged: (v) => setState(() =>
                                            _items[idx]['product_id'] = v),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              onChanged: (v) => _items[idx]
                                                      ['quantity'] =
                                                  int.tryParse(v),
                                              decoration: const InputDecoration(
                                                labelText: 'Qty',
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
                                              onChanged: (v) => _items[idx]
                                                  ['price'] = int.tryParse(v),
                                              decoration: const InputDecoration(
                                                labelText: 'Price',
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
                          : const Text(
                              'Create Sale',
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
        child: const Text(
          'Select Products',
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
                hintText: 'Search products...',
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
                        'Price: ${NumberFormatter.formatCurrency(product.sellingPrice)}',
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
          child: const Text('Cancel'),
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
          child: const Text('Add Selected'),
        ),
      ],
    );
  }
}