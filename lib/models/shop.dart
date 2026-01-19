// lib/models/shop.dart
class Shop {
  final int id;
  final String name;
  final String location;

  Shop({
    required this.id,
    required this.name,
    required this.location,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
    };
  }
}
