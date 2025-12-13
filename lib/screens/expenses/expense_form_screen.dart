// lib/screens/expenses/expense_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/expense.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  final VoidCallback onSave;

  const ExpenseFormScreen({super.key, this.expense, required this.onSave});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categoryCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;
  DateTime _date = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _categoryCtrl = TextEditingController(text: widget.expense?.category ?? '');
    _amountCtrl =
        TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _descriptionCtrl =
        TextEditingController(text: widget.expense?.description ?? '');
    if (widget.expense != null) _date = DateTime.parse(widget.expense!.date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'category': _categoryCtrl.text,
      'amount': int.parse(_amountCtrl.text),
      'description': _descriptionCtrl.text,
      'date': DateFormat('yyyy-MM-dd').format(_date),
    };
    try {
      if (widget.expense == null) {
        await ApiService.post('/api/expenses', data);
      } else {
        await ApiService.put('/api/expenses/${widget.expense!.id}', data);
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
      appBar: AppBar(
          title:
              Text(widget.expense == null ? 'Create Expense' : 'Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: _categoryCtrl,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description')),
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: _selectDate,
                controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(_date)),
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
