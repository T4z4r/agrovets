// lib/screens/seller/seller_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/report.dart';
import '../../utils/number_formatter.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  Map<String, dynamic> dashboard = {};
  bool _loading = false;
  SellerDaySummary? report;
  bool _reportLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadReport();
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/api/reports/dashboard');
      setState(() => dashboard = res['data'] ?? {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load dashboard: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _loadReport() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    setState(() => _reportLoading = true);
    try {
      final res = await ApiService.get('/api/reports/seller/day-summary');
      setState(() => report = SellerDaySummary.fromJson(res['data'] ?? {}));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _reportLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDashboard();
          await _loadReport();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.waving_hand, size: 40, color: Colors.white),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good Day!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              'Here’s your business overview',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ================= Stats =================
              if (_loading)
                Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child:
                          SpinKitWaveSpinner(color: Colors.green, size: 50.0)),
                )
              else
                Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.25,
                      children: [
                        _statCard(
                            'Total Products',
                            dashboard['total_products']?.toString() ?? '0',
                            Icons.inventory,
                            Colors.blue),
                        _statCard(
                            'Today Sales',
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['today_sales']?.toString() ?? '0')),
                            Icons.trending_up,
                            Colors.green),
                        _statCard(
                            'Total Sales',
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['total_sales']?.toString() ?? '0')),
                            Icons.monetization_on,
                            Colors.orange),
                        _statCard(
                            'Total Expenses',
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['total_expenses']?.toString() ??
                                    '0')),
                            Icons.money_off,
                            Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              const SizedBox(height: 24),

              // Seller Day Summary
              Text(
                'Seller Day Summary',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
              ),
              const SizedBox(height: 16),
              if (_reportLoading)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                      child:
                          SpinKitWaveSpinner(color: Colors.green, size: 50.0)),
                )
              else if (report != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columnSpacing: 150, // Spread columns to cover full width
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Amount',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Total Sales')),
                          DataCell(Text(NumberFormatter.formatCurrency(
                              report!.totalSales))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Total Expenses')),
                          DataCell(Text(NumberFormatter.formatCurrency(
                              report!.totalExpenses))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Net Profit')),
                          DataCell(
                            Text(
                              NumberFormatter.formatCurrency(
                                  report!.totalSales - report!.totalExpenses),
                              style: TextStyle(
                                color: (report!.totalSales -
                                            report!.totalExpenses) >=
                                        0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
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

  // ================= Widgets =================

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCardFullWidth(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
