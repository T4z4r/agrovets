// lib/screens/stock/stock_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';
import '../../models/supplier.dart';

class StockFormScreen extends StatefulWidget {
  final VoidCallback onSave;

  const StockFormScreen({super.key, required this.onSave});

  @override
  State<StockFormScreen> createState() => _StockFormScreenState();
}

class _StockFormScreenState extends State<StockFormScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadData();
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
      appBar: AppBar(title: const Text('Create Stock Transaction')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _productId,
                      hint: const Text('Select Product'),
                      items: _products
                          .map((p) => DropdownMenuItem(
                              value: p.id, child: Text(p.name!)))
                          .toList(),
                      onChanged: (v) => setState(() => _productId = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(
                            value: 'stock_in', child: Text('Stock In')),
                        DropdownMenuItem(
                            value: 'stock_out', child: Text('Stock Out')),
                        DropdownMenuItem(
                            value: 'damage', child: Text('Damage')),
                        DropdownMenuItem(
                            value: 'return', child: Text('Return')),
                      ],
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    TextFormField(
                      onChanged: (v) => _quantity = int.tryParse(v),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    DropdownButtonFormField<int>(
                      value: _supplierId,
                      hint: const Text('Select Supplier (optional)'),
                      items: _suppliers
                          .map((s) => DropdownMenuItem(
                              value: s.id, child: Text(s.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _supplierId = v),
                    ),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Date'),
                      onTap: _selectDate,
                      controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(_date)),
                    ),
                    TextFormField(
                      onChanged: (v) => _remarks = v,
                      decoration: const InputDecoration(labelText: 'Remarks'),
                    ),
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
