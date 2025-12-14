// lib/screens/stock/stock_list_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/stock_transaction.dart';
import 'stock_form_screen.dart';

class StockListScreen extends StatefulWidget {
  const StockListScreen({super.key});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen> {
  List<StockTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final res = await ApiService.get('/api/stock');
      setState(() {
        _transactions = (res['data'] as List)
            .map((t) => StockTransaction.fromJson(t))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteTransaction(int id) async {
    try {
      await ApiService.delete('/api/stock/$id');
      _loadTransactions();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Stock Transactions'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No stock transactions found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTransactions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _transactions.length,
                    itemBuilder: (ctx, i) {
                      final t = _transactions[i];
                      // Determine icon and color based on transaction type
                      IconData iconData;
                      Color iconColor;
                      Color cardColor;

                      switch (t.type) {
                        case 'stock_in':
                          iconData = Icons.trending_up;
                          iconColor = Colors.green[600]!;
                          cardColor = Colors.green[50]!;
                          break;
                        case 'stock_out':
                          iconData = Icons.trending_down;
                          iconColor = Colors.red[600]!;
                          cardColor = Colors.red[50]!;
                          break;
                        case 'damage':
                          iconData = Icons.error;
                          iconColor = Colors.orange[600]!;
                          cardColor = Colors.orange[50]!;
                          break;
                        case 'return':
                          iconData = Icons.keyboard_return;
                          iconColor = Colors.blue[600]!;
                          cardColor = Colors.blue[50]!;
                          break;
                        default:
                          iconData = Icons.inventory;
                          iconColor = Colors.grey[600]!;
                          cardColor = Colors.grey[50]!;
                      }

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
                              color: cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              iconData,
                              color: iconColor,
                            ),
                          ),
                          title: Text(
                            t.type.replaceAll('_', ' ').toUpperCase(),
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
                                    Icons.format_list_numbered,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Quantity: ${t.quantity}',
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
                                    'Date: ${t.date}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (t.remarks != null &&
                                  t.remarks!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.note,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        t.remarks!,
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
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'delete') {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Transaction'),
                                    content: Text(
                                        'Are you sure you want to delete this ${t.type.replaceAll('_', ' ')} transaction?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await _deleteTransaction(t.id);
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockFormScreen(onSave: _loadTransactions),
            ),
          );
        },
        backgroundColor: Colors.green[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
