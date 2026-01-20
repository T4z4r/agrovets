// lib/models/guide.dart
class Guide {
  final int id;
  final String title;
  final String content;
  final String? filePath;
  final String language;
  final String targetRole;
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? creator;

  Guide({
    required this.id,
    required this.title,
    required this.content,
    this.filePath,
    required this.language,
    required this.targetRole,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.creator,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      filePath: json['file_path']?.toString(),
      language: json['language']?.toString() ?? 'en',
      targetRole: json['target_role']?.toString() ?? 'both',
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      creator: json['creator'],
    );
  }
}