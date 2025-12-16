// lib/models/stock_transaction.dart
import 'product.dart';
import 'supplier.dart';
import 'user.dart';

class StockTransaction {
  final int id;
  final int productId;
  final String type;
  final int quantity;
  final int? supplierId;
  final String date;
  final String? remarks;
  final Product? product;
  final Supplier? supplier;
  final User? user;

  StockTransaction({
    required this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.supplierId,
    required this.date,
    this.remarks,
    this.product,
    this.supplier,
    this.user,
  });

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] ?? 0,
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      supplierId: json['supplier_id'] != null
          ? int.tryParse(json['supplier_id'].toString())
          : null,
      date: json['date'] ?? '',
      remarks: json['remarks'],
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      supplier: json['supplier'] != null ? Supplier.fromJson(json['supplier']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'supplier_id': supplierId,
      'date': date,
      'remarks': remarks,
    };
  }
}
