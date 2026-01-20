import 'package:flutter/material.dart';
import '../models/shop.dart';
import '../services/api_service.dart';

class ShopProvider with ChangeNotifier {
  Shop? _shop;
  bool _loading = false;

  Shop? get shop => _shop;
  bool get loading => _loading;

  Future<void> fetchShop() async {
    _loading = true;
    notifyListeners();
    try {
      _shop = await ApiService.getShop();
    } catch (e) {
      print(e);
      _shop = null;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateShop(String name, String location) async {
    _loading = true;
    notifyListeners();
    try {
      _shop = await ApiService.updateShop({
        'name': name,
        'location': location,
      });
    } catch (e) {
      // Handle error if needed
    }
    _loading = false;
    notifyListeners();
  }
}
