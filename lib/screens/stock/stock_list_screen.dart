// lib/screens/stock/stock_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/stock_transaction.dart';
import 'stock_form_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<StockTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final res = await ApiService.get('/api/stock');
      setState(() {
        _transactions = (res['data'] as List).map((t) => StockTransaction.fromJson(t)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await ApiService.delete('/api/stock/$id');
      _loadTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StockFormScreen(onSave: _loadTransactions))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (ctx, i) {
                final t = _transactions[i];
                return ListTile(
                  title: Text(t.type),
                  subtitle: Text('Quantity: ${t.quantity} | Date: ${t.date}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTransaction(t.id),
                  ),
                );
              },
            ),
    );
  }
}