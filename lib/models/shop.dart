// lib/models/shop.dart
class Shop {
  final int id;
  final String name;
  final String location;
  final int? ownerId;
  final String? createdAt;
  final String? updatedAt;

  Shop({
    required this.id,
    required this.name,
    required this.location,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      ownerId: int.tryParse(json['owner_id']?.toString() ?? ''),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
    };
  }
}
