import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _thbFormat = NumberFormat('#,##0.00', 'th_TH');
  static final NumberFormat _compactFormat = NumberFormat('#,##0', 'th_TH');

  static String format(double amount) {
    return '฿${_thbFormat.format(amount)}';
  }

  static String formatCompact(double amount) {
    return '฿${_compactFormat.format(amount)}';
  }
}
