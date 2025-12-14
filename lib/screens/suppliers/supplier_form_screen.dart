// lib/screens/suppliers/supplier_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../services/api_service.dart';
import '../../models/supplier.dart';
import '../../widgets/app_drawer.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await ApiService.put('/api/suppliers/${widget.supplier!.id}', data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save supplier: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _save,
          ),
        ),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
            Text(widget.supplier == null ? 'Create Supplier' : 'Edit Supplier'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Supplier Icon Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.supplier == null ? Icons.business : Icons.edit,
                  size: 40,
                  color: Colors.green[600],
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
                        widget.supplier == null
                            ? 'Add New Supplier'
                            : 'Edit Supplier',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Supplier Name Field
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Supplier Name',
                          hintText: 'Enter supplier name',
                          prefixIcon: const Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Supplier name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contact Person Field
                      TextFormField(
                        controller: _contactCtrl,
                        decoration: InputDecoration(
                          labelText: 'Contact Person',
                          hintText: 'Enter contact person name',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: 'Enter phone number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter email address',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address Field
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter supplier address',
                          prefixIcon: const Icon(Icons.location_on),
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
                                widget.supplier == null
                                    ? 'Create Supplier'
                                    : 'Update Supplier',
                                style: const TextStyle(
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
