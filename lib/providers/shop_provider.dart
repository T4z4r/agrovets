import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/shop.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ShopProvider with ChangeNotifier {
  Shop? _shop;
  bool _loading = false;

  Shop? get shop => _shop;
  bool get loading => _loading;

  Future<void> fetchShop() async {
    _loading = true;
    notifyListeners();
    try {
      // First try to load from local DB
      final dbShop = await DatabaseHelper().getShop();
      if (dbShop != null) {
        _shop = dbShop;
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from API and update DB
        final apiShop = await ApiService.getShop();
        _shop = apiShop;
        await DatabaseHelper().insertShop(apiShop);
      }
    } catch (e) {
      print(e);
      // Keep DB shop if available
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateShop(String name, String location) async {
    _loading = true;
    notifyListeners();
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        _shop = await ApiService.updateShop({
          'name': name,
          'location': location,
        });
        await DatabaseHelper().insertShop(_shop!);
      } else {
        // Offline: update local DB only, but since it's update, maybe not cache
        // For simplicity, assume updates are done online
      }
    } catch (e) {
      // Handle error if needed
    }
    _loading = false;
    notifyListeners();
  }
}
