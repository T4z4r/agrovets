import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products/product_list_screen.dart';
import '../screens/suppliers/supplier_list_screen.dart';
import '../screens/stock/stock_list_screen.dart';
import '../screens/sales/sale_list_screen.dart';
import '../screens/expenses/expense_list_screen.dart';
import '../screens/reports/daily_report_screen.dart';
import '../screens/sellers/seller_list_screen.dart';
import '../screens/shop/shop_detail_screen.dart';
import '../screens/privacy_policy_screen.dart';

class AppDrawer extends StatelessWidget {
  final String? activeScreen;

  const AppDrawer({super.key, this.activeScreen});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: Theme.of(context).primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/logo.png'),
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
              context,
              Icons.dashboard,
              AppLocalizations.of(context)!.dashboard,
              () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    (route) => false,
                  )),
          if (auth.isOwner || auth.isSeller)
            _drawerTile(
                context, Icons.store, AppLocalizations.of(context)!.shop, () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const ShopDetailScreen()),
                (route) => false,
              );
            }, isActive: activeScreen == 'shop'),
          _drawerTile(
              context, Icons.inventory, AppLocalizations.of(context)!.products,
              () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ProductListScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'products'),
          _drawerTile(
              context, Icons.people, AppLocalizations.of(context)!.suppliers,
              () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SupplierListScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'suppliers'),
          if (auth.isOwner || auth.isAdmin || auth.isSeller)
            _drawerTile(
                context, Icons.person, AppLocalizations.of(context)!.sellers,
                () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SellerListScreen()),
                (route) => false,
              );
            }, isActive: activeScreen == 'sellers'),
          _drawerTile(
              context, Icons.storage, AppLocalizations.of(context)!.stock, () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const StockListScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'stock'),
          _drawerTile(
              context, Icons.point_of_sale, AppLocalizations.of(context)!.sales,
              () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SaleListScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'sales'),
          _drawerTile(
              context, Icons.money_off, AppLocalizations.of(context)!.expenses,
              () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const ExpenseListScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'expenses'),
          _drawerTile(
              context, Icons.bar_chart, AppLocalizations.of(context)!.reports,
              () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DailyReportScreen()),
              (route) => false,
            );
          }, isActive: activeScreen == 'reports'),
          const Divider(),
          // Language Switcher Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.localeName == 'sw'
                      ? 'Lugha'
                      : 'Language',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<LocaleProvider>(
                  builder: (context, localeProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                localeProvider.setLocale(const Locale('en')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  localeProvider.locale.languageCode == 'en'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                              foregroundColor:
                                  localeProvider.locale.languageCode == 'en'
                                      ? Colors.white
                                      : Colors.black,
                              elevation:
                                  localeProvider.locale.languageCode == 'en'
                                      ? 2
                                      : 0,
                            ),
                            child: const Text('English'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                localeProvider.setLocale(const Locale('sw')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  localeProvider.locale.languageCode == 'sw'
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[200],
                              foregroundColor:
                                  localeProvider.locale.languageCode == 'sw'
                                      ? Colors.white
                                      : Colors.black,
                              elevation:
                                  localeProvider.locale.languageCode == 'sw'
                                      ? 2
                                      : 0,
                            ),
                            child: const Text('Kiswahili'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          _drawerTile(context, Icons.privacy_tip,
              AppLocalizations.of(context)!.privacyPolicy, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          }),
          const Divider(),
          _drawerTile(
              context, Icons.logout, AppLocalizations.of(context)!.logout,
              () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.confirmLogout),
                content: Text(AppLocalizations.of(context)!.logoutMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context)!.logout),
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

  Widget _drawerTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {bool isActive = false}) {
    return Container(
      color: isActive
          ? Theme.of(context).primaryColorLight.withOpacity(0.1)
          : null,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Theme.of(context).primaryColor : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
