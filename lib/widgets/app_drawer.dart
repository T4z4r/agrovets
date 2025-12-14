import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/suppliers/supplier_list_screen.dart';
import '../screens/stock/stock_list_screen.dart';
import '../screens/sales/sale_list_screen.dart';
import '../screens/expenses/expense_list_screen.dart';
import '../screens/reports/daily_report_screen.dart';
import '../screens/sellers/seller_list_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
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
                  child: Icon(Icons.person, size: 40, color: Colors.green[600]),
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
              Icons.dashboard,
              'Dashboard',
              () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  )),
          _drawerTile(Icons.inventory, 'Products', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
              (route) => false,
            );
          }),
          _drawerTile(Icons.people, 'Suppliers', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SupplierListScreen()),
              (route) => false,
            );
          }),
          if (auth.isOwner || auth.isAdmin || auth.isSeller)
            _drawerTile(Icons.person, 'Sellers', () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SellerListScreen()),
                (route) => false,
              );
            }),
          _drawerTile(Icons.storage, 'Stock', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StockListScreen()),
              (route) => false,
            );
          }),
          _drawerTile(Icons.point_of_sale, 'Sales', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SaleListScreen()),
              (route) => false,
            );
          }),
          _drawerTile(Icons.calculate, 'Expenses', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
              (route) => false,
            );
          }),
          _drawerTile(Icons.bar_chart, 'Reports', () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DailyReportScreen()),
              (route) => false,
            );
          }),
          const Divider(),
          _drawerTile(Icons.logout, 'Logout', () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirm Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            if (shouldLogout == true) {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[600]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
