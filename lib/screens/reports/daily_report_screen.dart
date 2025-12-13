// lib/screens/reports/daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../models/report.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DailyReport? _report;
  DateTime _date = DateTime.now();
  bool _loading = false;

  Future<void> _loadReport() async {
    setState(() => _loading = true);
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      final res = await ApiService.get('/api/reports/daily/$dateStr');
      setState(() => _report = DailyReport.fromJson(res['data']));
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
    if (picked != null) {
      setState(() => _date = picked);
      _loadReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Select Date'),
              onTap: _selectDate,
              controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_date)),
            ),
            const SizedBox(height: 20),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_report != null) ...[
              Text('Total Sales: ${_report!.totalSales}'),
              Text('Total Expenses: ${_report!.totalExpenses}'),
              // Add lists for sales and expenses if needed
            ],
          ],
        ),
      ),
    );
  }
}
