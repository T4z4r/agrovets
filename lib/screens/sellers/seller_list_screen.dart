// lib/screens/sellers/seller_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';
import 'seller_form_screen.dart';

class SellerListScreen extends StatefulWidget {
  const SellerListScreen({super.key});

  @override
  State<SellerListScreen> createState() => _SellerListScreenState();
}

class _SellerListScreenState extends State<SellerListScreen> {
  List<User> _sellers = [];
  List<User> _filteredSellers = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    try {
      final res = await ApiService.getSellers();
      setState(() {
        _sellers = (res['data'] as List).map((s) => User.fromJson(s)).toList();
        _filteredSellers = _sellers;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.noSellersFound)));
      }
    }
  }

  Future<void> _deleteSeller(int id) async {
    try {
      await ApiService.deleteSeller(id);
      _loadSellers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.operationFailed)));
      }
    }
  }

  Future<void> _toggleBlockSeller(int id) async {
    try {
      await ApiService.toggleBlockSeller(id);
      _loadSellers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.operationFailed)));
      }
    }
  }

  void _filterSellers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSellers = _sellers;
      } else {
        _filteredSellers = _sellers.where((seller) {
          return seller.name.toLowerCase().contains(query.toLowerCase()) ||
              seller.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwnerOrAdmin = authProvider.isOwner || authProvider.isAdmin;

    if (!isOwnerOrAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.accessDenied),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noPermission),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.sellers),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSellers,
          ),
        ],
      ),
      drawer: const AppDrawer(activeScreen: 'sellers'),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _filterSellers,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchSellers,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Sellers List
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitWaveSpinner(color: Theme.of(context).primaryColor, size: 50.0))
                : _filteredSellers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? AppLocalizations.of(context)!.noSellersFound
                                  : AppLocalizations.of(context)!
                                      .noSellersMatch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSellers,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredSellers.length,
                          itemBuilder: (ctx, i) {
                            final s = _filteredSellers[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: s.isActive
                                        ? Theme.of(context).primaryColorLight
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: s.isActive
                                        ? Theme.of(context).primaryColor
                                        : Colors.red[600],
                                  ),
                                ),
                                title: Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          s.email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          s.isActive
                                              ? Icons.check_circle
                                              : Icons.block,
                                          size: 14,
                                          color: s.isActive
                                              ? Theme.of(context).primaryColor
                                              : Colors.red[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          s.isActive
                                              ? AppLocalizations.of(context)!
                                                  .active
                                              : AppLocalizations.of(context)!
                                                  .blocked,
                                          style: TextStyle(
                                            color: s.isActive
                                                ? Theme.of(context).primaryColor
                                                : Colors.red[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit),
                                        title: Text(
                                            AppLocalizations.of(context)!.edit),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'toggle_block',
                                      child: ListTile(
                                        leading: Icon(
                                          s.isActive
                                              ? Icons.block
                                              : Icons.check_circle,
                                          color: s.isActive
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                        title: Text(
                                          s.isActive
                                              ? AppLocalizations.of(context)!
                                                  .block
                                              : AppLocalizations.of(context)!
                                                  .unblock,
                                          style: TextStyle(
                                            color: s.isActive
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete,
                                            color: Colors.red),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .delete,
                                            style:
                                                TextStyle(color: Colors.red)),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'edit') {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SellerFormScreen(
                                            seller: s,
                                            onSave: _loadSellers,
                                          ),
                                        ),
                                      );
                                    } else if (value == 'toggle_block') {
                                      await _toggleBlockSeller(s.id);
                                    } else if (value == 'delete') {
                                      // Show confirmation dialog
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .deleteSeller),
                                          content: Text(
                                              '${AppLocalizations.of(context)!.deleteProductConfirm} "${s.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .delete),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await _deleteSeller(s.id);
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SellerFormScreen(onSave: _loadSellers),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
