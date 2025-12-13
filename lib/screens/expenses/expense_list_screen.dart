// lib/screens/expenses/expense_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/expense.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final res = await ApiService.get('/api/expenses');
      setState(() {
        _expenses =
            (res['data'] as List).map((e) => Expense.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteExpense(int id) async {
    try {
      await ApiService.delete('/api/expenses/$id');
      _loadExpenses();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ExpenseFormScreen(onSave: _loadExpenses))),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (ctx, i) {
                final e = _expenses[i];
                return ListTile(
                  title: Text(e.category),
                  subtitle: Text('Amount: ${e.amount} | Date: ${e.date}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ExpenseFormScreen(
                                    expense: e, onSave: _loadExpenses))),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteExpense(e.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
