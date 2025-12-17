import 'user.dart';
import 'sale.dart';
import 'expense.dart';
import 'stock_transaction.dart';

class DailyReport {
  final double totalSales;
  final double totalExpenses;

  DailyReport({
    required this.totalSales,
    required this.totalExpenses,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      totalSales:
          double.tryParse(json['total_sales']?.toString() ?? '0') ?? 0.0,
      totalExpenses:
          double.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class ProfitReport {
  final double revenue;
  final double cost;
  final double profit;

  ProfitReport({
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  factory ProfitReport.fromJson(Map<String, dynamic> json) {
    return ProfitReport(
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      profit: double.tryParse(json['profit']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class SellerDaySummary {
  final String date;
  final List<Sale> sales;
  final int totalSales;
  final List<Expense> expenses;
  final int totalExpenses;
  final List<StockTransaction> stockTransactions;

  SellerDaySummary({
    required this.date,
    required this.sales,
    required this.totalSales,
    required this.expenses,
    required this.totalExpenses,
    required this.stockTransactions,
  });

  factory SellerDaySummary.fromJson(Map<String, dynamic> json) {
    return SellerDaySummary(
      date: json['date'] ?? '',
      sales:
          (json['sales'] as List?)?.map((s) => Sale.fromJson(s)).toList() ?? [],
      totalSales: int.tryParse(json['total_sales']?.toString() ?? '0') ?? 0,
      expenses: (json['expenses'] as List?)
              ?.map((e) => Expense.fromJson(e))
              .toList() ??
          [],
      totalExpenses:
          int.tryParse(json['total_expenses']?.toString() ?? '0') ?? 0,
      stockTransactions: (json['stock_transactions'] as List?)
              ?.map((st) => StockTransaction.fromJson(st))
              .toList() ??
          [],
    );
  }
}
