// lib/screens/products/product_form_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback onSave;

  const ProductFormScreen({super.key, this.product, required this.onSave});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _categoryCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _sellingPriceCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _unitCtrl = TextEditingController(text: widget.product?.unit ?? '');
    _categoryCtrl = TextEditingController(text: widget.product?.category ?? '');
    _stockCtrl =
        TextEditingController(text: widget.product?.stock.toString() ?? '');
    _costPriceCtrl =
        TextEditingController(text: widget.product?.costPrice.toString() ?? '');
    _sellingPriceCtrl = TextEditingController(
        text: widget.product?.sellingPrice.toString() ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'name': _nameCtrl.text,
      'unit': _unitCtrl.text,
      'category': _categoryCtrl.text,
      'stock': int.parse(_stockCtrl.text),
      'cost_price': int.parse(_costPriceCtrl.text),
      'selling_price': int.parse(_sellingPriceCtrl.text),
    };
    try {
      if (widget.product == null) {
        await ApiService.post('/api/products', data);
      } else {
        await ApiService.put('/api/products/${widget.product!.id}', data);
      }
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.product == null ? 'Create Product' : 'Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _unitCtrl,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _stockCtrl,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _costPriceCtrl,
                  decoration: const InputDecoration(labelText: 'Cost Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _sellingPriceCtrl,
                  decoration: const InputDecoration(labelText: 'Selling Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
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
