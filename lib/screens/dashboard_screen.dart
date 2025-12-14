import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'products/product_list_screen.dart';
import 'suppliers/supplier_list_screen.dart';
import 'stock/stock_list_screen.dart';
import 'sales/sale_list_screen.dart';
import 'expenses/expense_list_screen.dart';
import 'reports/daily_report_screen.dart';

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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('AgroVet Dashboard'),
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
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
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
                  const Text(
                    'Welcome!',
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
                Icons.dashboard, 'Dashboard', () => Navigator.pop(context)),
            _drawerTile(Icons.inventory, 'Products', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProductListScreen()));
            }),
            _drawerTile(Icons.people, 'Suppliers', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SupplierListScreen()));
            }),
            _drawerTile(Icons.storage, 'Stock', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const StockListScreen()));
            }),
            _drawerTile(Icons.point_of_sale, 'Sales', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SaleListScreen()));
            }),
            _drawerTile(Icons.money_off, 'Expenses', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ExpenseListScreen()));
            }),
            _drawerTile(Icons.bar_chart, 'Reports', () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DailyReportScreen()));
            }),
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
                            'Tsh ${dashboard['today_sales'] ?? 0}',
                            Icons.trending_up,
                            Colors.green),
                        _statCard(
                            'Total Sales',
                            'Tsh ${dashboard['total_sales'] ?? 0}',
                            Icons.monetization_on,
                            Colors.orange),
                        _statCard(
                            'Total Expenses',
                            'Tsh ${dashboard['total_expenses'] ?? 0}',
                            Icons.money_off,
                            Colors.red),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _statCardFullWidth(
                        'Stock Value',
                        'Tsh ${dashboard['stock_value'] ?? 0}',
                        Icons.warehouse,
                        Colors.green),
                  ],
                ),

              const SizedBox(height: 24),

              // ================= Quick Actions =================
              Text(
                'Quick Actions',
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
                      'Add Product',
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
                      'New Sale',
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

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // 👈 important
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12), // tighter bottom
        child: Column(
          mainAxisSize: MainAxisSize.min, // 👈 prevents stretch overflow
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(height: 8),

            // Value (scales safely)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  height: 1.1, // 👈 fixes font descent overflow
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey[600],
                height: 1.1, // 👈 critical
              ),
            ),
          ],
        ),
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
