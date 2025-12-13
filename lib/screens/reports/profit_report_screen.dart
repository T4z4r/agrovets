// lib/screens/reports/profit_report_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/report.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  ProfitReport? _report;
  DateTime _start = DateTime.now().subtract(const Duration(days: 30));
  DateTime _end = DateTime.now();
  bool _loading = false;

  Future<void> _loadReport() async {
    setState(() => _loading = true);
    try {
      final startStr = DateFormat('yyyy-MM-dd').format(_start);
      final endStr = DateFormat('yyyy-MM-dd').format(_end);
      final res = await ApiService.get('/api/reports/profit/$startStr/$endStr');
      setState(() => _report = ProfitReport.fromJson(res['data']));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _loading = false);
  }

  Future<void> _selectStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _start = picked);
      _loadReport();
    }
  }

  Future<void> _selectEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _end = picked);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profit Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Start Date'),
              onTap: _selectStart,
              controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_start)),
            ),
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'End Date'),
              onTap: _selectEnd,
              controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_end)),
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_report != null) ...[
              Text('Revenue: ${_report!.revenue}'),
              Text('Cost: ${_report!.cost}'),
              Text('Profit: ${_report!.profit}'),
            ],
          ],
        ),
      ),
    );
  }
}
