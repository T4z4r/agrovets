// lib/screens/seller/seller_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/auth/login_screen.dart';
import 'seller_dashboard_screen.dart';
import 'seller_product_list_screen.dart';
import 'seller_sale_list_screen.dart';
import 'seller_stock_list_screen.dart';
import 'seller_expense_list_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SellerDashboardScreen(),
    SellerProductListScreen(),
    SellerSaleListScreen(),
    SellerStockListScreen(),
    SellerExpenseListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.agroVetSeller),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            icon: const Icon(Icons.language, color: Colors.white),
            dropdownColor: Colors.green[700],
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'sw',
                child: Text('Swahili'),
              ),
            ],
            onChanged: (String? newValue) async {
              if (newValue != null) {
                final shouldChange = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    backgroundColor: Colors.white,
                    title: Text(
                      AppLocalizations.of(context)!.confirmLanguageChange,
                      style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.languageChangeMessage,
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
                            foregroundColor: Colors.green[600],
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        child: Text(
                            'Yes'), // Since 'yes' is not localized, but 'ok' could be used, but for now 'Yes'
                      ),
                    ],
                  ),
                );
                if (shouldChange == true) {
                  localeProvider.setLocale(Locale(newValue));
                }
              }
            },
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: AppLocalizations.of(context)!.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory),
            label: AppLocalizations.of(context)!.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.point_of_sale),
            label: AppLocalizations.of(context)!.sales,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.storage),
            label: AppLocalizations.of(context)!.stock,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: AppLocalizations.of(context)!.expenses,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
