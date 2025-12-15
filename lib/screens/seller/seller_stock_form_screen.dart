// lib/screens/seller/seller_stock_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';

class SellerStockFormScreen extends StatefulWidget {
  final VoidCallback onSave;

  const SellerStockFormScreen({super.key, required this.onSave});

  @override
  State<SellerStockFormScreen> createState() => _SellerStockFormScreenState();
}

class _SellerStockFormScreenState extends State<SellerStockFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _productId;
  String _type = 'stock_in';
  int? _quantity;
  int? _supplierId;
  DateTime _date = DateTime.now();
  String? _remarks;
  List<Product> _products = [];
  List<Supplier> _suppliers = [];
  bool _loading = true;
  String? _selectedProductName;
  late TextEditingController _productController;
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController();
    _searchController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    _productController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final pRes = await ApiService.get('/api/products');
      final sRes = await ApiService.get('/api/suppliers');
      setState(() {
        _products =
            (pRes['data'] as List).map((p) => Product.fromJson(p)).toList();
        _suppliers =
            (sRes['data'] as List).map((s) => Supplier.fromJson(s)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where(
            (p) => p.name!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'product_id': _productId,
      'type': _type,
      'quantity': _quantity,
      'supplier_id': _supplierId,
      'date': DateFormat('yyyy-MM-dd').format(_date),
      'remarks': _remarks,
    };
    try {
      await ApiService.post('/api/stock', data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.stockTransactionSaved),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.failedSaveStock}: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.retry,
            textColor: Colors.white,
            onPressed: _save,
          ),
        ),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _selectProduct() async {
    _searchQuery = '';
    _searchController.clear();
    final selectedProduct = await showDialog<Product>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectProduct),
          content: SizedBox(
            height: 400,
            width: double.maxFinite,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Products',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        title: Text(product.name ?? 'Unknown Product'),
                        onTap: () => Navigator.pop(context, product),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (selectedProduct != null) {
      setState(() {
        _productId = selectedProduct.id;
        _selectedProductName = selectedProduct.name;
        _productController.text = selectedProduct.name!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createStockTransaction),
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
                    // Stock Icon Header
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.inventory,
                        size: 40,
                        color: Colors.orange[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields Card
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
                              AppLocalizations.of(context)!
                                  .stockTransactionTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Product Selection
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.selectProduct,
                                hintText:
                                    AppLocalizations.of(context)!.chooseProduct,
                                prefixIcon: const Icon(Icons.inventory_2),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: _productController,
                              onTap: _selectProduct,
                              validator: (v) => _productId == null
                                  ? 'Product is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // Transaction Type
                            DropdownButtonFormField<String>(
                              value: _type,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .transactionType,
                                prefixIcon: const Icon(Icons.swap_vert),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'stock_in',
                                  child: Row(
                                    children: [
                                      Icon(Icons.trending_up,
                                          color: Colors.green[600]),
                                      const SizedBox(width: 8),
                                      const Text('Stock In'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'stock_out',
                                  child: Row(
                                    children: [
                                      Icon(Icons.trending_down,
                                          color: Colors.red[600]),
                                      const SizedBox(width: 8),
                                      const Text('Stock Out'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'damage',
                                  child: Row(
                                    children: [
                                      Icon(Icons.error,
                                          color: Colors.orange[600]),
                                      const SizedBox(width: 8),
                                      const Text('Damage'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'return',
                                  child: Row(
                                    children: [
                                      Icon(Icons.keyboard_return,
                                          color: Colors.blue[600]),
                                      const SizedBox(width: 8),
                                      const Text('Return'),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() => _type = v!),
                            ),
                            const SizedBox(height: 16),

                            // Quantity Field
                            TextFormField(
                              onChanged: (v) => _quantity = int.tryParse(v),
                              decoration: InputDecoration(
                                labelText:
                                    AppLocalizations.of(context)!.quantity,
                                hintText:
                                    AppLocalizations.of(context)!.enterQuantity,
                                prefixIcon:
                                    const Icon(Icons.format_list_numbered),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Quantity is required';
                                }
                                if (int.tryParse(v) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Supplier Selection (Optional)
                            DropdownButtonFormField<int>(
                              value: _supplierId,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .supplierOptional,
                                hintText: AppLocalizations.of(context)!
                                    .selectSupplier,
                                prefixIcon: const Icon(Icons.business),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: _suppliers
                                  .map((s) => DropdownMenuItem(
                                      value: s.id, child: Text(s.name)))
                                  .toList(),
                              onChanged: (v) => setState(() => _supplierId = v),
                            ),
                            const SizedBox(height: 16),

                            // Date Field
                            TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .transactionDate,
                                hintText:
                                    AppLocalizations.of(context)!.selectDate,
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              onTap: _selectDate,
                              controller: TextEditingController(
                                  text: DateFormat('yyyy-MM-dd').format(_date)),
                            ),
                            const SizedBox(height: 16),

                            // Remarks Field
                            TextFormField(
                              onChanged: (v) => _remarks = v,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!
                                    .remarksOptional,
                                hintText:
                                    AppLocalizations.of(context)!.addNotes,
                                prefixIcon: const Icon(Icons.note),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),

                            // Save Button
                            ElevatedButton(
                              onPressed: _loading ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                      AppLocalizations.of(context)!
                                          .saveTransaction,
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
                  ],
                ),
              ),
            ),
    );
  }
}
