import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/guide_list_screen.dart';
import '../../services/app_tour_service.dart';
import '../../widgets/app_tour_dialog.dart';
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
  bool _tourScheduled = false;

  final GlobalKey _tourHelpKey = GlobalKey();
  final GlobalKey _languageKey = GlobalKey();
  final GlobalKey _dashboardTabKey = GlobalKey();
  final GlobalKey _productsTabKey = GlobalKey();
  final GlobalKey _salesTabKey = GlobalKey();
  final GlobalKey _stockTabKey = GlobalKey();
  final GlobalKey _expensesTabKey = GlobalKey();

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

  String _tourText(String en, String sw) {
    return AppLocalizations.of(context)?.localeName == 'sw' ? sw : en;
  }

  Future<void> _showHelpMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                _tourText('Help & tour', 'Msaada na tour'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Guides'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuideListScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline),
                title: Text(_tourText('Replay tour', 'Rudia tour')),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showAppTour(force: true);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAppTour({bool force = false}) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    if (!force) {
      final shouldShow = await AppTourService.shouldShowTour(auth.user);
      if (!shouldShow || !mounted) return;
    }

    final steps = <AppTourStep>[
      AppTourStep(
        title: _tourText('Help and guides', 'Msaada na maelekezo'),
        description: _tourText(
          'Open this menu for written guides or to replay the tour whenever you need a refresher.',
          'Fungua menyu hii kupata maelekezo au kurudia tour unapohitaji ukumbusho.',
        ),
        targetKey: _tourHelpKey,
      ),
      AppTourStep(
        title: _tourText('Language switcher', 'Kubadili lugha'),
        description: _tourText(
          'Switch between English and Swahili from here without leaving the app.',
          'Badilisha kati ya Kiingereza na Kiswahili bila kutoka kwenye programu.',
        ),
        targetKey: _languageKey,
      ),
      AppTourStep(
        title: _tourText('Dashboard', 'Dashibodi'),
        description: _tourText(
          'This overview shows your performance, totals, and stock warnings. Tap next to move to products.',
          'Muhtasari huu unaonyesha utendaji wako, jumla, na tahadhari za hisa. Bonyeza next kwenda bidhaa.',
        ),
        targetKey: _dashboardTabKey,
        onNext: (_) async {
          _onItemTapped(1);
          await Future.delayed(const Duration(milliseconds: 250));
        },
      ),
      AppTourStep(
        title: _tourText('Products', 'Bidhaa'),
        description: _tourText(
          'Browse the catalog, search stock, and check product details here. Tap next for sales.',
          'Vinjari katalogi, tafuta hisa, na angalia maelezo ya bidhaa hapa. Bonyeza next kwenda mauzo.',
        ),
        targetKey: _productsTabKey,
        onBack: (_) async {
          _onItemTapped(0);
          await Future.delayed(const Duration(milliseconds: 250));
        },
        onNext: (_) async {
          _onItemTapped(2);
          await Future.delayed(const Duration(milliseconds: 250));
        },
      ),
      AppTourStep(
        title: _tourText('Sales', 'Mauzo'),
        description: _tourText(
          'Record new sales, review receipts, and keep daily trading history. Tap next for stock.',
          'Rekodi mauzo mapya, kagua risiti, na hifadhi historia ya biashara ya kila siku. Bonyeza next kwenda hisa.',
        ),
        targetKey: _salesTabKey,
        onBack: (_) async {
          _onItemTapped(1);
          await Future.delayed(const Duration(milliseconds: 250));
        },
        onNext: (_) async {
          _onItemTapped(3);
          await Future.delayed(const Duration(milliseconds: 250));
        },
      ),
      AppTourStep(
        title: _tourText('Stock', 'Hisa'),
        description: _tourText(
          'Track stock movements and add stock transactions from here. Tap next for expenses.',
          'Fuatilia mienendo ya hisa na ongeza miamala ya hisa hapa. Bonyeza next kwenda gharama.',
        ),
        targetKey: _stockTabKey,
        onBack: (_) async {
          _onItemTapped(2);
          await Future.delayed(const Duration(milliseconds: 250));
        },
        onNext: (_) async {
          _onItemTapped(4);
          await Future.delayed(const Duration(milliseconds: 250));
        },
      ),
      AppTourStep(
        title: _tourText('Expenses', 'Gharama'),
        description: _tourText(
          'Log business expenses so the day-to-day totals stay accurate.',
          'Rekodi gharama za biashara ili jumla za kila siku zibaki sahihi.',
        ),
        targetKey: _expensesTabKey,
        onBack: (_) async {
          _onItemTapped(3);
          await Future.delayed(const Duration(milliseconds: 250));
        },
      ),
    ];

    await AppTourDialog.show(
      context,
      title: _tourText('Seller walkthrough', 'Mwongozo wa muuzaji'),
      steps: steps,
    );

    if (mounted && !force) {
      await AppTourService.markTourSeen(auth.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    if (!_tourScheduled) {
      _tourScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showAppTour();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Image(
              image: AssetImage('assets/logo.png'),
              width: 32,
              height: 32,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            key: _tourHelpKey,
            icon: const Icon(Icons.info),
            onPressed: _showHelpMenu,
          ),
          Container(
            key: _languageKey,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButton<String>(
              value: localeProvider.locale.languageCode,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: Theme.of(context).primaryColor,
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'sw', child: Text('Swahili')),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  final shouldChange = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                      title: Text(
                        AppLocalizations.of(context)!.confirmLanguageChange,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        AppLocalizations.of(context)!.languageChangeMessage,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      actionsPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Yes'),
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
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                  title: Text(
                    AppLocalizations.of(context)!.confirmLogout,
                    style: const TextStyle(
                      color: Color(0xFF72140C),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    AppLocalizations.of(context)!.logoutMessage,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  actionsPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: _bottomNavItem(
                  key: _dashboardTabKey,
                  index: 0,
                  icon: Icons.dashboard,
                  label: AppLocalizations.of(context)!.dashboard,
                ),
              ),
              Expanded(
                child: _bottomNavItem(
                  key: _productsTabKey,
                  index: 1,
                  icon: Icons.inventory,
                  label: AppLocalizations.of(context)!.products,
                ),
              ),
              Expanded(
                child: _bottomNavItem(
                  key: _salesTabKey,
                  index: 2,
                  icon: Icons.point_of_sale,
                  label: AppLocalizations.of(context)!.sales,
                ),
              ),
              Expanded(
                child: _bottomNavItem(
                  key: _stockTabKey,
                  index: 3,
                  icon: Icons.storage,
                  label: AppLocalizations.of(context)!.stock,
                ),
              ),
              Expanded(
                child: _bottomNavItem(
                  key: _expensesTabKey,
                  index: 4,
                  icon: Icons.calculate,
                  label: AppLocalizations.of(context)!.expenses,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem({
    required GlobalKey key,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    final activeColor = Theme.of(context).primaryColor;
    const inactiveColor = Colors.grey;

    return InkWell(
      key: key,
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
