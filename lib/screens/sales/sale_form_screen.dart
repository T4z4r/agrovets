// lib/screens/sales/sale_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/user.dart';

class SaleFormScreen extends StatefulWidget {
  final VoidCallback onSave;

  const SaleFormScreen({super.key, required this.onSave});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _sellerId;
  DateTime _date = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  List<Product> _products = [];
  List<User> _sellers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final pRes = await ApiService.get('/api/products');
      // Assume we fetch sellers somehow; for simplicity, use /api/me or separate endpoint if needed
      // Here, mocking sellers as users with role 'seller'
      // In real, you might need an endpoint for users
      setState(() {
        _products =
            (pRes['data'] as List).map((p) => Product.fromJson(p)).toList();
        // _sellers = ... fetch sellers
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _addItem() {
    setState(() {
      _items.add({'product_id': null, 'quantity': null, 'price': null});
    });
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
      appBar: AppBar(title: const Text('Create Sale')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _sellerId,
                      hint: const Text('Select Seller'),
                      items: _sellers
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _sellerId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Date'),
                      onTap: _selectDate,
                      controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(_date)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Items:'),
                    ..._items.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _items[idx]['product_id'],
                              hint: const Text('Product'),
                              items: _products
                                  .map((p) => DropdownMenuItem(
                                      value: p.id, child: Text(p.name!)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _items[idx]['product_id'] = v),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              onChanged: (v) =>
                                  _items[idx]['quantity'] = int.tryParse(v),
                              decoration:
                                  const InputDecoration(labelText: 'Qty'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              onChanged: (v) =>
                                  _items[idx]['price'] = int.tryParse(v),
                              decoration:
                                  const InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () =>
                                setState(() => _items.removeAt(idx)),
                          ),
                        ],
                      );
                    }),
                    ElevatedButton(
                        onPressed: _addItem, child: const Text('Add Item')),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _loading ? null : _save,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text('Save')),
                  ],
                ),
              ),
            ),
    );
  }
}
