class GeneralDebtPayment {
  final int id;
  final double amount;
  final String paymentDate;
  final String? paymentMethod;
  final String? notes;

  GeneralDebtPayment({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.notes,
  });

  factory GeneralDebtPayment.fromJson(Map<String, dynamic> json) {
    return GeneralDebtPayment(
      id: json['id'] ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      paymentDate: json['payment_date'] ?? json['date'] ?? '',
      paymentMethod: json['payment_method'],
      notes: json['notes'],
    );
  }
}

class GeneralDebt {
  final int id;
  final String debtorName;
  final String? debtorPhone;
  final String? debtorEmail;
  final String? description;
  final double amount;
  final double amountPaid;
  final double balance;
  final String status;
  final String debtDate;
  final String? dueDate;
  final List<GeneralDebtPayment> payments;

  GeneralDebt({
    required this.id,
    required this.debtorName,
    this.debtorPhone,
    this.debtorEmail,
    this.description,
    required this.amount,
    required this.amountPaid,
    required this.balance,
    required this.status,
    required this.debtDate,
    this.dueDate,
    this.payments = const [],
  });

  factory GeneralDebt.fromJson(Map<String, dynamic> json) {
    return GeneralDebt(
      id: json['id'] ?? 0,
      debtorName: json['debtor_name'] ?? '',
      debtorPhone: json['debtor_phone'],
      debtorEmail: json['debtor_email'],
      description: json['description'],
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      amountPaid:
          double.tryParse(json['amount_paid']?.toString() ?? '0') ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'pending',
      debtDate: json['debt_date'] ?? json['date'] ?? '',
      dueDate: json['due_date'],
      payments: (json['payments'] as List? ?? [])
          .map((payment) => GeneralDebtPayment.fromJson(payment))
          .toList(),
    );
  }
}
