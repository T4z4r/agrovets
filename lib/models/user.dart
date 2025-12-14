// lib/models/user.dart
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;

  User(
      {required this.id,
      required this.name,
      required this.email,
      required this.role,
      this.isActive = true});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? true,
    );
  }
}
