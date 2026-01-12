class PrivacyPolicy {
  final int id;
  final String title;
  final String content;
  final String isActive;
  final String createdAt;
  final String updatedAt;

  PrivacyPolicy({
    required this.id,
    required this.title,
    required this.content,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivacyPolicy.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicy(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
