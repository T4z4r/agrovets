// lib/screens/suppliers/supplier_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/supplier.dart';
import 'supplier_form_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  List<Supplier> _suppliers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final res = await ApiService.get('/api/suppliers');
      setState(() {
        _suppliers =
            (res['data'] as List).map((s) => Supplier.fromJson(s)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteSupplier(int id) async {
    try {
      await ApiService.delete('/api/suppliers/$id');
      _loadSuppliers();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        SupplierFormScreen(onSave: _loadSuppliers))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _suppliers.length,
              itemBuilder: (ctx, i) {
                final s = _suppliers[i];
                return ListTile(
                  title: Text(s.name),
                  subtitle: Text(s.phone ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => SupplierFormScreen(
                                    supplier: s, onSave: _loadSuppliers))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteSupplier(s.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
