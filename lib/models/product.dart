// lib/models/product.dart
class Product {
  final int id;
  final String? name;
  final String? unit;
  final String? category;
  final int? stock;
  final int? costPrice;
  final int? sellingPrice;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.stock,
    required this.costPrice,
    required this.sellingPrice,
  });

  factory Product.fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return Product(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      category: map['category'] ?? '',
      stock: int.tryParse(map['stock']?.toString() ?? '0') ?? 0,
      costPrice: int.tryParse(map['cost_price']?.toString() ?? '0') ?? 0,
      sellingPrice: int.tryParse(map['selling_price']?.toString() ?? '0') ?? 0,
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
    };
  }
}
