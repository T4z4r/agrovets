import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import '../../models/general_debt.dart';
import '../../services/api_service.dart';
import '../../utils/number_formatter.dart';
import '../../widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';

class GeneralDebtListScreen extends StatefulWidget {
  final bool embedded;

  const GeneralDebtListScreen({super.key, this.embedded = false});

  @override
  State<GeneralDebtListScreen> createState() => _GeneralDebtListScreenState();
}

class _GeneralDebtListScreenState extends State<GeneralDebtListScreen> {
  List<GeneralDebt> _debts = [];
  List<GeneralDebt> _filteredDebts = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDebts();
  }

  Future<void> _loadDebts() async {
    try {
      final res = await ApiService.get('/api/general-debts');
      final debts = (res['data'] as List)
          .map((debt) => GeneralDebt.fromJson(debt))
          .toList();
      setState(() {
        _debts = debts;
        _filteredDebts = _applyFilter(debts, _searchQuery);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  List<GeneralDebt> _applyFilter(List<GeneralDebt> debts, String query) {
    if (query.isEmpty) return debts;
    final lowerQuery = query.toLowerCase();
    return debts.where((debt) {
      return debt.debtorName.toLowerCase().contains(lowerQuery) ||
          (debt.debtorPhone?.toLowerCase().contains(lowerQuery) ?? false) ||
          (debt.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          debt.status.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void _filterDebts(String query) {
    setState(() {
      _searchQuery = query;
      _filteredDebts = _applyFilter(_debts, query);
    });
  }

  Future<void> _openDebtForm([GeneralDebt? debt]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeneralDebtFormScreen(
          debt: debt,
          onSave: _loadDebts,
        ),
      ),
    );
  }

  Future<void> _deleteDebt(GeneralDebt debt) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDebt),
        content: Text(l10n.deleteDebtConfirm(debt.debtorName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ApiService.delete('/api/general-debts/${debt.id}');
      await _loadDebts();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showDebtDetails(GeneralDebt debt) async {
    try {
      final res = await ApiService.get('/api/general-debts/${debt.id}');
      final freshDebt = GeneralDebt.fromJson(res['data']);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _DebtDetailsSheet(
          debt: freshDebt,
          onChanged: _loadDebts,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _localizedStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status.toLowerCase()) {
      case 'paid':
        return l10n.paid;
      case 'partial':
        return l10n.partial;
      default:
        return l10n.unpaid;
    }
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            onChanged: _filterDebts,
            decoration: InputDecoration(
              hintText: l10n.searchDebts,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? Center(
                  child: SpinKitWaveSpinner(
                    color: Theme.of(context).primaryColor,
                    size: 50,
                  ),
                )
              : _filteredDebts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? l10n.noDebtsFound
                                : l10n.noDebtsMatch,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDebts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _filteredDebts.length,
                        itemBuilder: (context, index) {
                          final debt = _filteredDebts[index];
                          final statusColor = _statusColor(debt.status);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              onTap: () => _showDebtDetails(debt),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  color: statusColor,
                                ),
                              ),
                              title: Text(
                                debt.debtorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 4,
                                    children: [
                                      _MetaText(
                                        icon: Icons.payments,
                                        text:
                                            '${l10n.balance}: ${NumberFormatter.formatCurrency(debt.balance)}',
                                      ),
                                      _MetaText(
                                        icon: Icons.check_circle_outline,
                                        text:
                                            '${l10n.paid}: ${NumberFormatter.formatCurrency(debt.amountPaid)}',
                                      ),
                                      _MetaText(
                                        icon: Icons.calendar_today,
                                        text: debt.debtDate,
                                      ),
                                    ],
                                  ),
                                  if (debt.description != null &&
                                      debt.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      debt.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Chip(
                                    label: Text(
                                      _localizedStatus(context, debt.status)
                                          .toUpperCase(),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                    visualDensity: VisualDensity.compact,
                                    backgroundColor: statusColor,
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'payment') {
                                    _showPaymentDialog(
                                      context,
                                      debt,
                                      onSave: _loadDebts,
                                    );
                                  } else if (value == 'edit') {
                                    _openDebtForm(debt);
                                  } else if (value == 'delete') {
                                    _deleteDebt(debt);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'payment',
                                    child: ListTile(
                                      leading: const Icon(Icons.add_card),
                                      title: Text(l10n.recordPayment),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: Text(l10n.edit),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: const Icon(Icons.delete,
                                          color: Colors.red),
                                      title: Text(
                                        l10n.delete,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(AppLocalizations.of(context)!.debts),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadDebts,
                ),
              ],
            ),
      drawer: widget.embedded ? null : const AppDrawer(activeScreen: 'debts'),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDebtForm(),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class GeneralDebtFormScreen extends StatefulWidget {
  final GeneralDebt? debt;
  final VoidCallback onSave;

  const GeneralDebtFormScreen({super.key, this.debt, required this.onSave});

  @override
  State<GeneralDebtFormScreen> createState() => _GeneralDebtFormScreenState();
}

class _GeneralDebtFormScreenState extends State<GeneralDebtFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _amountCtrl;
  DateTime _debtDate = DateTime.now();
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final debt = widget.debt;
    _nameCtrl = TextEditingController(text: debt?.debtorName ?? '');
    _phoneCtrl = TextEditingController(text: debt?.debtorPhone ?? '');
    _emailCtrl = TextEditingController(text: debt?.debtorEmail ?? '');
    _descriptionCtrl = TextEditingController(text: debt?.description ?? '');
    _amountCtrl = TextEditingController(text: debt?.amount.toString() ?? '');
    if (debt != null && debt.debtDate.isNotEmpty) {
      _debtDate = DateTime.parse(debt.debtDate);
    }
    if (debt?.dueDate != null && debt!.dueDate!.isNotEmpty) {
      _dueDate = DateTime.parse(debt.dueDate!);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _descriptionCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate({required bool dueDate}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ? (_dueDate ?? _debtDate) : _debtDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (dueDate) {
        _dueDate = picked;
      } else {
        _debtDate = picked;
        if (_dueDate != null && _dueDate!.isBefore(_debtDate)) {
          _dueDate = _debtDate;
        }
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final data = {
      'debtor_name': _nameCtrl.text.trim(),
      'debtor_phone': _phoneCtrl.text.trim(),
      'debtor_email': _emailCtrl.text.trim(),
      'description': _descriptionCtrl.text.trim(),
      'amount': double.parse(_amountCtrl.text),
      'debt_date': DateFormat('yyyy-MM-dd').format(_debtDate),
      'due_date': _dueDate == null
          ? null
          : DateFormat('yyyy-MM-dd').format(_dueDate!),
    };

    try {
      if (widget.debt == null) {
        await ApiService.post('/api/general-debts', data);
      } else {
        await ApiService.put('/api/general-debts/${widget.debt!.id}', data);
      }
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = widget.debt == null ? l10n.createDebt : l10n.editDebt;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  widget.debt == null
                      ? Icons.account_balance_wallet
                      : Icons.edit,
                  size: 40,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 24),
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
                        widget.debt == null ? l10n.addNewDebt : l10n.editDebt,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _DebtTextField(
                        controller: _nameCtrl,
                        labelText: l10n.debtorName,
                        hintText: l10n.enterDebtorName,
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.debtorNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        controller: _phoneCtrl,
                        labelText: l10n.phoneNumber,
                        hintText: l10n.enterPhoneNumber,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        controller: _emailCtrl,
                        labelText: l10n.emailAddress,
                        hintText: l10n.enterEmailAddress,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        controller: _amountCtrl,
                        labelText: l10n.amount,
                        hintText: l10n.enterDebtAmount,
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          if (amount == null || amount <= 0) {
                            return l10n.enterValidAmount;
                          }
                          if (widget.debt != null &&
                              amount < widget.debt!.amountPaid) {
                            return l10n.amountBelowPaid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        readOnly: true,
                        labelText: l10n.debtDate,
                        hintText: l10n.selectDate,
                        icon: Icons.calendar_today,
                        controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(_debtDate),
                        ),
                        onTap: () => _selectDate(dueDate: false),
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        readOnly: true,
                        labelText: l10n.dueDate,
                        hintText: l10n.selectDate,
                        icon: Icons.event_available,
                        suffixIcon: _dueDate == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _dueDate = null),
                              ),
                        controller: TextEditingController(
                          text: _dueDate == null
                              ? ''
                              : DateFormat('yyyy-MM-dd').format(_dueDate!),
                        ),
                        onTap: () => _selectDate(dueDate: true),
                        validator: (_) {
                          if (_dueDate != null &&
                              _dueDate!.isBefore(_debtDate)) {
                            return l10n.dueDateAfterDebtDate;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _DebtTextField(
                        controller: _descriptionCtrl,
                        labelText: l10n.description,
                        hintText: l10n.enterDebtDescription,
                        icon: Icons.description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
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
                                  color: Colors.white,
                                  size: 20,
                                ),
                              )
                            : Text(
                                widget.debt == null
                                    ? l10n.createDebt
                                    : l10n.updateDebt,
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

class _DebtDetailsSheet extends StatelessWidget {
  final GeneralDebt debt;
  final VoidCallback onChanged;

  const _DebtDetailsSheet({required this.debt, required this.onChanged});

  Future<void> _deletePayment(
    BuildContext context,
    GeneralDebtPayment payment,
  ) async {
    try {
      await ApiService.delete(
        '/api/general-debts/${debt.id}/payments/${payment.id}',
      );
      onChanged();
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        debt.debtorName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SummaryChip(
                      label: l10n.amountLabel,
                      value: NumberFormatter.formatCurrency(debt.amount),
                    ),
                    _SummaryChip(
                      label: l10n.paid,
                      value: NumberFormatter.formatCurrency(debt.amountPaid),
                    ),
                    _SummaryChip(
                      label: l10n.balance,
                      value: NumberFormatter.formatCurrency(debt.balance),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: debt.balance <= 0
                      ? null
                      : () => _showPaymentDialog(
                            context,
                            debt,
                            onSave: onChanged,
                          ),
                  icon: const Icon(Icons.add_card),
                  label: Text(l10n.recordPayment),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.paymentHistory,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (debt.payments.isEmpty)
                  Text(
                    l10n.noPaymentsRecorded,
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  ...debt.payments.map(
                    (payment) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long),
                      title: Text(NumberFormatter.formatCurrency(payment.amount)),
                      subtitle: Text(
                        [
                          payment.paymentDate,
                          if (payment.paymentMethod != null &&
                              payment.paymentMethod!.isNotEmpty)
                            payment.paymentMethod!,
                          if (payment.notes != null && payment.notes!.isNotEmpty)
                            payment.notes!,
                        ].join(' - '),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletePayment(context, payment),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> _showPaymentDialog(
  BuildContext context,
  GeneralDebt debt, {
  required VoidCallback onSave,
}) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _PaymentDialog(debt: debt, onSave: onSave),
  );
}

class _PaymentDialog extends StatefulWidget {
  final GeneralDebt debt;
  final VoidCallback onSave;

  const _PaymentDialog({required this.debt, required this.onSave});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _methodCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.post('/api/general-debts/${widget.debt.id}/payments', {
        'amount': double.parse(_amountCtrl.text),
        'payment_date': DateFormat('yyyy-MM-dd').format(_paymentDate),
        'payment_method': _methodCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      });
      widget.onSave();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.recordPayment),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentAmountMax(
                    NumberFormatter.formatCurrency(widget.debt.balance),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) {
                    return l10n.enterValidAmount;
                  }
                  if (amount > widget.debt.balance) {
                    return l10n.paymentExceedsBalance;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(labelText: l10n.paymentDate),
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_paymentDate),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _methodCtrl,
                decoration: InputDecoration(labelText: l10n.paymentMethod),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }
}

class _DebtTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final int maxLines;

  const _DebtTextField({
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }
}
