import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sale.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class SaleProvider with ChangeNotifier {
  List<Sale> _sales = [];
  bool _loading = false;

  List<Sale> get sales => _sales;
  bool get loading => _loading;

  Future<void> fetchSales() async {
    _loading = true;
    notifyListeners();
    try {
      // First try to load from local DB
      final dbSales = await DatabaseHelper().getSales();
      if (dbSales.isNotEmpty) {
        _sales = dbSales;
        notifyListeners();
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from API and update DB
        final res = await ApiService.get('/api/sales');
        final apiSales = (res['data'] as List).map((s) => Sale.fromJson(s)).toList();
        _sales = apiSales;
        await DatabaseHelper().insertSales(apiSales);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching sales: $e');
      // Keep DB sales if available
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addSale(Sale sale) async {
    // Assuming online for now
    await fetchSales();
  }

  Future<void> deleteSale(int id) async {
    // Assuming online
    await fetchSales();
  }
}