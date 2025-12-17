// lib/screens/expenses/expense_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/expense.dart';
import '../../widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';

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
      'amount': double.parse(_amountCtrl.text),
      'description': _descriptionCtrl.text,
      'date': DateFormat('yyyy-MM-dd').format(_date),
    };
    try {
      if (widget.expense == null) {
        await ApiService.post('/api/expenses', data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.expenseCreated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        await ApiService.put('/api/expenses/${widget.expense!.id}', data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.expenseUpdated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedSaveExpense}: $e'),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.expense == null
            ? AppLocalizations.of(context)!.createExpense
            : AppLocalizations.of(context)!.editExpense),
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
              // Expense Icon Header
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.expense == null ? Icons.money_off : Icons.edit,
                  size: 40,
                  color: Colors.red[600],
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
                        widget.expense == null
                            ? AppLocalizations.of(context)!.addNewExpense
                            : AppLocalizations.of(context)!.editExpense,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Category Field
                      TextFormField(
                        controller: _categoryCtrl,
                        decoration: InputDecoration(
                          labelText:
                              AppLocalizations.of(context)!.expenseCategory,
                          hintText: AppLocalizations.of(context)!
                              .enterExpenseCategory,
                          prefixIcon: const Icon(Icons.category),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!
                                .categoryRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Amount Field
                      TextFormField(
                        controller: _amountCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.amount,
                          hintText:
                              AppLocalizations.of(context)!.enterExpenseAmount,
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return AppLocalizations.of(context)!.amountRequired;
                          }
                          if (double.tryParse(v) == null) {
                            return AppLocalizations.of(context)!
                                .enterValidAmount;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.description,
                          hintText: AppLocalizations.of(context)!
                              .enterExpenseDescription,
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Date Field
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.expenseDate,
                          hintText: AppLocalizations.of(context)!.selectDate,
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onTap: _selectDate,
                        initialValue: DateFormat('yyyy-MM-dd').format(_date),
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
                                widget.expense == null
                                    ? AppLocalizations.of(context)!
                                        .createExpense
                                    : AppLocalizations.of(context)!
                                        .updateExpense,
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
