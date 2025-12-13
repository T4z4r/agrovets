// lib/screens/sales/sale_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/sale.dart';
import 'sale_form_screen.dart';
import 'receipt_view_screen.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});

  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  List<Sale> _sales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    try {
      final res = await ApiService.get('/api/sales');
      setState(() {
        _sales = (res['data'] as List).map((s) => Sale.fromJson(s)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SaleFormScreen(onSave: _loadSales))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _sales.length,
              itemBuilder: (ctx, i) {
                final s = _sales[i];
                return ListTile(
                  title: Text('Sale #${s.id}'),
                  subtitle:
                      Text('Date: ${s.saleDate} | Items: ${s.items.length}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.receipt),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReceiptViewScreen(saleId: s.id))),
                  ),
                );
              },
            ),
    );
  }
}
