import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/number_formatter.dart';
import '../widgets/app_drawer.dart';
import '../widgets/app_tour_dialog.dart';
import 'auth/login_screen.dart';
import 'guide_list_screen.dart';
import 'products/product_form_screen.dart';
import 'sales/sale_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _menuButtonKey = GlobalKey();
  final GlobalKey _statsSectionKey = GlobalKey();
  final GlobalKey _quickActionsKey = GlobalKey();
  final GlobalKey _addProductKey = GlobalKey();
  final GlobalKey _newSaleKey = GlobalKey();
  final GlobalKey _tourHelpKey = GlobalKey();
  final Map<String, GlobalKey> _drawerItemKeys = {
    'dashboard': GlobalKey(),
    'shop': GlobalKey(),
    'products': GlobalKey(),
    'suppliers': GlobalKey(),
    'sellers': GlobalKey(),
    'stock': GlobalKey(),
    'sales': GlobalKey(),
    'expenses': GlobalKey(),
    'reports': GlobalKey(),
  };

  Map<String, dynamic> dashboard = {};
  bool _loading = false;
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
    };
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

  String _tourText(String en, String sw) {
    return AppLocalizations.of(context)?.localeName == 'sw' ? sw : en;
  }

  Future<void> _showAppTour() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final steps = <AppTourStep>[
      AppTourStep(
        title: _tourText('Your dashboard menu', 'Menyu ya dashibodi'),
        description: _tourText(
          'Use the drawer to jump to products, sales, stock, reports, and shop settings.',
          'Tumia menyu ya pembeni kwenda bidhaa, mauzo, hisa, ripoti, na mipangilio ya duka.',
        ),
        targetKey: _menuButtonKey,
        highlightLabel: _tourText(
          'Tap the menu button whenever you want the full navigation list.',
          'Bonyeza kitufe cha menyu ili kuona chaguo zote za usogezaji.',
        ),
      ),
      AppTourStep(
        title: _tourText('Quick actions', 'Vitendo vya haraka'),
        description: _tourText(
          'These cards are the fastest way to add products or create a sale.',
          'Kadi hizi ndizo njia ya haraka zaidi kuongeza bidhaa au kuanzisha mauzo.',
        ),
        targetKey: _quickActionsKey,
      ),
      AppTourStep(
        title: _tourText('Add a product', 'Ongeza bidhaa'),
        description: _tourText(
          'Use this when you need to create a new product record or restock an item.',
          'Tumia hapa unapohitaji kuongeza bidhaa mpya au kujaza upya bidhaa.',
        ),
        targetKey: _addProductKey,
      ),
      AppTourStep(
        title: _tourText('Start a sale', 'Anzisha mauzo'),
        description: _tourText(
          'Open the sales flow to record a customer purchase and generate a receipt.',
          'Fungua mauzo ili kurekodi ununuzi wa mteja na kutoa risiti.',
        ),
        targetKey: _newSaleKey,
      ),
      AppTourStep(
        title: _tourText('Help and guides', 'Msaada na maelekezo'),
        description: _tourText(
          'This menu opens written guides and lets you replay the tour anytime.',
          'Menyu hii hufungua maelekezo na pia hukuruhusu kurudia tour wakati wowote.',
        ),
        targetKey: _tourHelpKey,
      ),
      AppTourStep(
        title: _tourText('Dashboard insights', 'Muhtasari wa dashibodi'),
        description: _tourText(
          'The totals, stock value, and low-stock alerts help you watch the business at a glance.',
          'Jumla, thamani ya hisa, na tahadhari za hisa ndogo hukusaidia kufuatilia biashara kwa haraka.',
        ),
        targetKey: _statsSectionKey,
      ),
    ];

    await AppTourDialog.show(
      context,
      title: _tourText('Owner walkthrough', 'Mwongozo wa mmiliki'),
      steps: steps,
    );
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
                  _showAppTour();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.appName} ${AppLocalizations.of(context)!.dashboard}',
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          key: _menuButtonKey,
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            key: _tourHelpKey,
            icon: const Icon(Icons.info),
            onPressed: _showHelpMenu,
          ),
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                  title: Text(
                    AppLocalizations.of(context)!.confirmLogout,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
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
      drawer: AppDrawer(activeScreen: 'dashboard', itemKeys: _drawerItemKeys),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        Theme.of(context).primaryColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.waving_hand,
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.goodDay,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
              Container(
                key: _statsSectionKey,
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: SpinKitWaveSpinner(
                            color: Theme.of(context).primaryColor,
                            size: 50.0,
                          ),
                        ),
                      )
                    : Column(
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
                                Colors.blue,
                                'totalProducts',
                              ),
                              _statCard(
                                AppLocalizations.of(context)!.todaySales,
                                NumberFormatter.formatCurrency(
                                  num.tryParse(
                                    dashboard['today_sales']?.toString() ?? '0',
                                  ),
                                ),
                                Icons.trending_up,
                                Theme.of(context).primaryColor,
                                'todaySales',
                              ),
                              _statCard(
                                AppLocalizations.of(context)!.totalSales,
                                NumberFormatter.formatCurrency(
                                  num.tryParse(
                                    dashboard['total_sales']?.toString() ?? '0',
                                  ),
                                ),
                                Icons.monetization_on,
                                Colors.orange,
                                'totalSales',
                              ),
                              _statCard(
                                AppLocalizations.of(context)!.totalExpenses,
                                NumberFormatter.formatCurrency(
                                  num.tryParse(
                                    dashboard['total_expenses']?.toString() ??
                                        '0',
                                  ),
                                ),
                                Icons.money_off,
                                Colors.red,
                                'totalExpenses',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _statCardFullWidth(
                            AppLocalizations.of(context)!.stockValue,
                            NumberFormatter.formatCurrency(
                              num.tryParse(
                                dashboard['stock_value']?.toString() ?? '0',
                              ),
                            ),
                            Icons.warehouse,
                            Theme.of(context).primaryColor,
                            'stockValue',
                          ),
                          const SizedBox(height: 16),
                          _statCardFullWidth(
                            AppLocalizations.of(context)!.lowStockProducts,
                            dashboard['low_stock_products_count']?.toString() ??
                                '0',
                            Icons.warning,
                            Colors.orange,
                            'lowStockProducts',
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              Container(
                key: _quickActionsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.quickActions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            key: _addProductKey,
                            child: _quickActionCard(
                              AppLocalizations.of(context)!.addProduct,
                              Icons.add_box,
                              Colors.blue,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductFormScreen(
                                    onSave: () => _loadDashboard(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            key: _newSaleKey,
                            child: _quickActionCard(
                              AppLocalizations.of(context)!.newSale,
                              Icons.point_of_sale,
                              Theme.of(context).primaryColor,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SaleFormScreen(
                                    onSave: () => _loadDashboard(),
                                  ),
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _drawerTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isActive = false,
    GlobalKey? key,
  }) {
    return Container(
      key: key,
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

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String key,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  () => _cardVisibility[key] = !_cardVisibility[key]!,
                ),
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
    String title,
    String value,
    IconData icon,
    Color color,
    String key,
  ) {
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
                  _cardVisibility[key]! ? value : '****',
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
    );
  }

  Widget _quickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
