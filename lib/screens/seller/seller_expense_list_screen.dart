// lib/screens/seller/seller_expense_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../models/expense.dart';
import '../debts/general_debt_list_screen.dart';
import '../../utils/number_formatter.dart';
import 'seller_expense_form_screen.dart';

class SellerExpenseListScreen extends StatefulWidget {
  const SellerExpenseListScreen({super.key});

  @override
  State<SellerExpenseListScreen> createState() =>
      _SellerExpenseListScreenState();
}

class _SellerExpenseListScreenState extends State<SellerExpenseListScreen> {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      final res = await ApiService.get('/api/expenses');
      setState(() {
        _expenses =
            (res['data'] as List).map((e) => Expense.fromJson(e)).toList();
        _filteredExpenses = _expenses;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _filterExpenses(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredExpenses = _expenses;
      } else {
        _filteredExpenses = _expenses.where((expense) {
          return expense.category.toLowerCase().contains(query.toLowerCase()) ||
              expense.date.toLowerCase().contains(query.toLowerCase()) ||
              (expense.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  Widget _buildExpenseTab(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              onChanged: _filterExpenses,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchExpenses,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),

          // Expenses List
          Expanded(
            child: _loading
                ? Center(
                    child: SpinKitWaveSpinner(
                        color: Theme.of(context).primaryColor, size: 50.0))
                : _filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calculate,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? AppLocalizations.of(context)!
                                      .noExpensesFound
                                  : AppLocalizations.of(context)!
                                      .noExpensesMatch,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadExpenses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(4),
                          itemCount: _filteredExpenses.length,
                          itemBuilder: (ctx, i) {
                            final e = _filteredExpenses[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.money_off,
                                    color: Colors.red[600],
                                  ),
                                ),
                                title: Text(
                                  e.category,
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
                                          Icons.attach_money,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          NumberFormatter.formatCurrency(
                                              e.amount),
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
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${AppLocalizations.of(context)!.dateLabel}: ${e.date}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (e.description != null &&
                                        e.description!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              e.description!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
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
              builder: (_) => SellerExpenseFormScreen(onSave: _loadExpenses),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(
                  icon: const Icon(Icons.money_off),
                  text: AppLocalizations.of(context)!.expenses,
                ),
                Tab(
                  icon: const Icon(Icons.account_balance_wallet),
                  text: AppLocalizations.of(context)!.debts,
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildExpenseTab(context),
                const GeneralDebtListScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
