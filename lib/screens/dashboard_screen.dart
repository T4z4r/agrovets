import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../services/api_service.dart';
import '../utils/number_formatter.dart';
import 'auth/login_screen.dart';
import 'products/product_list_screen.dart';
import 'suppliers/supplier_list_screen.dart';
import 'stock/stock_list_screen.dart';
import 'sales/sale_list_screen.dart';
import 'expenses/expense_list_screen.dart';
import 'reports/daily_report_screen.dart';
import 'sellers/seller_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic> dashboard = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appName +
            ' ' +
            AppLocalizations.of(context)!.dashboard),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                  title: Text(
                    AppLocalizations.of(context)!.confirmLogout,
                    style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.logoutMessage,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  actionsPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[600]),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold)),
                      child: Text(AppLocalizations.of(context)!.logout),
                    ),
                  ],
                ),
              );
              if (shouldLogout == true) {
                await auth.logout();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),

      // ================= Drawer =================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              color: Colors.green[600],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child:
                        Icon(Icons.person, size: 40, color: Colors.green[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context)!.welcome,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    auth.user?['name'] ?? 'User',
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            _drawerTile(
                Icons.dashboard,
                AppLocalizations.of(context)!.dashboard,
                () => Navigator.pop(context),
                isActive: true),
            _drawerTile(Icons.inventory, AppLocalizations.of(context)!.products,
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()));
            }),
            _drawerTile(Icons.people, AppLocalizations.of(context)!.suppliers,
                () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SupplierListScreen()));
            }),
            if (auth.isOwner || auth.isAdmin || auth.isSeller)
              _drawerTile(Icons.person, AppLocalizations.of(context)!.sellers,
                  () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SellerListScreen()));
              }, isActive: false),
            _drawerTile(Icons.storage, AppLocalizations.of(context)!.stock, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StockListScreen()));
            }),
            _drawerTile(
                Icons.point_of_sale, AppLocalizations.of(context)!.sales, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SaleListScreen()));
            }),
            _drawerTile(Icons.money_off, AppLocalizations.of(context)!.expenses,
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
            }),
            _drawerTile(Icons.bar_chart, AppLocalizations.of(context)!.reports,
                () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DailyReportScreen()));
            }),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localeProvider.locale.languageCode == 'en'
                        ? 'Language'
                        : 'Lugha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => localeProvider.setLocale(const Locale('en')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: localeProvider.locale.languageCode == 'en'
                                ? Colors.blue[700]
                                : Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('English'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => localeProvider.setLocale(const Locale('sw')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: localeProvider.locale.languageCode == 'sw'
                                ? Colors.green[700]
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Kiswahili'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= Body =================
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
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
                    children: [
                      const Icon(Icons.waving_hand,
                          size: 40, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.goodDay,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              AppLocalizations.of(context)!.businessOverview,
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
                            AppLocalizations.of(context)!.totalProducts,
                            dashboard['total_products']?.toString() ?? '0',
                            Icons.inventory,
                            Colors.blue),
                        _statCard(
                            AppLocalizations.of(context)!.todaySales,
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['today_sales']?.toString() ?? '0')),
                            Icons.trending_up,
                            Colors.green),
                        _statCard(
                            AppLocalizations.of(context)!.totalSales,
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['total_sales']?.toString() ?? '0')),
                            Icons.monetization_on,
                            Colors.orange),
                        _statCard(
                            AppLocalizations.of(context)!.totalExpenses,
                            NumberFormatter.formatCurrency(num.tryParse(
                                dashboard['total_expenses']?.toString() ??
                                    '0')),
                            Icons.money_off,
                            Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _statCardFullWidth(
                        AppLocalizations.of(context)!.stockValue,
                        NumberFormatter.formatCurrency(num.tryParse(
                            dashboard['stock_value']?.toString() ?? '0')),
                        Icons.warehouse,
                        Colors.green),
                  ],
                ),

              const SizedBox(height: 24),

              // ================= Quick Actions =================
              Text(
                AppLocalizations.of(context)!.quickActions,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      AppLocalizations.of(context)!.addProduct,
                      Icons.add_box,
                      Colors.blue,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProductListScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickActionCard(
                      AppLocalizations.of(context)!.newSale,
                      Icons.point_of_sale,
                      Colors.green,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SaleListScreen())),
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

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap,
      {bool isActive = false}) {
    return Container(
      color: isActive ? Colors.green[50] : null,
      child: ListTile(
        leading:
            Icon(icon, color: isActive ? Colors.green[700] : Colors.green[600]),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.green[700] : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

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

  Widget _quickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
