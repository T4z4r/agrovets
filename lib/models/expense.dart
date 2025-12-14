// lib/models/expense.dart
class Expense {
  final int id;
  final String category;
  final int amount;
  final String? description;
  final String date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      category: json['category'] ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      description: json['description'],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'description': description,
      'date': date,
    };
  }
}
