// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String unit;
  final String category;
  final int stock;
  final int costPrice;
  final int sellingPrice;

  Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.stock,
    required this.costPrice,
    required this.sellingPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      category: json['category'],
      stock: json['stock'],
      costPrice: json['cost_price'],
      sellingPrice: json['selling_price'],
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
