// lib/models/about.dart
class About {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  About({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory About.fromJson(Map<String, dynamic> json) {
    return About(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
