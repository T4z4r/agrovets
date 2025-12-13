import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final res = await ApiService.get('/api/reports/dashboard');
      setState(() => dashboard = res['data']);
    } catch (e) {
      // handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgroVet Dashboard'),
        actions: [
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
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(child: Text('Hello, ${auth.user?['name'] ?? ''}')),
            ListTile(
                title: const Text('Dashboard'),
                leading: const Icon(Icons.dashboard),
                onTap: () => Navigator.pop(context)),
            ListTile(
                title: const Text('Products'),
                leading: const Icon(Icons.inventory),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductListScreen()))),
            ListTile(
                title: const Text('Suppliers'),
                leading: const Icon(Icons.people),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SupplierListScreen()))),
            ListTile(
                title: const Text('Stock'),
                leading: const Icon(Icons.storage),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StockListScreen()))),
            ListTile(
                title: const Text('Sales'),
                leading: const Icon(Icons.point_of_sale),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SaleListScreen()))),
            ListTile(
                title: const Text('Expenses'),
                leading: const Icon(Icons.money_off),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ExpenseListScreen()))),
            ListTile(
                title: const Text('Reports'),
                leading: const Icon(Icons.bar_chart),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DailyReportScreen()))),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _card('Total Products',
                dashboard['total_products']?.toString() ?? '-'),
            _card('Today Sales', 'KES ${dashboard['today_sales'] ?? 0}'),
            _card('Total Sales', 'KES ${dashboard['total_sales'] ?? 0}'),
            _card('Total Expenses', 'KES ${dashboard['total_expenses'] ?? 0}'),
            _card('Stock Value', 'KES ${dashboard['stock_value'] ?? 0}'),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, String value) {
    return Card(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
