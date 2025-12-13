class DailyReport {
  final double totalSales;
  final double totalExpenses;

  DailyReport({
    required this.totalSales,
    required this.totalExpenses,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      totalSales: json['total_sales']?.toDouble() ?? 0.0,
      totalExpenses: json['total_expenses']?.toDouble() ?? 0.0,
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
      revenue: json['revenue']?.toDouble() ?? 0.0,
      cost: json['cost']?.toDouble() ?? 0.0,
      profit: json['profit']?.toDouble() ?? 0.0,
    );
  }
}
