// lib/screens/seller/seller_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
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
  bool _isLoading = true;
  SellerDaySummary? report;
  Map<String, bool> _cardVisibility = {};

  @override
  void initState() {
    super.initState();
    _cardVisibility = {
      'totalProducts': false,
      'todaySales': false,
      'totalSales': false,
      'totalExpenses': false,
      'stockValue': false,
      'lowStockProducts': false,
      'reportValues': false,
    };
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadDashboard();
    await _loadReport();
    setState(() => _isLoading = false);
  }

  Future<void> _loadDashboard() async {
    try {
      final res = await ApiService.get('/api/reports/dashboard');
      setState(() => dashboard = res['data'] ?? {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadDashboard}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadReport() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    try {
      final res = await ApiService.get('/api/reports/seller/day-summary');
      setState(() => report = SellerDaySummary.fromJson(res['data'] ?? {}));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${AppLocalizations.of(context)!.failedLoadReport}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.waving_hand,
                          size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.goodDay,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              AppLocalizations.of(context)!.businessOverview,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                      child: SpinKitWaveSpinner(
                          color: Theme.of(context).colorScheme.primary,
                          size: 50.0)),
                )
              else
                Column(
                  children: [
                    // ================= Stats =================
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.25,
                      children: [
                        _statCard(
                            AppLocalizations.of(context)!.totalProducts,
                            dashboard['total_products']?.toString() ?? '0',
                            Icons.inventory,
                            Colors.blue,
                            'totalProducts'),
                        _statCard(
                            AppLocalizations.of(context)!.lowStockProducts,
                            (dashboard['low_stock_products_count'] as num?)
                                    ?.toString() ??
                                '0',
                            Icons.warning,
                            Colors.red,
                            'lowStockProducts'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _statCardFullWidth(
                        AppLocalizations.of(context)!.todaySales,
                        NumberFormatter.formatCurrency(num.tryParse(
                            dashboard['today_sales']?.toString() ?? '0')),
                        Icons.inventory,
                        Theme.of(context).primaryColor,
                        'todaySales'),

                    // Seller Day Summary
                    const SizedBox(height: 16),
                    if (report != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Card(
                          color: const Color.fromARGB(255, 255, 214, 214)
                              .withOpacity(0.5),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.2)),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final screenWidth =
                                        MediaQuery.of(context).size.width;
                                    final isSmallScreen = screenWidth < 600;
                                    return SingleChildScrollView(
                                      scrollDirection: isSmallScreen
                                          ? Axis.horizontal
                                          : Axis.vertical,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: isSmallScreen
                                              ? 300
                                              : constraints.maxWidth,
                                        ),
                                        child: DataTable(
                                          columnSpacing: isSmallScreen ? 20 : 50,
                                          columns: [
                                            DataColumn(
                                              label: Text(
                                                AppLocalizations.of(context)!
                                                    .category,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            DataColumn(
                                              label: Text(
                                                AppLocalizations.of(context)!
                                                    .amount,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                          rows: [
                                            DataRow(cells: [
                                              DataCell(Text(
                                                  AppLocalizations.of(context)!
                                                      .totalSalesLabel)),
                                              DataCell(Text(_cardVisibility[
                                                      'reportValues']!
                                                  ? NumberFormatter
                                                      .formatCurrency(
                                                          report!.totalSales)
                                                  : '****')),
                                            ]),
                                            DataRow(cells: [
                                              DataCell(Text(
                                                  AppLocalizations.of(context)!
                                                      .totalExpensesLabel)),
                                              DataCell(Text(_cardVisibility[
                                                      'reportValues']!
                                                  ? NumberFormatter
                                                      .formatCurrency(
                                                          report!.totalExpenses)
                                                  : '****')),
                                            ]),
                                            DataRow(cells: [
                                              DataCell(Text(
                                                  AppLocalizations.of(context)!
                                                      .netProfit)),
                                              DataCell(
                                                Text(
                                                  _cardVisibility['reportValues']!
                                                      ? NumberFormatter
                                                          .formatCurrency(report!
                                                                  .totalSales -
                                                              report!
                                                                  .totalExpenses)
                                                      : '****',
                                                  style: _cardVisibility[
                                                          'reportValues']!
                                                      ? TextStyle(
                                                          color: (report!.totalSales -
                                                                      report!
                                                                          .totalExpenses) >=
                                                                  0
                                                              ? Theme.of(context)
                                                                  .colorScheme
                                                                  .primary
                                                              : Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                            ]),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    _cardVisibility['reportValues']!
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(() =>
                                      _cardVisibility['reportValues'] =
                                          !_cardVisibility['reportValues']!),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Widgets =================

  Widget _statCard(
      String title, String value, IconData icon, Color color, String key) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  _cardVisibility[key]! ? value : '****',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  _cardVisibility[key]!
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onPressed: () => setState(
                    () => _cardVisibility[key] = !_cardVisibility[key]!),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCardFullWidth(
      String title, String value, IconData icon, Color color, String key) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    _cardVisibility[key]! ? value : '****',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _cardVisibility[key]! ? Icons.visibility : Icons.visibility_off,
                size: 16,
                color: Colors.grey[600],
              ),
              onPressed: () =>
                  setState(() => _cardVisibility[key] = !_cardVisibility[key]!),
            ),
          ],
        ),
      ),
    );
  }
}
