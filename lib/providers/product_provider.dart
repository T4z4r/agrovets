import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _loading = false;

  List<Product> get products => _products;
  bool get loading => _loading;

  Future<void> fetchProducts() async {
    _loading = true;
    notifyListeners();
    try {
      // First try to load from local DB
      final dbProducts = await DatabaseHelper().getProducts();
      if (dbProducts.isNotEmpty) {
        _products = dbProducts;
        notifyListeners();
      }

      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from API and update DB
        final res = await ApiService.get('/api/products');
        final apiProducts = (res['data'] as List).map((p) => Product.fromJson(p)).toList();
        _products = apiProducts;
        await DatabaseHelper().insertProducts(apiProducts);
        notifyListeners();
      }
    } catch (e) {
      // Keep DB products if available
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> syncFromStockResponse(Map<String, dynamic> response) async {
    final data = response['data'];
    final stockItems = data is List ? data : [data];
    final updatedProducts = stockItems
        .whereType<Map<String, dynamic>>()
        .map((item) => item['product'])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();

    if (updatedProducts.isEmpty) return;

    final productsById = {
      for (final product in _products) product.id: product,
      for (final product in updatedProducts) product.id: product,
    };
    _products = productsById.values.toList();
    await DatabaseHelper().insertProducts(updatedProducts);
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    // Assuming online for now
    // After adding via API, refetch
    await fetchProducts();
  }

  Future<void> updateProduct(Product product) async {
    // Assuming online
    await fetchProducts();
  }

  Future<void> deleteProduct(int id) async {
    // Assuming online
    await fetchProducts();
  }
}
