// lib/utils/number_formatter.dart
import 'package:intl/intl.dart';

class NumberFormatter {
  static final NumberFormat _currencyFormat = NumberFormat('#,###');
  static final NumberFormat _decimalFormat = NumberFormat('#,###.##');

  /// Formats a number as currency with Tanzanian Shilling symbol
  static String formatCurrency(num? value) {
    if (value == null) return 'Tsh 0';
    return 'Tsh ${_currencyFormat.format(value)}';
  }

  /// Formats a number with commas for thousands separator
  static String formatNumber(num? value) {
    if (value == null) return '0';
    return _currencyFormat.format(value);
  }

  /// Formats a number with decimal places
  static String formatDecimal(num? value, {int decimals = 2}) {
    if (value == null) return '0.${'0' * decimals}';
    return NumberFormat('#,###.${'#' * decimals}').format(value);
  }

  /// Formats a percentage with one decimal place
  static String formatPercentage(double? value) {
    if (value == null) return '0.0%';
    return '${value.toStringAsFixed(1)}%';
  }

  /// Calculates and formats profit margin percentage
  static String formatProfitMargin(num? profit, num? revenue) {
    if (revenue == null || revenue == 0 || profit == null) return '0%';
    final margin = (profit / revenue) * 100;
    return formatPercentage(margin);
  }
}
