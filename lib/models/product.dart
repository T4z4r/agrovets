// lib/models/product.dart
import 'stock_transaction.dart';

class Product {
  final int id;
  final String? name;
  final String? unit;
  final String? category;
  final double? stock;
  final double? costPrice;
  final double? sellingPrice;
  final double? minimumQuantity;
  final String? barcode;
  final List<StockTransaction>? stockTransactions;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.stock,
    required this.costPrice,
    required this.sellingPrice,
    required this.minimumQuantity,
    this.barcode,
    this.stockTransactions,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return Product(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      category: map['category'] ?? '',
      stock: double.tryParse(map['stock']?.toString() ?? '0') ?? 0,
      costPrice: double.tryParse(map['cost_price']?.toString() ?? '0') ?? 0,
      sellingPrice:
          double.tryParse(map['selling_price']?.toString() ?? '0') ?? 0,
      minimumQuantity:
          double.tryParse(map['minimum_quantity']?.toString() ?? '0') ?? 0,
      barcode: map['barcode'],
      stockTransactions: map['stock_transactions'] != null
          ? (map['stock_transactions'] as List)
              .map((e) => StockTransaction.fromJson(e))
              .toList()
          : null,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'category': category,
      'stock': stock,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'minimum_quantity': minimumQuantity,
      'barcode': barcode,
    };
  }
}
