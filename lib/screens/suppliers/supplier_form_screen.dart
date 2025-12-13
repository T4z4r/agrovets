// lib/screens/suppliers/supplier_form_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/supplier.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;
  final VoidCallback onSave;

  const SupplierFormScreen({super.key, this.supplier, required this.onSave});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.supplier?.name ?? '');
    _contactCtrl =
        TextEditingController(text: widget.supplier?.contactPerson ?? '');
    _phoneCtrl = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.supplier?.email ?? '');
    _addressCtrl = TextEditingController(text: widget.supplier?.address ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'name': _nameCtrl.text,
      'contact_person': _contactCtrl.text,
      'phone': _phoneCtrl.text,
      'email': _emailCtrl.text,
      'address': _addressCtrl.text,
    };
    try {
      if (widget.supplier == null) {
        await ApiService.post('/api/suppliers', data);
      } else {
        await ApiService.put('/api/suppliers/${widget.supplier!.id}', data);
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
          title: Text(
              widget.supplier == null ? 'Create Supplier' : 'Edit Supplier')),
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
                  controller: _contactCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Contact Person')),
              TextFormField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone')),
              TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email')),
              TextFormField(
                  controller: _addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address')),
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
