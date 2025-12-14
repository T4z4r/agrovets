// lib/models/sale.dart
class Sale {
  final int id;
  final int sellerId;
  final String saleDate;
  final List<SaleItem> items;

  Sale({
    required this.id,
    required this.sellerId,
    required this.saleDate,
    required this.items,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] ?? 0,
      sellerId: int.tryParse(json['seller_id']?.toString() ?? '0') ?? 0,
      saleDate: json['sale_date'] ?? '',
      items:
          (json['items'] as List?)?.map((i) => SaleItem.fromJson(i)).toList() ??
              [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'sale_date': saleDate,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class SaleItem {
  final int productId;
  final int quantity;
  final int price;

  SaleItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: int.tryParse(json['product_id']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      price: int.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}
