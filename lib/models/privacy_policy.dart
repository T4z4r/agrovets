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
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isActive: json['is_active']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
